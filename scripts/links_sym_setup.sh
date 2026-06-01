#!/bin/bash
# ==============================================================================
# OS-SHIELD - HOMESHIELD DAEMON / LINKS SETUP
# ==============================================================================

APP_VERSION="v4.2.0"

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

# 2. TRAVA DE SEGURANÇA: Verifica se a instalação foi concluída
if [ "$1" != "--silent-install" ] && [ ! -f "$HOME/.os_shield_install_success" ]; then
    zenity --error --title="OS-SHIELD Não Instalado" \
        --text="O sistema de governança não foi inicializado corretamente!\n\nVocê precisa rodar o arquivo 'install.sh' (O Instalador Base) antes de acessar o Painel de Controle, para garantir a criação do Agendamento e das travas de segurança." \
        --width=450
    echo -e "${VERMELHO}[X] Acesso Negado: Instalação base pendente.${PADRAO}"
    exit 1
fi

echo -e "${VERDE}--- OS-SHIELD: INICIANDO PAINEL DE GOVERNANÇA ---${PADRAO}"

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

    CHOICE=$(zenity --list --radiolist --title="OS-SHIELD ${APP_VERSION} - Particionamento Avançado" \
        --column="Seleção" --column="Ferramenta" --column="Descrição" \
        "${OPTIONS[@]}" --width=600 --height=300)

    case "$CHOICE" in
        "GParted")
            zenity --info --text="Abrindo o GParted. O OS-SHIELD reoxigenará o mapa de discos assim que a ferramenta foi fechada." --width=400
            pkexec gparted
            ;;
        "CFdisk")
            zenity --info --text="Abrindo o CFdisk em uma nova janela isolada do Terminator." --width=400
            terminator --title="OS-SHIELD - CFdisk" -e "sudo cfdisk"
            ;;
        "Parted")
            zenity --info --text="Abrindo o GNU Parted em uma nova janela do Terminator." --width=400
            terminator --title="OS-SHIELD - GNU Parted" -e "sudo parted"
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
    OPTIONS+=(FALSE "OS-SHIELD Native Clean" "Limpeza direta e manual das pastas temporárias mapeadas na nossa arquitetura.")

    CHOICE=$(zenity --list --radiolist --title="OS-SHIELD ${APP_VERSION} - Limpeza e Otimização" \
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
        "OS-SHIELD Native Clean")
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
# Gerado Automaticamente pelo OS-SHIELD
logs/
snapshots_config/
scripts/tmp/
*.log
*.bak
INNER_EOF
    fi

    zenity --info --title="OS-SHIELD" --text="Estrutura de links e políticas de indexação (.trackerignore) atualizadas com sucesso!" --width=450
}

# ==============================================================================
# MÓDULO 4: HITL REVIEW - CURADORIA DE INTELIGÊNCIA ARTIFICIAL
# ==============================================================================
revisar_sugestoes_hitl() {
    local HITL_INBOX="$HOME/.jarvis_hitl_review.txt"
    local SHIELD_CONF="$(dirname "$0")/../configs/shield.conf"

    if [ ! -s "$HITL_INBOX" ]; then
        zenity --info --title="HITL Review" --text="A Caixa de Entrada está vazia.\nNão há sugestões pendentes da Inteligência Artificial no momento." --width=400
        return
    fi

    mapfile -t pastas_sugeridas < "$HITL_INBOX"
    
    local options=()
    for pasta in "${pastas_sugeridas[@]}"; do
        options+=(FALSE "$pasta" "Manter no SSD e proteger")
    done

    local escolhas=$(zenity --list --checklist --title="HITL Review - Decisões do Jarvis" \
        --text="A IA detectou essas novas pastas e julgou que pertencem ao SSD.\nSelecione quais você **aprova** para entrarem na Whitelist oficial:" \
        --column="Aprovar" --column="Pasta" --column="Ação" \
        "${options[@]}" --separator="|" --width=600 --height=400)

    if [ -n "$escolhas" ]; then
        IFS='|' read -ra aprovadas <<< "$escolhas"
        local adicionadas=0
        for aprovada in "${aprovadas[@]}"; do
            # Injeta a pasta aprovada dentro do array WHITELIST_SSD no shield.conf
            sed -i "/WHITELIST_SSD=(/a \    \"$aprovada\"" "$SHIELD_CONF"
            # Remove a linha aprovada da caixa de entrada
            sed -i "|^$aprovada$|d" "$HITL_INBOX"
            ((adicionadas++))
        done
        zenity --info --title="HITL Review Concluído" --text="$adicionadas pastas aprovadas e adicionadas à Whitelist!\nO Jarvis não tentará movê-las e elas estão protegidas no SSD." --width=450
    else
        zenity --info --title="Cancelado" --text="Nenhuma aprovação realizada." --width=300
    fi
}

# ==============================================================================
# MÓDULO 5: GESTÃO DE PASTAS PROTEGIDAS (WHITELIST MANUAL - LOOP CRUD)
# ==============================================================================
gerenciar_whitelist_manual() {
    local SHIELD_CONF="$(dirname "$0")/../configs/shield.conf"
    
    while true; do
        # 1. Extrair a lista atual do arquivo de configuração
        # Lemos tudo entre "WHITELIST_SSD=(" e ")" usando awk e limpamos aspas e espaços
        mapfile -t pastas_atuais < <(awk '/WHITELIST_SSD=\(\{/{flag=1; next} /\)/{flag=0} flag' "$SHIELD_CONF" | sed -e 's/^[[:space:]]*//' -e 's/"//g' | grep -v '^$')

        # 2. Se a lista estiver vazia (improvável devido às regras de base, mas por segurança)
        if [ ${#pastas_atuais[@]} -eq 0 ]; then
            zenity --info --title="OS-SHIELD ${APP_VERSION} - Whitelist Vazia" --text="Nenhuma pasta está protegida no momento." --width=300
            break
        fi

        # 3. Montar o menu do Zenity
        local acao=$(zenity --list --title="OS-SHIELD ${APP_VERSION} - Gestão de Pastas (Whitelist)" \
            --text="Pastas protegidas no SSD (O Jarvis não as migrará para o HD):\n\nSelecione uma para **Remover**, ou clique em **Adicionar Nova**." \
            --column="Pasta Blindada" "${pastas_atuais[@]}" \
            --extra-button="Adicionar Nova" --extra-button="Remover Selecionada" --ok-button="Voltar ao Painel" \
            --width=500 --height=400)
            
        local exit_code=$?
        
        # 4. Processamento da ação
        # Se o usuário clicar em Voltar ou Cancelar
        if [ $exit_code -eq 0 ] || [ $exit_code -eq 1 ]; then
            break
        fi

        # Se clicou em algum botão extra, a ação vem na variável de saída
        if [ "$acao" == "Adicionar Nova" ]; then
            local NOVA_PASTA=$(zenity --entry --title="Adicionar à Whitelist" \
                --text="Digite o nome EXATO do diretório na sua /home que deve ser protegido:\n(Ex: Projetos, Games, etc)" \
                --width=400)
            
            if [ -n "$NOVA_PASTA" ]; then
                # Sanitização de Segurança: Bloqueia injeção de código
                if [[ ! "$NOVA_PASTA" =~ ^[a-zA-Z0-9_\.\-]+$ ]]; then
                    zenity --error --title="Nome Inválido" --text="O nome da pasta contém caracteres especiais ou espaços não permitidos por questões de segurança.\nUse apenas letras, números, pontos ou traços." --width=400
                    continue
                fi
                
                # Valida se já existe
                if grep -q "\"$NOVA_PASTA\"" "$SHIELD_CONF"; then
                    zenity --error --title="Duplicidade" --text="A pasta '$NOVA_PASTA' já está protegida!" --width=350
                else
                    sed -i "/WHITELIST_SSD=(/a \    \"$NOVA_PASTA\"" "$SHIELD_CONF"
                fi
            fi
        elif [ "$acao" == "Remover Selecionada" ]; then
            # O Zenity list com custom buttons às vezes não preenche a variável $acao com o texto do botão
            # Mas envia o dado selecionado antes no stdin? Não, quando usa extra-button, 
            # a variável de retorno $acao contém exatamente o NOME do botão clicado.
            # O problema é que precisamos saber QUAL item foi selecionado na lista para remover!
            # Para resolver isso em bash nativo, pediremos pra digitar ou selecionar de outra forma.
            # Uma abordagem mais limpa com Zenity puro é abrir um novo checklist para remoção.
            local opcoes_del=()
            for p in "${pastas_atuais[@]}"; do
                opcoes_del+=(FALSE "$p")
            done
            
            local excluir=$(zenity --list --checklist --title="Remover Proteção" \
                --text="Selecione as pastas que deseja remover da Whitelist (elas ficarão expostas à IA no próximo ciclo):" \
                --column="Remover" --column="Pasta" \
                "${opcoes_del[@]}" --separator="|" --width=450 --height=350)
                
            if [ -n "$excluir" ]; then
                IFS='|' read -ra itens_excluir <<< "$excluir"
                for item in "${itens_excluir[@]}"; do
                    # Exclui a linha exata contendo a string no shield.conf
                    sed -i "/^[[:space:]]*\"$item\"[[:space:]]*$/d" "$SHIELD_CONF"
                done
            fi
        fi
    done
}

# ==============================================================================
# MÓDULO 6: TREINAMENTO DA IA (FEW-SHOT LEARNING)
# ==============================================================================
treinar_inteligencia_artificial() {
    local LEARNING_FILE="$(dirname "$0")/../configs/jarvis_learning.txt"
    
    if [ ! -f "$LEARNING_FILE" ]; then
        touch "$LEARNING_FILE"
    fi
    
    local NOVO_CONTEUDO
    NOVO_CONTEUDO=$(zenity --text-info --title="OS-SHIELD ${APP_VERSION} - Treinamento da IA" \
        --filename="$LEARNING_FILE" --editable --width=700 --height=500)
        
    # Verifica se o usuário apertou OK (exit status 0)
    if [ $? -eq 0 ]; then
        echo "$NOVO_CONTEUDO" > "$LEARNING_FILE"
        zenity --info --title="Treinamento Salvo" --text="A 'Memória' do Jarvis foi atualizada com sucesso!\nA Inteligência Artificial passará a ler esse arquivo antes de julgar qualquer nova pasta." --width=400
    fi
}

# ==============================================================================
# MÓDULO 7: BACKUP E SNAPSHOT (RSYNC)
# ==============================================================================
executar_snapshot_home() {
    local SHIELD_CONF="$(dirname "$0")/../configs/shield.conf"
    source "$SHIELD_CONF"
    
    if [ -z "$BACKUP_DESTINATION" ] || [ ! -d "$BACKUP_DESTINATION" ]; then
        zenity --error --title="Destino Inválido" --text="O diretório de backup não foi configurado ou não existe.\nVerifique a variável BACKUP_DESTINATION no arquivo shield.conf." --width=400
        return
    fi
    
    zenity --question --title="Confirmação de Snapshot" --text="Deseja iniciar o backup estrutural da sua Home agora?\nDestino: $BACKUP_DESTINATION\n\n(Links simbólicos e pastas ocultas pesadas serão ignoradas para máxima performance)." --width=450
    if [ $? -eq 0 ]; then
        # Usa o rsync ignorando arquivos ocultos .* e não seguindo symlinks (-l implícito em -a)
        rsync -a --exclude=".*" "$HOME/" "$BACKUP_DESTINATION/OS_SHIELD_HOME_SNAPSHOT/" | \
            zenity --progress --title="OS-SHIELD ${APP_VERSION} - Snapshot Rsync" \
            --text="Sincronizando arquivos estruturais do SSD...\nAguarde a conclusão." \
            --pulsate --auto-close --no-cancel || zenity --error --text="Erro durante o backup!"
            
        zenity --info --title="Snapshot Concluído" --text="Backup finalizado com sucesso em:\n$BACKUP_DESTINATION/OS_SHIELD_HOME_SNAPSHOT/" --width=400
    fi
}

# ==============================================================================
# MODO HEADLESS (PARA O INSTALADOR)
# ==============================================================================
if [ "$1" == "--silent-install" ]; then
    echo -e "${CIANO}[*] Rodando em modo de instalação silenciosa...${PADRAO}"
    consolidar_links_simbolicos
    exit 0
fi

# ==============================================================================
# INTERFACE PRINCIPAL - LOOP DO MENU ZENITY
# ==============================================================================
while true; do
    MAIN_CHOICE=$(zenity --list --title="OS-SHIELD ${APP_VERSION} - Control Center" \
        --column="Código" --column="Ação do Sistema" \
        "1" "Consolidar Malha de Links e Filtros do Tracker" \
        "2" "Central de Limpeza e Otimização (BleachBit / Caches)" \
        "3" "Revisar Sugestões da IA (HITL Review)" \
        "4" "Gerenciar Pastas Protegidas (Whitelist Manual)" \
        "5" "Treinar Inteligência Artificial (Memória)" \
        "6" "Configurar Agendamento do Daemon (Timer)" \
        "7" "Criar Snapshot da Home (Backup Rsync)" \
        "8" "Particionamento Avançado de Hardware (GParted / Auxiliares)" \
        "9" "Sair do Painel" \
        --width=650 --height=450 --hide-column=1)

    case "$MAIN_CHOICE" in
        "1")
            consolidar_links_simbolicos
            ;;
        "2")
            executar_limpeza_caches
            ;;
        "3")
            revisar_sugestoes_hitl
            ;;
        "4")
            gerenciar_whitelist_manual
            ;;
        "5")
            treinar_inteligencia_artificial
            ;;
        "6")
            "$(dirname "$0")/../install.sh" --reconfigure-timer
            ;;
        "7")
            executar_snapshot_home
            ;;
        "8")
            abrir_particionador_avancado
            ;;
        "9"|"")
            echo -e "${CIANO}[*] Fechando o Painel de Controle OS-SHIELD. Até a próxima!${PADRAO}"
            break
            ;;
    esac
done
