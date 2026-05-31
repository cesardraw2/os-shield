# language: pt
@epic("OSShieldCore")
@feature("#FOS002 - Wizard de Instalação e Setup Inicial")
Funcionalidade: Wizard de Instalação e Setup Inicial
  Como novo usuário do OS-SHIELD
  Eu quero um instalador guiado (Wizard) para configurar o projeto
  Para que eu possa definir o agendamento do Daemon e ter a garantia de que o sistema só ligará se a instalação for bem sucedida.

  Rule: ["FOS002_SP001"] Configuração e Validação de Instalação
    @hitl
    @swimlane("Admin")
    @id("FOS002_A001")
    Cenário: Configuração de agendamento via Wizard
      Dado que o administrador inicia o "install.sh"
      Quando o Wizard exibe a tela de configuração de Agendamento
      E o administrador seleciona a frequência desejada (ex: 15min, 1h, 6h)
      Então o sistema atualiza o arquivo "homeshield.timer" com o valor selecionado
      E prossegue com as ancoragens iniciais

    @id("FOS002_A002")
    Cenário: Instalação concluída com sucesso e Daemon ativado
      Dado que o Wizard de instalação está em execução
      Quando todas as etapas de linkagem, configuração e testes passarem sem erros
      Então o sistema registra a flag de sucesso de instalação (".install_success")
      E o sistema ativa e inicia o "homeshield.timer" em background
      E o usuário recebe uma notificação de sucesso

    @id("FOS002_A003")
    Cenário: Interrupção ou falha durante a instalação
      Dado que o Wizard de instalação está em execução
      Quando ocorre uma falha crítica ou o usuário cancela a execução prematuramente
      Então o sistema limpa a flag de sucesso (".install_success")
      E o sistema NÃO ativa o "homeshield.timer"
      E o usuário recebe um alerta de que o sistema não está protegido
