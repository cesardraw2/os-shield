# 🛠️ OS-SHIELD (Antigravity HomeShield)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash Shell](https://img.shields.io/badge/shell-bash-4eed1c.svg)](https://www.gnu.org/software/bash/)

O **OS-SHIELD** é um canivete suíço de infraestrutura local projetado para manter a sua `/home` ultra-leve, estendendo a vida útil e economizando espaço precioso do seu SSD principal (NVMe). Ele cria uma malha logística de links simbólicos e um Daemon resiliente do Systemd que gerencia o fluxo de dados em background para um HD secundário de forma transparente.

Ideal para System Architects, Desenvolvedores Full-Stack e usuários Linux que lidam com caches massivos de desenvolvimento (`node_modules`, Android SDKs, caches de IA locais) em máquinas com armazenamento SSD limitado.

---

## 🏗️ Arquitetura do Sistema

O projeto intercepta e isola pastas de alta taxa de escrita do SSD, movendo os blocos brutos para o HD mecânico e ancorando links lógicos na Home.

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
🚀 Instalação e Instanciação Rápida
1. Clonar o Repositório
Clone esta caixa de ferramentas dentro da partição do seu HD secundário montado:

Bash
cd /mnt/seu_hd_secundario
git clone [https://github.com/seu-usuario/os-shield.git](https://github.com/seu-usuario/os-shield.git) toolbox
cd toolbox
2. Configurar Variáveis de Ambiente
Abra o arquivo de propriedades e ajuste os caminhos para bater com o seu usuário e ponto de montagem do HD:

Bash
nano configs/shield.conf
3. Rodar a Carga Inicial e Instalar o Daemon
Execute o orquestrador para consolidar os links simbólicos na sua Home atual e registrar o Daemon no barramento do sistema:

Bash
./scripts/links_sym_setup.sh
Para habilitar a automação em background a cada 15 minutos:

Bash
sudo cp daemon_state/homeshield.* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now homeshield.timer
🤖 AI-Agent Readiness (Manifesto de Cooperação)
Se você é um Agente de IA (Cursor, Jarvis, Claude, ChatGPT) operando ou estendendo esta toolbox, você deve ler rigorosamente as instruções contidas em docs/AGENTS.md antes de sugerir ou commitar códigos neste repositório.

📄 Licença
Distribuído sob a licença MIT. Veja LICENSE para mais detalhes.
