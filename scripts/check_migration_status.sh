#!/bin/bash
# ==============================================================================
# SCRIPT: check_migration_status.sh
# PROPÓSITO: Painel Dinâmico de Integridade e Sincronização da Home
# ==============================================================================

# Cores para o relatório
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

clear
echo -e "${CIANO}==================================================================${PADRAO}"
echo -e "${VERDE}📦 ANTIGRAVITY OS-SHIELD - PAINEL DE INTEGRIDADE DOS DISCOS${PADRAO}"
echo -e "${CIANO}==================================================================${PADRAO}"

# 2. Diagnóstico Geral de Espaço
TAMANHO_HOME_ATUAL=$(du -sh ~ 2>/dev/null | cut -f1)
ESPACO_HD_NOVO=$(df -h "$HD_DESTINO" | tail -n 1 | awk '{print $3 " ocupados de " $2}')

echo -e "${CIANO}📦 Tamanho total remanescente na Home (SSD):${PADRAO} $TAMANHO_HOME_ATUAL"
echo -e "${CIANO}💾 Armazenamento consumido no HD Secundário:${PADRAO} $ESPACO_HD_NOVO"
echo ""
echo -e "${AMARELO}---> [STATUS DE COBERTURA DOS LINKS SIMBÓLICOS]${PADRAO}"

# 3. Varredura Focada no Array de Configuração
for pasta in "${PASTAS_ALVO[@]}"; do
    CAMINHO_HOME="$HOME/$pasta"
    CAMINHO_HD="$HD_DESTINO/$pasta"

    # Cenário A: O Link Simbólico está de pé e saudável
    if [ -L "$CAMINHO_HOME" ]; then
        alvo_link=$(readlink "$CAMINHO_HOME")
        echo -e "${VERDE}✅ [$pasta]${PADRAO} -> Link Consolidado (Aponta para: $alvo_link)"
        continue
    fi

    # Cenário B: Pasta ainda é física no SSD, mas já existe cópia no HD
    if [ -d "$CAMINHO_HD" ] && [ -d "$CAMINHO_HOME" ]; then
        arquivos_ssd=$(find "$CAMINHO_HOME" -type f 2>/dev/null | wc -l)
        arquivos_hd=$(find "$CAMINHO_HD" -type f 2>/dev/null | wc -l)
        
        bytes_ssd=$(du -sb "$CAMINHO_HOME" 2>/dev/null | cut -f1)
        bytes_hd=$(du -sb "$CAMINHO_HD" 2>/dev/null | cut -f1)

        bytes_ssd=${bytes_ssd:-0}
        bytes_hd=${bytes_hd:-0}

        # Proteção contra pastas vazias residuais de 4KB no SSD
        if [ "$bytes_hd" -e 0 ] && [ "$bytes_ssd" -le 4096 ]; then
            echo -e "${VERDE}✅ [$pasta]${PADRAO} -> Sincronizado no HD. Pronto para rodar o link setup!"
        elif [ "$bytes_ssd" -eq "$bytes_hd" ] && [ "$arquivos_ssd" -eq "$arquivos_hd" ]; then
            echo -e "${VERDE}✅ [$pasta]${PADRAO} -> Sincronizado no HD. Pronto para rodar o link setup!"
        else
            if [ "$bytes_ssd" -le "$bytes_hd" ] || [ "$bytes_ssd" -eq 0 ]; then
                percentual=99
            else
                percentual=$(( (bytes_hd * 100) / bytes_ssd ))
            fi
            
            if [ "$percentual" -gt 100 ]; then percentual=99; fi
            echo -e "${AMARELO}⏳ [$pasta]${PADRAO} -> Sincronização Desalinhada (${percentual}% correspondente | SSD: $arquivos_ssd arq vs HD: $arquivos_hd arq)"
        fi
        continue
    fi

    # Cenário C: A pasta existe no SSD mas o HD nunca viu ela (Inédita ou Nova)
    if [ -d "$CAMINHO_HOME" ] && [ ! -d "$CAMINHO_HD" ]; then
        tamanho_pendente=$(du -sh "$CAMINHO_HOME" 2>/dev/null | cut -f1)
        echo -e "${VERMELHO}💤 [$pasta]${PADRAO} -> Pasta física exclusiva no SSD ($tamanho_pendente acumulados | Precisa ser migrada)"
    fi
done

echo -e "${CIANO}==================================================================${PADRAO}"
