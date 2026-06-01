#!/bin/bash
# ==============================================================================
# OS-SHIELD WIZARD DE INSTALAÇÃO (FOS002/FOS004/FOS005)
# ==============================================================================
set -e

APP_VERSION="v4.2.0"

# Cores
VERDE="\033[0;32m"
CIANO="\033[0;36m"
AMARELO="\033[0;33m"
VERMELHO="\033[0;31m"
PADRAO="\033[0m"

echo -e "${CIANO}--- INICIANDO WIZARD DE INSTALAÇÃO DO OS-SHIELD ${APP_VERSION} ---${PADRAO}"

# 0. Verificação de Dependências
DEPENDENCIAS=("zenity" "rsync" "bleachbit")
FALTANTES=()
for cmd in "${DEPENDENCIAS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        FALTANTES+=("$cmd")
    fi
done

if [ ${#FALTANTES[@]} -ne 0 ]; then
    echo -e "${AMARELO}[!] Dependências ausentes detectadas: ${FALTANTES[*]}${PADRAO}"
    echo -e "${CIANO}[*] Instalando dependências nativas via APT...${PADRAO}"
    sudo apt-get update && sudo apt-get install -y "${FALTANTES[@]}"
fi

if ! command -v ollama &> /dev/null; then
    echo -e "${AMARELO}[!] Ollama (Engine de IA) não detectado.${PADRAO}"
    echo -e "${CIANO}[*] Baixando e instalando Ollama...${PADRAO}"
    curl -fsSL https://ollama.com/install.sh | sh
fi

RECONFIGURE_MODE=0
if [ "$1" == "--reconfigure-timer" ]; then
    RECONFIGURE_MODE=1
    echo -e "${AMARELO}[*] MODO RECONFIGURAÇÃO DE AGENDAMENTO ATIVADO${PADRAO}"
else
    # 1. Checa versão antiga
    if [ -f "$HOME/.os_shield_install_success" ]; then
        OLD_VERSION=$(cat "$HOME/.os_shield_install_success" 2>/dev/null || echo "v4.0")
        echo -e "${VERDE}[*] Detectada instalação prévia ($OLD_VERSION). Atualizando para ${APP_VERSION}...${PADRAO}"
    else
        echo -e "${CIANO}[*] Primeira instalação detectada. Configurando ambiente ${APP_VERSION}...${PADRAO}"
    fi
    rm -f "$HOME/.os_shield_install_success"
fi

# 2. Pergunta ao usuário a frequência desejada
CHOICE=$(zenity --list --radiolist --title="OS-SHIELD ${APP_VERSION} - Configuração do Agendamento" \
    --text="Escolha a frequência de varredura do Daemon (IA Preditiva em background):" \
    --column="Seleção" --column="Frequência" --column="Descrição" \
    FALSE "5min" "A cada 5 minutos (Agressivo)" \
    TRUE "15min" "A cada 15 minutos (Padrão Ouro)" \
    FALSE "1h" "A cada 1 Hora (Moderado)" \
    FALSE "6h" "A cada 6 Horas (Conservador)" \
    --width=600 --height=300)

if [ -z "$CHOICE" ]; then
    echo -e "${VERMELHO}[X] Instalação cancelada pelo usuário.${PADRAO}"
    zenity --warning --title="Instalação Interrompida" --text="O sistema não está protegido. O agendamento NÃO foi ativado." --width=350
    exit 1
fi

echo -e "${VERDE}[+] Frequência escolhida: $CHOICE${PADRAO}"

# 3. Atualiza o arquivo timer base
TIMER_FILE="$(dirname "$0")/daemon_state/homeshield.timer"
sed -i "s/^OnUnitActiveSec=.*/OnUnitActiveSec=$CHOICE/" "$TIMER_FILE"
sed -i "s/^Description=.*/Description=Timer para o Daemon Shield Home (Monitoramento a cada $CHOICE)/" "$TIMER_FILE"

# 3. Configuração de Destino de Backup e Mount Point
SHIELD_CONF="$(dirname "$(realpath "$0")")/configs/shield.conf"

# 3.1 Definição do Mount Point Dinâmico (HD Secundário)
if ! grep -q "HD_DESTINO=" "$SHIELD_CONF" 2>/dev/null || grep -q "HD_DESTINO=\"/mnt/seu_hd_secundario\"" "$SHIELD_CONF" 2>/dev/null; then
    zenity --info --title="Configuração de Armazenamento" --text="Precisamos saber onde o seu HD Secundário está montado.\n\nNa próxima tela, selecione a pasta raiz do seu HD (ex: /mnt/dados, /media/hd, etc)." --width=450
    HD_DIR=$(zenity --file-selection --directory --title="Selecione o Mount Point do HD Secundário")
    if [ -n "$HD_DIR" ]; then
        # Atualiza ou insere o HD_DESTINO
        sed -i "/^HD_DESTINO=/d" "$SHIELD_CONF"
        echo -e "HD_DESTINO=\"$HD_DIR\"" | cat - "$SHIELD_CONF" > temp && mv temp "$SHIELD_CONF"
    fi
fi

# 3.2 Destino do Backup Automático
if ! grep -q "BACKUP_DESTINATION=" "$SHIELD_CONF" 2>/dev/null; then
    zenity --info --title="Backup da Home" --text="A partir desta versão, o OS-SHIELD pode fazer Snapshots automáticos de segurança da sua Home.\n\nNa próxima tela, selecione a pasta onde quer guardar os backups." --width=400
    BKP_DIR=$(zenity --file-selection --directory --title="Escolha o diretório para os Snapshots")
    if [ -n "$BKP_DIR" ]; then
        echo -e "\n# DESTINO DO BACKUP AUTOMATIZADO (RSYNC)\nBACKUP_DESTINATION=\"$BKP_DIR\"" >> "$SHIELD_CONF"
    else
        echo -e "\n# DESTINO DO BACKUP AUTOMATIZADO (RSYNC)\nBACKUP_DESTINATION=\"\"" >> "$SHIELD_CONF"
    fi
fi

# 4. Criação da estrutura do Systemd User
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$USER_SYSTEMD_DIR"
rm -f "$USER_SYSTEMD_DIR/homeshield.service" "$USER_SYSTEMD_DIR/homeshield.timer"

# Corrige o caminho absoluto do daemon_state para a pasta real antes de copiar
ABSOLUTE_PATH="$(dirname "$(realpath "$0")")"
sed -i "s|ExecStart=.*|ExecStart=$ABSOLUTE_PATH/scripts/homeshield_daemon.sh|" "$ABSOLUTE_PATH/daemon_state/homeshield.service"

cp "$ABSOLUTE_PATH/daemon_state/homeshield.service" "$USER_SYSTEMD_DIR/"
cp "$ABSOLUTE_PATH/daemon_state/homeshield.timer" "$USER_SYSTEMD_DIR/"

systemctl --user daemon-reload

if [ "$RECONFIGURE_MODE" -eq 1 ]; then
    systemctl --user daemon-reload
    systemctl --user restart homeshield.timer
    zenity --info --title="OS-SHIELD ${APP_VERSION}" --text="A frequência de varredura do OS-SHIELD foi alterada com sucesso para $CHOICE." --width=350
    echo -e "${VERDE}[+] Reconfiguração de Agendamento Concluída.${PADRAO}"
    exit 0
fi

# 5. Executa a ancoragem inicial da malha (Modo Silencioso/Headless)
echo -e "${CIANO}[*] Preparando a malha primária de links simbólicos...${PADRAO}"
if [ -f "$(dirname "$0")/scripts/links_sym_setup.sh" ]; then
    "$(dirname "$0")/scripts/links_sym_setup.sh" --silent-install
else
    echo -e "${VERMELHO}[X] Script de ancoragem não encontrado!${PADRAO}"
    exit 1
fi

# 6. Registra sucesso absoluto e grava a versão
echo "$APP_VERSION" > "$HOME/.os_shield_install_success"

# 7. Acesso Global via .bashrc
ALIAS_CMD="alias os-shield=\"$(dirname "$(realpath "$0")")/scripts/links_sym_setup.sh\""
if ! grep -Fxq "$ALIAS_CMD" "$HOME/.bashrc"; then
    echo -e "\n# OS-SHIELD Control Center" >> "$HOME/.bashrc"
    echo "$ALIAS_CMD" >> "$HOME/.bashrc"
    echo -e "${CIANO}[*] Alias 'os-shield' injetado no .bashrc para acesso global.${PADRAO}"
fi

# 8. Liga o Daemon com a nova frequência
echo -e "${CIANO}[*] Habilitando e iniciando o agendamento em background...${PADRAO}"
systemctl --user enable --now homeshield.timer

# 9. Rotina de Backup Automático do Instalador (Snapshot Inicial)
source "$SHIELD_CONF"
if [ -n "$BACKUP_DESTINATION" ] && [ -d "$BACKUP_DESTINATION" ]; then
    echo -e "${CIANO}[*] Executando Snapshot Inicial da Home via Rsync...${PADRAO}"
    rsync -a --exclude=".*" "$HOME/" "$BACKUP_DESTINATION/OS_SHIELD_HOME_SNAPSHOT/" | \
        zenity --progress --title="OS-SHIELD ${APP_VERSION} - Snapshot" \
        --text="Realizando backup estrutural da Home...\nPreservando configurações e ignorando links pesados." \
        --pulsate --auto-close --no-cancel || true
fi

zenity --info --title="Instalação Concluída (${APP_VERSION})" \
    --text="A instalação/atualização do OS-SHIELD foi concluída com absoluto sucesso!\n\n1. O Daemon rodará a cada $CHOICE.\n2. Para abrir este painel de qualquer lugar, digite 'os-shield' no terminal." \
    --width=450

echo -e "${VERDE}--- INSTALAÇÃO FINALIZADA COM SUCESSO (${APP_VERSION}) ---${PADRAO}"
