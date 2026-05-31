# language: pt
@epic("OSShieldCore")
@feature("#FOS001 - Governança Híbrida e HITL")
Funcionalidade: Governança Híbrida e HITL
  Como administrador do sistema
  Eu quero que o OS-SHIELD utilize regras rígidas (Hard-Rules) integradas à IA Preditiva
  Para manter meu SSD performático e aprovar assincronamente as decisões da IA.

  Background:
    Dado que o Daemon do OS-SHIELD está configurado para execução a cada 15 minutos
    E as Hard-Rules estão definidas em "configs/shield.conf"

  Rule: ["FOS001_SP001"] Varredura e Migração Padrão
    @id("FOS001_A001")
    Cenário: Pasta mapeada na Whitelist do SSD (Hard-Rule)
      Dado que uma nova pasta é detectada na Home
      E a pasta consta na "WHITELIST_SSD"
      Quando o Daemon processa a pasta
      Então o sistema a mantém intacta no SSD

    @id("FOS001_A002")
    Cenário: Pasta detectada na Home fora das regras
      Dado que uma pasta genérica é detectada na Home
      E ela não está na "WHITELIST_SSD"
      Quando o Daemon processa a pasta
      Então o sistema migra fisicamente a pasta para o HD via rsync
      E cria o link simbólico na Home

  Rule: ["FOS001_SP002"] Decisão de IA e HITL Assíncrono
    @id("FOS001_A003")
    Cenário: Nova pasta desconhecida submetida à IA Preditiva
      Dado que o sistema aciona o Jarvis Preditivo para uma pasta
      Quando a IA (Ollama) avalia a natureza dos arquivos
      E a IA decide que a pasta é conteúdo pesado (HD)
      Então o sistema segue com a migração para o HD e amarra o link

    @hitl
    @swimlane("Admin")
    @id("FOS001_A004")
    Cenário: IA sugere permanência no SSD e gera solicitação HITL
      Dado que a IA avalia que a pasta tem natureza crítica para o sistema (SSD)
      Ao mesmo tempo o sistema aborta a migração e mantém a pasta no disco principal
      E em paralelo o sistema apensa a sugestão no arquivo ".jarvis_hitl_review.txt"
      Mas se o usuário abrir o Painel de Controle e aprovar a inclusão
      Então o sistema injeta o nome da pasta na "WHITELIST_SSD" no "shield.conf"
