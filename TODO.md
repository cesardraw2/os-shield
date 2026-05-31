# 📋 OS-SHIELD Roadmap & TODO

Este documento rastreia débitos técnicos, ideias arquiteturais e melhorias planejadas para o ecosistema OS-SHIELD, seguindo o padrão de esteira de desenvolvimento contínuo (Continuous Improvement).

## 🚀 Alta Prioridade (Backlog)

- `[ ]` **Evolução do Motor de Backup (Restic / BorgBackup):**
  - **Contexto:** Atualmente utilizamos o `Rsync` em modo *mirror* para garantir resiliência estrutural do SSD de forma ultra-rápida. Embora performático, o Rsync não permite compressão em arquivo único (`.tar.gz`) sem destruir a velocidade incremental, resultando em consumo maior de espaço no disco de destino.
  - **Proposta:** Substituir ou criar uma chave seletora para adotar ferramentas modernas (como o **BorgBackup** ou **Restic**). Eles são escritos em linguagens de baixo nível (C/Rust), quebram os arquivos em *chunks* invisíveis, aplicam criptografia militar e compressão pesada (deduplicação), conseguindo manter a característica incremental (rápida) enquanto compactam fortemente os dados.

## 🧠 Médio Prazo (Pesquisa e Desenvolvimento)

- `[ ]` **Integração de Nuvem (Rclone):** Avaliar a adição de uma etapa de sincronização de backups locais cruciais para um *bucket* S3 ou Google Drive através do Rclone.
- `[ ]` **Dashboard de Saúde em TUI:** Desenvolver uma interface TUI (*Text-based User Interface*) para exibir a saúde geral do SSD vs HD no terminal, em complemento ao painel Zenity.

## 🛠️ Baixa Prioridade (Polimentos)

- `[ ]` **Empacotamento (Debian/RPM):** Avaliar a viabilidade de transformar a Toolbox em um pacote `.deb` para distribuição corporativa automatizada.
