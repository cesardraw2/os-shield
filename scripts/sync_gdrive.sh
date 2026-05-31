#!/bin/bash
# ==========================================================================
# SCRIPT: sync_gdrive.sh
# PROPÓSITO: Sincronização Cloud Agnóstica via Rclone
# ==========================================================================

# 1. IMPORTAÇÃO DINÂMICA DA CONFIGURAÇÃO CENTRAL
CONFIG_FILE="$(dirname "$0")/../configs/shield.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "\033[0;31m[X] Erro Crítico: Arquivo configs/shield.conf não encontrado!\033[0m"
    exit 1
fi

TOOLBOX_DIR="$HD_DESTINO/toolbox"

echo "=========================================================================="
echo "          INICIANDO BACKUP SEGURO DA TOOLBOX (CLOUD SYNC)                 "
echo "=========================================================================="

# Verifica se o rclone está instalado
if ! command -v rclone &> /dev/null; then
    echo -e "⚠️  rclone não encontrado no path do sistema. Instale com: sudo apt install rclone"
    exit 1
fi

echo -e "---> [PASSO ÚNICO] Sincronizando repositório local com a nuvem: $RCLONE_REMOTE"

# Executa o rclone de forma incremental e segura usando as variáveis globais
rclone sync "$TOOLBOX_DIR" "$RCLONE_REMOTE" \
    --exclude "logs/**" \
    --exclude "snapshots_config/**" \
    --verbose

if [ $? -eq 0 ]; then
    echo -e "✅ Sincronização com a nuvem concluída com sucesso!"
    mkdir -p "$TOOLBOX_DIR/logs"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cloud Sync OK" >> "$TOOLBOX_DIR/logs/sync.log"
else
    echo -e "❌ Erro durante a sincronização do rclone. Verifique suas credenciais e conexões."
fi

echo "=========================================================================="
