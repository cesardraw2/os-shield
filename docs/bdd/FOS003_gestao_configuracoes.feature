# language: pt
@epic("OSShieldCore")
@feature("#FOS003 - Gestão Dinâmica de Configurações")
Funcionalidade: Gestão Dinâmica de Configurações
  Como administrador do sistema
  Eu quero poder reconfigurar o agendamento e gerenciar manualmente as pastas protegidas (Whitelist)
  Para adaptar o nível de proteção sem precisar editar arquivos de texto ou rodar o instalador novamente.

  Rule: ["FOS003_SP001"] Reconfiguração de Agendamento via Painel
    @hitl
    @swimlane("Admin")
    @id("FOS003_A001")
    Cenário: Alterar frequência do Daemon após a instalação inicial
      Dado que o OS-SHIELD já está instalado e rodando
      Quando o usuário abre o Painel de Controle (Zenity)
      E seleciona a opção "Configurar Agendamento do Daemon"
      Então o sistema invoca silenciosamente a rotina de tempo do instalador
      E recarrega o "homeshield.timer" com a nova frequência sem quebrar os links

  Rule: ["FOS003_SP002"] Gestão Manual de Pastas (Whitelist)
    @hitl
    @swimlane("Admin")
    @id("FOS003_A002")
    Cenário: Adicionar nova pasta crítica manualmente à Whitelist
      Dado que existe uma nova pasta na Home que a IA não analisou ainda
      Quando o usuário abre o Painel de Controle
      E seleciona a opção "Gerenciar Pastas Protegidas (Whitelist)"
      E digita o nome da nova pasta no input de texto
      Então o sistema insere o nome da pasta no array "WHITELIST_SSD" dentro do "shield.conf"
      E protege a pasta imediatamente de qualquer migração

    @id("FOS003_A003")
    Cenário: Tentativa de adicionar pasta já existente
      Dado que o usuário tenta adicionar manualmente uma pasta que já está na Whitelist
      Quando o sistema processa a inserção
      Então a interface exibe um aviso de duplicidade
      E não duplica a entrada no "shield.conf"
