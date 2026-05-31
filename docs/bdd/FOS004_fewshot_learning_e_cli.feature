# language: pt
@epic("OSShieldCore")
@feature("#FOS004 - Aprendizado Contínuo (Few-Shot) e Integração CLI")
Funcionalidade: Aprendizado Contínuo (Few-Shot) e Integração CLI
  Como administrador do sistema
  Eu quero fornecer exemplos para a Inteligência Artificial e acessar a ferramenta globalmente
  Para que o modelo evolua seu julgamento com meu feedback e eu não precise navegar até a pasta de instalação para operá-lo.

  Rule: ["FOS004_SP001"] Injeção de Conhecimento Base (Few-Shot Prompting)
    @id("FOS004_A001")
    Cenário: Fornecer histórico de aprendizado ao prompt do Jarvis
      Dado que existe um arquivo de aprendizado com exemplos de erros e acertos ("jarvis_learning.txt")
      Quando o Daemon aciona o Jarvis para classificar uma nova pasta
      Então o script injeta os exemplos do arquivo de aprendizado no prompt do SRE
      E a IA responde com base no contexto aprendido, mitigando erros anteriores

    @hitl
    @swimlane("Admin")
    @id("FOS004_A003")
    Cenário: Edição manual da memória da IA via interface gráfica
      Dado que o usuário abre o Painel de Controle (Zenity)
      Quando o usuário clica na opção "Treinar Inteligência Artificial (Memória)"
      Então o painel abre um editor de texto interativo com o conteúdo de "jarvis_learning.txt"
      E o usuário pode modificar, salvar e aplicar os novos pesos contextuais em tempo real

  Rule: ["FOS004_SP002"] Acesso Global (Environment / Bashrc)
    @id("FOS004_A002")
    Cenário: Injeção do CLI no .bashrc via Instalador
      Dado que o administrador executa o instalador do OS-SHIELD
      Quando a instalação é concluída
      Então o instalador cria um alias global "os-shield" no ".bashrc" do usuário
      E aplica a configuração instantaneamente para que a ferramenta seja chamada de qualquer diretório
