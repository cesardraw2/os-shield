# language: pt
@epic("OSShieldCore")
@feature("#FOS005 - Resiliência e Backup Automático (Snapshot)")
Funcionalidade: Sistema de Backup da Home
  Como administrador precavido
  Eu quero que minha /home seja backupeada automaticamente em momentos críticos e manualmente sob demanda
  Para garantir que eu não perca dados importantes se o sistema falhar ou houver reconfiguração.

  Background:
    Dado que o usuário definiu o diretório "BACKUP_DESTINATION" na instalação
    E a ferramenta utiliza o RSYNC em modo incremental para máxima performance

  Rule: ["FOS005_SP001"] Backups Acionados por Evento
    @id("FOS005_A001")
    Cenário: Backup inicial durante a Instalação
      Dado que o administrador roda o "install.sh"
      Quando o Wizard de instalação finaliza a configuração
      Então o sistema aciona o rsync e cria o primeiro snapshot completo da Home no destino escolhido
    
    @id("FOS005_A002")
    Cenário: Backup antes de reconfigurar o motor (Timer)
      Dado que o usuário usa a opção de reconfigurar o agendamento
      Quando o novo timer é acionado
      Então o sistema realiza um backup incremental automático como medida de segurança antes de aplicar a nova configuração

  Rule: ["FOS005_SP002"] Backup Sob Demanda via Painel
    @hitl
    @swimlane("Admin")
    @id("FOS005_A003")
    Cenário: Execução manual do Backup via Zenity
      Dado que o usuário abre o Painel de Controle
      Quando clica na opção "Criar Snapshot da Home (Backup)"
      Então o sistema exibe uma barra de progresso do Rsync e consolida os arquivos no destino
