# language: pt
@epic("OSShieldCore")
@feature("#FOS003 - Gestão Dinâmica de Configurações")
Funcionalidade: Gestão Avançada de Whitelist
  Como administrador do sistema
  Eu quero um painel completo para gerenciar a Whitelist do SSD
  Para que eu possa ver todas as pastas protegidas, adicionar novas e remover antigas em uma interface unificada.

  Rule: ["FOS003_SP002"] Gestão Visual da Whitelist
    @hitl
    @swimlane("Admin")
    @id("FOS003_A004")
    Cenário: Visualizar e Gerenciar lista de pastas no Painel
      Dado que o usuário acessa o menu de "Gestão de Pastas Protegidas"
      Quando o painel exibe a lista completa de pastas atualmente na "WHITELIST_SSD"
      E o usuário utiliza os botões dinâmicos do painel ("Adicionar", "Remover")
      Então o sistema processa a ação, atualiza o arquivo "shield.conf"
      E recarrega a lista visualmente em loop até o usuário clicar em "Voltar"
