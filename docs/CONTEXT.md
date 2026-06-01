# 🗺️ System Context Architecture (Cesar Draw Environment)

## 💻 Hardware Reference
- **Machine**: Acer Nitro 5 (AN515-51)
- **Primary Storage (OS)**: SSD NVMe (`/dev/nvme0n1p4`) -> Destinado ao Sistema Operacional e `/home` limpa (Configurações/.config).
- **Secondary Storage (Data)**: HD Mecânico 1TB (`/dev/sda`)
  - `/dev/sda1`: Backup e imagem histórica da Home antiga.
  - `/dev/sda2`: Partição dedicada de alta capacidade para dados de Dev, IA e Mídias.

## 🐧 OS & Stack Spec
- **Operating System**: Linux Mint (Ambiente de Produção)
- **Core Hypervisor**: KVM/QEMU para virtualização de Windows (CorelDRAW)
- **Tech Stack Focus**: Angular (Native Federation), Node.js, LangChain, Ollama, n8n, BPMN [cite: Gemini Chat. Evidence: Technical discussions and project requests involving Angular, Node.js, and Linux stacks. Date: 2025-09 to 2026-04., Gemini Chat. Evidence: User discussed building a personal assistant named Jarvis and orchestrating AI-driven project squads. Date: 2026-03 to 2026-04., Gmail. Evidence: User activated a professional license key for n8n in August 2025 and enrolled in courses for LangChain and AI agents. Date: 2025-08 to 2026-01., Search. Evidence: Queries for ollama, native federation in angular, and how to make modules flexible for containers. Date: 2025-09.].

## 🔗 Storage Mapping Strategy (The Ping-Pong Architecture)
Para otimizar a vida útil e performance do SSD, todos os diretórios de escrita massiva, caches globais e repositórios pesados ficam hospedados fisicamente no **Armazenamento Secundário** e são espelhados na **Home do Usuário** através de **Links Simbólicos (Symlinks)**.
