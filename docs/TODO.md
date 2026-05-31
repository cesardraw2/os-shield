# 🚀 Antigravity OS-Shield & Suite - Evolution Roadmap (TODO.md)

Este documento consolida a visão de longo prazo para a evolução do nosso ecossistema de gerenciamento de infraestrutura, IA local e governança de segurança.

## 🟩 FASE 1: A Base de Ferro (Shell Script / Local) - [STATUS: ACELERADO]
- [x] **SYS-01**: Migração bruta de caches e pastas pesadas para o HD Novo liberando o SSD.
- [ ] **SYS-02**: Execução e validação da re-linkagem simbólica na Home limpa.
- [ ] **SYS-03**: Geração automatizada do primeiro snapshot do `fstab` e tabela de links.
- [ ] **SYS-04**: Ativação da sincronização automática via `rclone` com o Google Drive.
- [ ] **SYS-05**: Desenvolvimento do Daemon `homeshield_daemon.sh` via Systemd Service/Timer com alertas locais gráficos via `zenity`.
- [ ] **SYS-06**: Refinamento do script de telemetria para reports de execução em tempo real.

## 🟨 FASE 2: O Núcleo de Alta Performance (Rust Engine & MicroTUIs Federadas) - [PRÓXIMO PASSO]
- [ ] **Core em Rust**: Reescrever a inteligência dos scripts Bash em uma CLI nativa em Rust para ganho de velocidade e segurança de memória.
- [ ] **Arquitetura de MicroTUIs (Wasm Sandbox)**: 
  - Estruturar a TUI principal (Host via `Ratatui`) de forma desacoplada.
  - Implementar o padrão de "Microfrontends de Terminal", onde submódulos remotos da VPS são compilados para WebAssembly (`wasm32-wasi`) e injetados em runtime no Host local via runtimes leves (`Wasmtime`/`Wasmer`).
- [ ] **MCP Server Nativo**: Integrar um servidor MCP dentro do binário do Rust para permitir que o Jarvis na nuvem ou modelos locais (Ollama) consumam o status do OS via JSON padronizado.

## 🟧 FASE 3: A Interface Web Avançada (Angular Native Federation + Tauri)
- [ ] **Front-end em Angular**: Criar uma dashboard web moderna com Tailwind CSS para monitoramento visual, configuração de limites de espaço e aprovação de jobs.
- [ ] **Native Federation no Desktop**: Utilizar os conceitos de Module/Native Federation para carregar dinamicamente microfrontends administrativos distribuídos.
- [ ] **Empacotamento Tauri**: Unir o Front Angular ao Core Rust usando Tauri, eliminando o peso do Electron e gerando um executável nativo ultra-leve.

## 🟥 FASE 4: Orquestração Multi-Node, Encanamento gRPC e Segurança Zero-Trust
- [ ] **Comunicação Segura de Agentes (gRPC / JSON-RPC)**: Abstrair comandos brutos de terminal. A UI/TUI local envia requisições estruturadas via gRPC sobre WebSockets Criptografados para o Daemon remoto em Rust rodando na VPS da Contabo.
- [ ] **Isolamento de Rede (VPN)**: Bloquear qualquer tráfego de gerenciamento fora da subrede privada/VPN segura.
- [ ] **Autenticação SSO/OAuth**: Integrar validação de identidade na camada de transporte usando Google OAuth / Identity Provider interno antes de expor a tela de gerenciamento.
- [ ] **Gatilho de Consentimento Remoto (HITL Criptografado)**: Implementar o fluxo de aprovação estilo Antigravity/Gemini. Uma ação crítica na VPS abre um link web seguro que exige autenticação SSO e um clique físico de autorização na máquina local para liberar o token JWT que destrava a execução do comando em background no servidor.
