# language: pt
@epic("OSShieldCore")
@feature("#FOS006 - Distribuição, Resiliência e Rollback")
Funcionalidade: Preparação para Distribuição Global
  Como um Engenheiro de Software Open Source
  Eu quero que o OS-SHIELD gerencie suas próprias dependências, possua abstração de ambiente e um motor de rollback seguro
  Para que qualquer desenvolvedor no mundo possa instalá-lo ou removê-lo sem hardcodes e com altíssima segurança (CI/CD).

  Rule: ["FOS006_SP001"] Autogestão de Dependências e Ambiente
    @id("FOS006_A001")
    Cenário: Instalação com dependências faltantes
      Dado que o usuário executa o "install.sh" em uma máquina limpa
      Quando o script detecta ausência de pacotes vitais (zenity, rsync, ollama, bleachbit)
      Então o instalador exibe uma lista do que falta
      E solicita permissão para baixar e instalar as dependências nativamente via apt/dnf

    @id("FOS006_A002")
    Cenário: Dinamismo de Ponto de Montagem (Mount Point)
      Dado que o usuário tem seu HD Secundário montado em um caminho exótico (ex: /media/dados)
      Quando o "install.sh" é executado
      Então ele solicita a localização do HD via interface gráfica
      E atualiza o "shield.conf" e o Systemd dinamicamente com o novo PATH

  Rule: ["FOS006_SP002"] Clean Uninstallation (Rollback)
    @id("FOS006_A003")
    Cenário: Remoção Segura da Ferramenta
      Dado que o administrador deseja desinstalar o OS-SHIELD
      Quando executa o "uninstall.sh"
      Então o sistema desabilita e deleta o Daemon do Systemd
      E remove o alias do .bashrc
      E não apaga nenhum dado do usuário do HD secundário, apenas desvinculando a infraestrutura
