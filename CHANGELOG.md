# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v4.2.0] - 2026-05-31
### Added
- **Rsync Backup (FOS005):** Snapshots automáticos e manuais da Home no SSD.
- **Few-Shot Learning (FOS004):** Integração do arquivo `jarvis_learning.txt` para injetar memória na IA.
- **Interface Gráfica de Edição da IA:** Zenity nativo editando os pesos de memória (Prompting).
- **Acesso Global CLI:** Adicionado alias `os-shield` no `.bashrc`.

### Changed
- **Versionamento Dinâmico:** Instalador e Painel agora exibem versão baseada em SemVer (Inteligência de Atualização).
- **Whitelist CRUD:** Substituição do *input* simples por um Menu visual interativo com listagem e checkboxes.

## [v4.1.0] - 2026-05-31
### Added
- **Wizard de Instalação (FOS002):** Interface gráfica para configurar os temporizadores do Daemon (5m, 15m, 1h).
- **Systemd User:** Migração de todos os serviços de daemon de `root` para `.config/systemd/user/`.

## [v4.0.0] - 2026-05-31
### Added
- **Governança HITL (FOS001):** Sistema agora grava as sugestões da IA e aguarda aprovação humana.
- Configuração modular (`shield.conf`) com Whitelists separadas.
