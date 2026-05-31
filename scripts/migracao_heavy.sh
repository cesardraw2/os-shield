#!/bin/bash

# Define as origens e destinos com base nas nossas montagens
ORIGEM="/mnt/hd_antigo/cesardraw"
DESTINO="/mnt/hd_novo"

echo "=========================================================================="
echo " INICIANDO O SCRIPT DE MIGRAÇÃO EM LOTES - PRIORIZANDO DIRETÓRIOS PESADOS "
echo "=========================================================================="

# --------------------------------------------------------------------------
# LOTE 1: OS GRANDES VILÕES (Ambientes Brutos, SDKs e Caches Globais de Dev)
# --------------------------------------------------------------------------
echo -e "\n---> [LOTE 1/3] Copiando ambientes brutos, SDKs e caches globais..."
sudo rsync -avh --progress \
    "$ORIGEM/desenv" \
    "$ORIGEM/tools" \
    "$ORIGEM/Android" \
    "$ORIGEM/.android" \
    "$ORIGEM/.gemini" \
    "$ORIGEM/.npm" \
    "$ORIGEM/.nvm" \
    "$ORIGEM/.verdaccio-storage" \
    "$DESTINO/"

# --------------------------------------------------------------------------
# LOTE 2: DIRETÓRIOS CUSTOMIZADOS (Projetos Isolados, Ecossistemas e IA)
# --------------------------------------------------------------------------
echo -e "\n---> [LOTE 2/3] Copiando diretórios customizados e ecossistemas..."
sudo rsync -avh --progress \
    "$ORIGEM/JarvisProject" \
    "$ORIGEM/mycroft-core" \
    "$ORIGEM/dyad-apps" \
    "$ORIGEM/dyad-apps-temp" \
    "$ORIGEM/go" \
    "$ORIGEM/.gradle" \
    "$ORIGEM/.var" \
    "$ORIGEM/.antigravity" \
    "$ORIGEM/.antigravity-ide" \
    "$ORIGEM/.jdks" \
    "$ORIGEM/.hermes" \
    "$ORIGEM/.PlayOnLinux" \
    "$ORIGEM/.arduino15" \
    "$ORIGEM/games" \
    "$ORIGEM/cursos" \
    "$ORIGEM/.opencode" \
    "$ORIGEM/.m2" \
    "$ORIGEM/.ollamassist" \
    "$ORIGEM/artes" \
    "$ORIGEM/.bun" \
    "$ORIGEM/antigravity-backup" \
    "$ORIGEM/.agent_skills" \
    "$DESTINO/"

# --------------------------------------------------------------------------
# LOTE 3: MÍDIAS E DIRETÓRIOS DE SISTEMA LOCAIS (Cache e Local pesados)
# --------------------------------------------------------------------------
echo -e "\n---> [LOTE 3/3] Copiando mídias pesadas e pastas de dados locais..."
sudo mkdir -p "$DESTINO/pesados/cache" "$DESTINO/pesados/local"

sudo rsync -avh --progress "$ORIGEM/Vídeos" "$ORIGEM/Imagens" "$ORIGEM/Downloads" "$DESTINO/"
sudo rsync -avh --progress "$ORIGEM/.cache/" "$DESTINO/pesados/cache/"
sudo rsync -avh --progress "$ORIGEM/.local/" "$DESTINO/pesados/local/"

echo -e "\n=========================================================================="
echo "      MIGRACÃO DOS DIRETÓRIOS CONCLUÍDA COM SUCESSO NO SEU HD NOVO!       "
echo "=========================================================================="
