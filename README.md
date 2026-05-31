# 🛠️ OS-SHIELD (Antigravity HomeShield)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash Shell](https://img.shields.io/badge/shell-bash-4eed1c.svg)](https://www.gnu.org/software/bash/)

O **OS-SHIELD** é um canivete suíço de infraestrutura local projetado para manter a sua `/home` ultra-leve, estendendo a vida útil e economizando espaço precioso do seu SSD principal (NVMe). Ele cria uma malha logística de links simbólicos e um Daemon resiliente do Systemd que gerencia o fluxo de dados em background para um HD secundário de forma transparente.

Ideal para System Architects, Desenvolvedores Full-Stack e usuários Linux que lidam com caches massivos de desenvolvimento (`node_modules`, Android SDKs, caches de IA locais) em máquinas com armazenamento SSD limitado.

---

## 🏗️ Arquitetura do Sistema

O projeto intercepta e isola pastas de alta taxa de escrita do SSD, movendo os blocos brutos para o HD mecânico e ancorando links lógicos na Home.

```mermaid
sequenceDiagram
    participant Admin as Usuário
    participant Setup as "links_sym_setup.sh"
    participant Timer as "homeshield.timer"
    participant Daemon as "homeshield_daemon.sh"
    participant Perms as "env_fix_permissions.sh"
    participant Jarvis as "jarvis_governance_test.sh"
    participant Ollama as "Ollama (Qwen)"
    participant SSD as "SSD (/home)"
    participant HD as "HD Secundário"
    
    %% Fase de Carga Inicial
    Admin->>Setup: Executa carga inicial (Manual)
    activate Setup
    Setup->>SSD: Ancoragem dos links simbólicos
    Setup->>HD: Protege pastas com .trackerignore
    Setup-->>Admin: Concluído
    deactivate Setup

    %% Fase do Daemon (Automática)
    Note over Timer, HD: Ciclo de Autocura (A cada 15 min)
    Timer->>Daemon: Dispara via homeshield.service
    activate Daemon
    Daemon->>HD: Verifica Mountpoint do HD
    alt HD Não Montado
        Daemon-->>Timer: Aborta e Protege SSD
    else HD Montado
        loop Para cada Pasta Alvo
            Daemon->>SSD: Checa estado do Link Simbólico
            alt Encontrou Pasta Física (Anomalia)
                Daemon->>HD: Faz backup seguro para /trash/
                Daemon->>SSD: Remove a pasta física invasora
                Daemon->>SSD: Amarra novo Link (SSD -> HD)
            else Link Saudável
                Daemon->>Daemon: Valida e prossegue
            end
        end
        Daemon->>Perms: Dispara script de Governança
        activate Perms
        Perms->>SSD: Força permissões (chown user:user)
        Perms-->>Daemon: Retorna Sucesso
        deactivate Perms
        Daemon->>HD: Registra Log de Sucesso (homeshield.log)
    end
    deactivate Daemon

    %% Fase Preditiva (Standalone / Manual)
    Note over Admin, Ollama: Exploração e Decisão via IA (Sob Demanda)
    Admin->>Jarvis: Aciona governança preditiva
    activate Jarvis
    Jarvis->>SSD: Mapeia novos diretórios na Home
    loop Para cada Nova Pasta
        Jarvis->>Ollama: Prompt: "Analise a pasta. HD ou SSD?"
        Ollama-->>Jarvis: Responde (Classificação)
        alt Decisão = HD
            Jarvis->>HD: Migra via rsync e amarra Link
        else Decisão = SSD
            Jarvis->>Jarvis: Mantém no SSD (Salva no Cache)
        end
    end
    Jarvis-->>Admin: Relatório Preditivo Concluído
    deactivate Jarvis
```

* **Modo Atômico**: Proteção contra perda de dados. Se uma pasta física ressurgir na Home, o sistema faz o pivô seguro enviando os resíduos para uma lixeira controlada (`/trash/`) antes de amarrar o link.
* **Resiliência de Daemon**: Um par de serviços do Systemd (`.service` + `.timer`) roda de forma silenciosa a cada 15 minutos para garantir que a sua Home nunca seja corrompida por atualizações do sistema ou resets de snapshots (como Timeshift).


---

## 📁 Estrutura de Diretórios do Repositório

```text
.
├── configs/          # Configurações globais e fstab centralizados
├── daemon_state/     # Unidades de serviço do Systemd (Instalação local)
├── docs/             # Manifesto de IA (AGENTS.md) e runbooks de engenharia
└── scripts/          # Motores Bash modulares e utilitários de cura
```

## 🚀 Instalação e Instanciação Rápida

### 1. Clonar o Repositório
Clone esta caixa de ferramentas dentro da partição do seu HD secundário montado:

```bash
cd /mnt/seu_hd_secundario
git clone https://github.com/seu-usuario/os-shield.git toolbox
cd toolbox
```

### 2. Configurar Variáveis de Ambiente
Abra o arquivo de propriedades e ajuste os caminhos para bater com o seu usuário e ponto de montagem do HD:

```bash
nano configs/shield.conf
```

### 3. Executar o Instalador Gráfico (Wizard)
O novo OS-SHIELD v4 possui um instalador inteligente. Ele configurará o agendamento no seu *User Space* (sem precisar de sudo), definirá o alias global e fará o primeiro backup de segurança:

```bash
./install.sh
```

A partir desse momento, basta digitar `os-shield` em qualquer terminal para abrir a **Central de Controle Zenity**.

## 🛡️ Funcionalidades Avançadas (Painel de Controle)
Digitando `os-shield`, você tem acesso às seguintes ferramentas nativas:
- **Gestão de Whitelist:** Adicione ou remova pastas do SSD através de uma interface interativa (CRUD Completo).
- **Few-Shot Learning (IA):** "Ensine" o modelo de IA sobre suas preferências através de um editor de texto injetado diretamente no prompt, sem precisar de *fine-tuning*.
- **Snapshots de Resiliência:** Execute backups ultra-rápidos e estruturais da sua Home via Rsync ignorando links pesados, mantendo sempre uma cópia salva na lixeira segura.

## 🤖 AI-Agent Readiness (Manifesto de Cooperação)
Se você é um Agente de IA (Cursor, Jarvis, Claude, ChatGPT) operando ou estendendo esta toolbox, você deve ler rigorosamente as instruções contidas em docs/AGENTS.md antes de sugerir ou commitar códigos neste repositório.

## 🩺 Verificação de Saúde do Sistema

Para garantir que a infraestrutura de governança e o daemon estão rodando corretamente, você pode consultar o status do agendador e os logs de auditoria:

Verificar o Agendamento (Systemd Timer do Usuário):

```bash
systemctl --user status homeshield.timer
```

Ler os Logs de Auditoria do Daemon:

```bash
cat /mnt/hd_novo/toolbox/logs/homeshield.log
```

## 📄 Licença
Distribuído sob a licença MIT. Veja LICENSE para mais detalhes.
