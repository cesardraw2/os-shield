#!/bin/bash
# ==============================================================================
# OS-SHIELD UNINSTALLER (Rollback Seguro)
# ==============================================================================
set -e

# Cores
VERDE="\033[0;32m"
CIANO="\033[0;36m"
VERMELHO="\033[0;31m"
PADRAO="\033[0m"

echo -e "${CIANO}--- INICIANDO DESINSTALAÇÃO DO OS-SHIELD ---${PADRAO}"
echo -e "${VERMELHO}Aviso: Isso removerá as travas de segurança e o Daemon do sistema.${PADRAO}"
echo -e "${VERMELHO}Os seus arquivos físicos no HD secundário NÃO serão apagados.${PADRAO}"

read -p "Tem certeza que deseja desinstalar o OS-SHIELD? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Desinstalação abortada."
    exit 0
fi

# 1. Parando os serviços do Systemd
echo -e "${CIANO}[*] Desativando e removendo Daemons...${PADRAO}"
if systemctl --user is-active --quiet homeshield.timer; then
    systemctl --user disable --now homeshield.timer
fi
rm -f "$HOME/.config/systemd/user/homeshield.timer"
rm -f "$HOME/.config/systemd/user/homeshield.service"
systemctl --user daemon-reload

# 2. Removendo as variáveis e aliases do bashrc
echo -e "${CIANO}[*] Limpando arquivos de configuração do terminal...${PADRAO}"
if grep -q "# OS-SHIELD Control Center" "$HOME/.bashrc"; then
    sed -i '/# OS-SHIELD Control Center/d' "$HOME/.bashrc"
    sed -i '/alias os-shield=/d' "$HOME/.bashrc"
fi

# 3. Removendo a flag de instalação
echo -e "${CIANO}[*] Removendo trava de instalação...${PADRAO}"
rm -f "$HOME/.os_shield_install_success"

echo -e "${VERDE}--- DESINSTALAÇÃO CONCLUÍDA ---${PADRAO}"
echo -e "O OS-SHIELD foi desativado. Para reativá-lo no futuro, basta executar o 'make install'."
