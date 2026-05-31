#!/bin/bash
# ==============================================================================
# SCRIPT: backup_incremental.sh
# PROPÓSITO: Sincronização segura Origem -> HD Novo
# ==============================================================================

ORIGEM="/mnt/raiz_pura/home/cesardraw"
DESTINO="/mnt/hd_novo"

# Validação dinâmica de segurança dos pontos de montagem
if ! mountpoint -q /mnt/hd_novo; then
    echo -e "\033[0;31m[X] Erro: O HD Novo não está montado em /mnt/hd_novo!\033[0m"
    exit 1
fi

echo -e "\033[1;32m[+] Disparando sincronização incremental segura...\033[0m"

# rsync calibrado com proteção contra deleção de links simbólicos lógicos
sudo rsync -aHAXxv --progress --del \
    --exclude="node_modules" \
    --exclude=".cache" \
    "$ORIGEM/toolbox/" "$DESTINO/toolbox/"

echo -e "\033[1;36m🏆 Sincronização da Toolbox concluída!\033[0m"
