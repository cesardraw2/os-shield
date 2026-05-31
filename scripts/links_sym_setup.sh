#!/bin/bash
# ==============================================================================
# ANTIGRAVITY OS-SHIELD - HOMESHIELD DAEMON / LINKS SETUP (v2.1-OpenSource)
# ==============================================================================

# Cores para logs no terminal
VERDE="\033[0;32m"
CIANO="\033[0;36m"
AMARELO="\033[0;33m"
VERMELHO="\033[0;31m"
PADRAO="\033[0m"

# 1. IMPORTAÇÃO DINÂMICA DA CONFIGURAÇÃO CENTRAL
CONFIG_FILE="$(dirname "$0")/../configs/shield.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "${VERMELHO}[X] Erro Crítico: Arquivo configs/shield.conf não encontrado!${PADRAO}"
    exit 1
fi

echo -e "${VERDE}--- ANTIGRAVITY OS-SHIELD: INICIANDO PAINEL DE GOVERNANÇA ---${PADRAO}"

# ==============================================================================
# MÓDULO 1: SELEÇÃO DE PARTICIONAMENTO AVANÇADO
# ==============================================================================
abrir_particionador_avancado() {
    OPTIONS=()
    if command -v gparted &> /dev/null; then
        OPTIONS+=(TRUE "GParted" "Interface gráfica completa para gerenciar partições (Recomendado)")
    fi
    if command -v cfdisk &> /dev/null; then
        OPTIONS+=(FALSE "CFdisk" "Interface de terminal simplificada e rápida (Ncurses)")
    fi
    if command -v parted &> /dev/null; then
        OPTIONS+=(FALSE "Parted" "Linha de comando clássica e direta do GNU")
    fi

    if [ ${#OPTIONS[@]} -eq 0 ]; then
        zenity --error --title="Erro de Dependência" \
            --text="Nenhuma ferramenta de particionamento foi encontrada no sistema." --width=400
        return 1
    fi

    CHOICE=$(zenity --list --radiolist --title="Antigravity OS - Particionamento Avançado" \
        --column="Seleção" --column="Ferramenta" --column="Descrição" \
        "${OPTIONS[@]}" --width=600 --height=300)

    case "$CHOICE" in
        "GParted")
            zenity --info --text="Abrindo o GParted. O Antigravity OS reoxigenará o mapa de discos assim que a ferramenta foi fechada." --width=400
            pkexec gparted
            ;;
        "CFdisk")
            zenity --info --text="Abrindo o CFdisk em uma nova janela isolada do Terminator." --width=400
            terminator --title="Antigravity OS - CFdisk" -e "sudo cfdisk"
            ;;
        "Parted")
            zenity --info --text="Abrindo o GNU Parted em uma nova janela do Terminator." --width=400
            terminator --title="Antigravity OS - GNU Parted" -e "sudo parted"
            ;;
        *)
            echo -e "${AMARELO}[!] Operação de particionamento cancelada pelo usuário.${PADRAO}"
            ;;
    esac
}

# ==============================================================================
# MÓDULO 2: CENTRAL DE LIMPEZA E OTIMIZAÇÃO
# ==============================================================================
executar_limpeza_caches() {
    OPTIONS=()
    if command -v bleachbit &> /dev/null; then
        OPTIONS+=(TRUE "BleachBit (GUI)" "Interface completa do BleachBit. Limpa navegadores, Telegram e logs antigos.")
        OPTIONS+=(FALSE "BleachBit (CLI Rápido)" "Limpeza silenciosa via terminal dos maiores vilões de cache do sistema.")
    fi
    OPTIONS+=(FALSE "Antigravity Native Clean" "Limpeza direta e manual das pastas temporárias mapeadas na nossa arquitetura.")

    CHOICE=$(zenity --list --radiolist --title="Antigravity OS - Central de Limpeza e Otimização" \
        --column="Seleção" --column="Método" --column="Descrição" \
        "${OPTIONS[@]}" --width=650 --height=300)

    case "$CHOICE" in
        "BleachBit (GUI)")
            bleachbit
            ;;
        "BleachBit (CLI Rápido)")
            zenity --info --text="Iniciando a trituração de caches em background via BleachBit CLI. Limpando a sujeira..." --width=400 --timeout=2
            bleachbit --clean system.cache system.tmp deepscan.thumbs chromium.cache browser.cache
            zenity --info --text="Limpeza via BleachBit CLI concluída com sucesso!" --width=300
            ;;
        "Antigravity Native Clean")
            if zenity --question --title="Confirmação de Faxina" \
                --text="Deseja apagar os caches de mídia do Telegram e navegadores de forma nativa? (Suas contas NÃO serão deslogadas)" --width=400; then
                
                echo -e "${CIANO}[*] Executando limpeza cirúrgica nas sandboxes...${PADRAO}"
                rm -rf ~/.var/app/org.telegram.desktop/cache/data/*
                rm -rf ~/.var/app/com.brave.Browser/cache/*
                
                zenity --info --text="Caches nativos triturados com sucesso! Sua /home agradece." --width=300
            fi
            ;;
        *)
            echo -e "${AMARELO}[!] Operação de limpeza cancelada.${PADRAO}"
            ;;
    esac
}

# ==============================================================================
# MÓDULO 3: GERENCIADOR E AMARRAÇÃO DE LINKS SIMBÓLICOS (DINÂMICO + PROTETOR)
# ==============================================================================
consolidar_links_simbolicos() {
    echo -e "${CIANO}[*] Verificando integridade e criando links simbólicos...${PADRAO}"
    
    # Garante que a pasta de lixeira segura existe no HD destino
    mkdir -p "$HD_DESTINO/trash"

    # Itera sobre o array definido dinamicamente no shield.conf
    for pasta in "${PASTAS_ALVO[@]}"; do
        CAMINHO_ORIGEM="$HOME/$pasta"
        CAMINHO_DESTINO="$HD_DESTINO/$pasta"

        if [ -d "$CAMINHO_DESTINO" ]; then
            # Se a pasta física ainda existe no SSD da Home (e não for um link), joga pra lixeira segura
            if [ -d "$CAMINHO_ORIGEM" ] && [ ! -L "$CAMINHO_ORIGEM" ]; then
                echo -e "${AMARELO}[!] Movendo diretório físico residual do SSD para o trash do HD: $pasta${PADRAO}"
                mv "$CAMINHO_ORIGEM" "$HD_DESTINO/trash/${pasta}_$(date +%Y%m%d_%H%M%S)"
            fi

            # Cria ou repara o link simbólico de forma atômica
            if [ ! -L "$CAMINHO_ORIGEM" ]; then
                echo -e "${VERDE}[+] Amarrando Link Simbólico: $CAMINHO_ORIGEM -> $CAMINHO_DESTINO${PADRAO}"
                ln -s "$CAMINHO_DESTINO" "$CAMINHO_ORIGEM"
            else
                echo -e "${VERDE}✅ Link já consolidado para: $pasta${PADRAO}"
            fi
        else
            echo -e "${VERMELHO}[X] Alerta: Pasta $pasta não foi encontrada no HD de Destino ($HD_DESTINO).${PADRAO}"
        fi
    done

    # ==========================================================================
    # SISTEMA DE GOVERNANÇA INTEGRADO: INJEÇÃO AUTOMÁTICA DE .trackerignore
    # ==========================================================================
    echo -e "${CIANO}[*] Injetando escudos protetores contra indexação mecânica (.trackerignore)...${PADRAO}"
    
    # Proteção da pasta de Desenvolvimento
    if [ -d "$HD_DESTINO/desenv" ]; then
        cat << 'INNER_EOF' > "$HD_DESTINO/desenv/.trackerignore"
# Gerado Automaticamente pelo Antigravity OS-SHIELD
node_modules/
.venv/
venv/
target/
dist/
build/
.angular/
INNER_EOF
    fi

    # Proteção da própria Toolbox
    if [ -d "$HD_DESTINO/toolbox" ]; then
        cat << 'INNER_EOF' > "$HD_DESTINO/toolbox/.trackerignore"
# Gerado Automaticamente pelo Antigravity OS-SHIELD
logs/
snapshots_config/
scripts/tmp/
*.log
*.bak
INNER_EOF
    fi

    zenity --info --title="Antigravity OS" --text="Estrutura de links e políticas de indexação (.trackerignore) atualizadas com sucesso!" --width=450
}

# ==============================================================================
# INTERFACE PRINCIPAL - LOOP DO MENU ZENITY
# ==============================================================================
while true; do
    MAIN_CHOICE=$(zenity --list --title="Antigravity OS - HomeShield Control Center" \
        --column="Código" --column="Ação do Sistema" \
        "1" "Consolidar Malha de Links e Filtros do Tracker" \
        "2" "Central de Limpeza e Otimização (BleachBit / Caches)" \
        "3" "Particionamento Avançado de Hardware (GParted / Auxiliares)" \
        "4" "Sair do Painel" \
        --width=500 --height=350 --hide-column=1)

    case "$MAIN_CHOICE" in
        "1")
            consolidar_links_simbolicos
            ;;
        "2")
            executar_limpeza_caches
            ;;
        "3")
            abrir_particionador_avancado
            ;;
        "4"|"")
            echo -e "${CIANO}[*] Fechando o Painel de Controle Antigravity OS. Até a próxima!${PADRAO}"
            break
            ;;
    esac
done
