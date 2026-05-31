#!/bin/bash
# ==============================================================================
# SCRIPT: homeshield_daemon.sh (SYS-05)
# PROPÓSITO: Daemon Resiliente de Monitoramento e Integridade do OS-SHIELD
# ==============================================================================

# TRAVA DE SEGURANÇA: Só executa se o Wizard de instalação concluiu com sucesso
if [ ! -f "$HOME/.os_shield_install_success" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [CRÍTICO] Daemon abortado! A instalação oficial do OS-SHIELD não foi concluída." >> "$(dirname "$0")/../logs/daemon_error.log"
    exit 1
fi
# 1. IMPORTAÇÃO DINÂMICA DA CONFIGURAÇÃO CENTRAL
CONFIG_FILE="$(dirname "$0")/../configs/shield.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "[X] Erro de configuração: shield.conf não encontrado." >> "$(dirname "$0")/../logs/daemon_error.log"
    exit 1
fi

LOG_FILE="$HD_DESTINO/toolbox/logs/homeshield.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Iniciando checagem de rotina do Shield..." >> "$LOG_FILE"

# 2. GUARDA DE SEGURANÇA: O PONTO DE MONTAGEM ESTÁ ATIVO?
if ! mountpoint -q "$HD_DESTINO"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [CRÍTICO] Armazenamento secundário em $HD_DESTINO não está montado! Abortando para proteger o SSD." >> "$LOG_FILE"
    exit 1
fi

# 3. CURA AUTOMÁTICA DA MALHA DE LINKS SIMBÓLICOS
# Garante que a lixeira de segurança existe
mkdir -p "$HD_DESTINO/trash"

for pasta in "${PASTAS_ALVO[@]}"; do
    ORIGEM="$HOME/$pasta"
    DESTINO="$HD_DESTINO/$pasta"

    # Se a pasta existe no HD, mas o link sumiu ou virou pasta comum na Home
    if [ -d "$DESTINO" ]; then
        if [ -d "$ORIGEM" ] && [ ! -L "$ORIGEM" ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [AVISO] Pasta física detectada na Home para '$pasta'. Movendo para o lixo seguro..." >> "$LOG_FILE"
            mv "$ORIGEM" "$HD_DESTINO/trash/${pasta}_daemon_$(date +%Y%m%d_%H%M%S)"
        fi

        if [ ! -L "$ORIGEM" ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [REPARO] Reconstruindo link simbólico corrompido para '$pasta'." >> "$LOG_FILE"
            ln -snf "$DESTINO" "$ORIGEM"
        fi
    fi
done

# 4. GOVERNANÇA AUTOMÁTICA DE PERMISSÕES
# Executa de forma silenciosa o corretor para manter o usuário dono dos seus dados
if [ -f "$(dirname "$0")/env_fix_permissions.sh" ]; then
    $(dirname "$0")/env_fix_permissions.sh > /dev/null 2>&1
fi

# 5. GOVERNANÇA PREDITIVA DE IA (JARVIS)
if [ -f "$(dirname "$0")/jarvis_governance.sh" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [JARVIS] Iniciando rastreio heurístico de Inteligência Artificial..." >> "$LOG_FILE"
    # Executa o Jarvis repassando todos os argumentos (como o --dry-run se houver)
    $(dirname "$0")/jarvis_governance.sh "$@" >> "$LOG_FILE" 2>&1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCESSO] Auditoria concluída. Sistema está íntegro e estável." >> "$LOG_FILE"
