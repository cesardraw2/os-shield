#!/bin/bash
# ==============================================================================
# JARVIS SRE: GOVERNANÇA PREDITIVA COM CACHE (v4.0)
# ==============================================================================

# Importação da Configuração Central
CONFIG_FILE="$(dirname "$0")/../configs/shield.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

HD_DESTINO="${HD_DESTINO:-/mnt/seu_hd_secundario}"
CACHE_SSD="$HOME/.jarvis_cache_ssd"
CACHE_HD="$HOME/.jarvis_cache_hd"
HITL_INBOX="$HOME/.jarvis_hitl_review.txt"
touch "$CACHE_SSD" "$CACHE_HD" "$HITL_INBOX"

# Cores para logs
VERDE="\033[0;32m"
CIANO="\033[0;36m"
AMARELO="\033[0;33m"
VERMELHO="\033[0;31m"
PADRAO="\033[0m"

echo -e "${CIANO}--- JARVIS SRE: ESCANEAMENTO DE ESTADO COM CACHE PREDITIVO ---${PADRAO}"

DRY_RUN=0
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=1
    echo -e "${AMARELO}[!] MODO DRY-RUN ATIVADO: Nenhuma alteração no disco será feita.${PADRAO}"
fi

# Função de IA
analisar_pasta_com_ia() {
     local pasta="$1"
     local prompt_base="Você é um Engenheiro SRE. Sua missão é manter a pasta /home enxuta com apenas o estritamente necessário para garantir alta performance, estabilidade do sistema e boot ultrarrápido. Diretórios genéricos (como 'teste'), projetos em desenvolvimento e mídias devem ser classificados como 'HD' para poupar o disco principal. Componentes vitais do Linux, dependências de boot e caches cruciais de sistema devem ser 'SSD'."
     
     # Injeção de Contexto (Few-Shot Prompting)
     local learning_file="$(dirname "$0")/../configs/jarvis_learning.txt"
     local prompt_learning=""
     if [ -f "$learning_file" ]; then
         prompt_learning=" Considere este histórico de aprendizado do administrador:\n$(grep -v '^#' "$learning_file")\n\n"
     fi

     local prompt_final="${prompt_base}\n${prompt_learning}Analise o diretório '$pasta' e responda APENAS com HD ou SSD."
     
     local resposta
     
     if ! resposta=$(timeout 15 ollama run qwen2.5-coder:1.5b "$prompt_final" 2>/dev/null); then
         echo "ssd" # Fallback de segurança se a IA estiver offline ou der timeout
         return
     fi
     
     echo "$resposta" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]'
}

# 1. Discovery: Busca diretórios na raiz (exclui ocultos e links simbólicos existentes)
cd "$HOME" || exit 1
find . -maxdepth 1 -type d -not -path '*/.*' -not -lname '*' | sed 's|^\./||' | while read -r pasta; do
    [ -z "$pasta" ] || [ "$pasta" == "." ] && continue
    
    # 2. Hard-Rules de Segurança (Proteção no SSD via Whitelist do shield.conf)
    is_whitelisted=0
    for whitelist_item in "${WHITELIST_SSD[@]}"; do
        if [ "$pasta" == "$whitelist_item" ]; then
            is_whitelisted=1
            break
        fi
    done
    
    if [ "$is_whitelisted" -eq 1 ]; then
        echo -e "${VERMELHO}[🔒 HARD-RULE] $pasta: Protegido na Whitelist (SSD).${PADRAO}"
        continue
    fi

    # 3. Check Cache
    if grep -Fxq "$pasta" "$CACHE_SSD"; then
        echo -e "${CIANO}[⚡ CACHE SSD] $pasta já validado para SSD. Pulando...${PADRAO}"
        continue
    elif grep -Fxq "$pasta" "$CACHE_HD"; then
        echo -e "${VERDE}[🚀 CACHE HD] $pasta validado para HD. Validando link...${PADRAO}"
    else
        # 4. Consulta IA (Miss no Cache)
        echo -e "${AMARELO}[?] Nova estrutura '$pasta' detectada. Consultando IA...${PADRAO}"
        decisao=$(analisar_pasta_com_ia "$pasta")

        if [ "$decisao" == "hd" ]; then
            if [ "$DRY_RUN" -eq 0 ]; then echo "$pasta" >> "$CACHE_HD"; fi
            echo -e "${VERDE}[+] Nova decisão (HD) salva no cache.${PADRAO}"
        else
            if [ "$DRY_RUN" -eq 0 ]; then 
                echo "$pasta" >> "$CACHE_SSD"
                # HITL Inbox: Envia para aprovação humana assíncrona
                if ! grep -Fxq "$pasta" "$HITL_INBOX"; then
                    echo "$pasta" >> "$HITL_INBOX"
                fi
            fi
            echo -e "${CIANO}[+] Decisão (SSD) temporária salva no cache. Enviado para HITL Review.${PADRAO}"
            continue
        fi
    fi

    # 5. Ação de Migração (Executada se decisão for HD)
    if [ "$DRY_RUN" -eq 1 ]; then
        echo -e "${AMARELO}[DRY-RUN] Migraria a pasta física '$pasta' para o HD e criaria o link simbólico.${PADRAO}"
    else
        mkdir -p "$HD_DESTINO/$pasta"
        if [ -d "$pasta" ] && [ ! -L "$pasta" ]; then
            echo -e "${CIANO}[*] Sincronizando $pasta via RSYNC...${PADRAO}"
            if rsync -av --ignore-errors "$pasta/" "$HD_DESTINO/$pasta/"; then
                rm -rf "$pasta"
                ln -s "$HD_DESTINO/$pasta" "$pasta"
                echo -e "${VERDE}[✅] Migração concluída com sucesso.${PADRAO}"
            else
                echo -e "${VERMELHO}[X] Erro na migração de $pasta.${PADRAO}"
            fi
        fi
    fi
done
