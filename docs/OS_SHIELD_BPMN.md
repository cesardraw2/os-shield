# Arquitetura Operacional do OS-SHIELD (BPMN)

Diagrama gerado automaticamente a partir das documentações BDD (FOS001 a FOS006) seguindo as diretrizes do **Jarvis Claw Gold Standard**.

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'fontFamily': 'Inter'}}}%%
flowchart TD
    %% Piscinas e Raias (Swimlanes)
    subgraph Admin [Swimlane: Administrador do Sistema]
        START((Início))
        GUI_PANEL(Abre o Painel Zenity / os-shield)
        HITL_REVIEW(Revisa Sugestões HITL)
        EDIT_WHITELIST(Edita a Whitelist)
        EDIT_MEMORY(Treina a Memória da IA)
        MANUAL_BACKUP(Dispara Backup Manual Rsync)
    end

    subgraph Daemon [Swimlane: Systemd Daemon]
        TIMER{Timer de 15 min}
        CHK_MOUNT{O HD está montado?}
        CHK_ORPHANS(Procura Pastas Órfãs no SSD)
        FIX_PERM(Força Permissões chown)
        AUTO_BACKUP(Dispara Backup Automático)
    end

    subgraph Jarvis [Swimlane: Jarvis SRE / Ollama]
        AI_ENGINE[[Motor de Inferência Ollama]]
        ANALYZE_DIR(Analisa Diretório Desconhecido)
        READ_MEMORY(Lê jarvis_learning.txt)
    end

    %% Fluxo do Administrador (UI)
    START --> GUI_PANEL
    
    GUI_PANEL --> |Opção 3| HITL_REVIEW
    GUI_PANEL --> |Opção 4| EDIT_WHITELIST
    GUI_PANEL --> |Opção 5| EDIT_MEMORY
    GUI_PANEL --> |Opção 6| AUTO_BACKUP
    GUI_PANEL --> |Opção 7| MANUAL_BACKUP

    %% Fluxo de Governança Híbrida (HITL + IA)
    EDIT_MEMORY -.-> |"Atualiza Contexto"| READ_MEMORY
    HITL_REVIEW -.-> |"Aprova Migração"| CHK_ORPHANS

    %% Fluxo do Daemon (Background)
    TIMER --> CHK_MOUNT
    CHK_MOUNT -- Não --> ABORT((Abortar Missão))
    CHK_MOUNT -- Sim --> CHK_ORPHANS
    
    CHK_ORPHANS --> |"Encontrou anomalias"| FIX_PERM
    CHK_ORPHANS --> |"Nova pasta descoberta"| ANALYZE_DIR
    
    ANALYZE_DIR --> READ_MEMORY
    READ_MEMORY --> AI_ENGINE
    AI_ENGINE --> |"Decisão: HD"| HITL_REVIEW
    AI_ENGINE --> |"Decisão: SSD"| IGNORE((Ignorar e Manter))
    
    FIX_PERM --> LOG_SUCCESS((Log e Fim))
    MANUAL_BACKUP --> LOG_SUCCESS
    AUTO_BACKUP --> LOG_SUCCESS
```

### 📋 Mapeamento de Padrões Industriais
1. **`<bpmn:userTask>` (HITL):** Etapas como `Revisa Sugestões HITL` e `Edita a Whitelist` aguardam intervenção humana.
2. **`<bpmn:callActivity>` (Macro-Fluxos):** `Motor de Inferência Ollama` invoca um binário/rede neural externa.
3. **`<bpmn:parallelGateway>` (Paralelismo):** O `Systemd Daemon` e o `Painel Zenity` rodam em raias assíncronas totalmente isoladas.
