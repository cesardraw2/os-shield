#!/bin/bash
# ==========================================================================
# SCRIPT: backup_fstab_links.sh
# PROPÓSITO: Snapshot de segurança dos Links Simbólicos e FSTAB
# ==========================================================================

# 1. IMPORTAÇÃO DINÂMICA DA CONFIGURAÇÃO CENTRAL
CONFIG_FILE="$(dirname "$0")/../configs/shield.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "\033[0;31m[X] Erro Crítico: Arquivo configs/shield.conf não encontrado!\033[0m"
    exit 1
fi

USER_HOME="$HOME"
BACKUP_DIR="$HD_DESTINO/toolbox/snapshots_config"

echo "=========================================================================="
echo "          INICIANDO SNAPSHOT DE SEGURANÇA DA CONFIGURAÇÃO                 "
echo "=========================================================================="

# Garante a existência da pasta de snapshots no HD secundário
sudo mkdir -p "$BACKUP_DIR"

# 2. FAZENDO BACKUP DO /etc/fstab
echo "---> [PASSO 1/2] Salvando imagem atual do /etc/fstab..."
sudo cp /etc/fstab "$BACKUP_DIR/fstab.bak"
echo "✅ Arquivo fstab espelhado em: $BACKUP_DIR/fstab.bak"

# 3. MAPEANDO LINKS SIMBÓLICOS ATIVOS NA HOME DE FORMA DINÂMICA
echo -e "\n---> [PASSO 2/2] Mapeando links simbólicos ativos na Home..."
LOG_LINKS="$BACKUP_DIR/links_ativos_snapshot.txt"

# Limpa o arquivo de log antigo se existir
sudo rm -f "$LOG_LINKS"

# Varre o array de pastas alvo que definimos no shield.conf para checar o status atual
for pasta in "${PASTAS_ALVO[@]}"; do
    LINK_LOCAL="$USER_HOME/$pasta"
    if [ -L "$LINK_LOCAL" ]; then
        ALVO=$(readlink -f "$LINK_LOCAL")
        echo "$LINK_LOCAL -> $ALVO" | sudo tee -a "$LOG_LINKS" > /dev/null
    fi
done

if [ -f "$LOG_LINKS" ]; then
    echo "✅ Snapshot os links simbólicos gerado com sucesso!"
    echo "📋 Relação salva em: $LOG_LINKS"
else
    echo "ℹ️  Nenhum link simbólico ativo foi detectado na Home atual para mapeamento."
fi

echo -e "\n=========================================================================="
echo "              SNAPSHOT DE CONTINGÊNCIA CONCLUÍDO COM SUCESSO!              "
echo "=========================================================================="
