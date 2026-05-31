# 🤖 AI Agent Runbook & Execution Rules (AGENTS.md)

Este arquivo define os limites operacionais, formatos de resposta e restrições de segurança para QUALQUER agente autônomo de IA que interaja com este ecossistema de manutenção.

## 🛑 STRICT RESTRICTIONS (O que você NÃO PODE fazer)
1. **Never Touch `/dev/sda1` Without Consent**: A partição `sda1` é o nosso cold-backup de segurança. Nenhuma automação de escrita ou exclusão pode rodar nela.
2. **No Blind Fstab Modification**: Alterações no arquivo `/etc/fstab` exigem validação prévia de UUID via `blkid` e geração de um arquivo `.bak` antes da escrita.
3. **No Raw Direct Deletions**: Substitua comandos destrutivos (`rm -rf`) em diretórios mapeados por movimentações para uma pasta temporária de descarte (`/mnt/hd_novo/trash/`).

## 🛠️ MANDATORY PROCEDURES (O que você DEVE fazer)
1. **Symlink Validation**: Antes de assumir que uma pasta existe na Home, verifique se ela é um link simbólico válido usando `test -L /caminho/`.
2. **Idempotent Scripting**: Ao sugerir ou criar novos scripts para a pasta `/scripts`, garanta que eles verifiquem se a ação já foi executada para evitar duplicidade.
3. **Task Completion Hook**: Após executar qualquer script listado no `README.md`, o agente deve atualizar o status correspondente na tabela de ferramentas e registrar o log em `/toolbox/logs/`.

## 🎛️ HITL GOVERNANCE (Governança Humana e Redundância Híbrida)
1. **Dual-Channel Consent**: O daemon de monitoramento (`SYS-05`) deve sempre disparar o consentimento local gráfico (`zenity`) e o webhook remoto para o Jarvis (n8n/Telegram/WhatsApp) de forma simultânea.
2. **First-Response Win**: O sistema deve aceitar a primeira resposta válida (seja o clique físico na tela ou a confirmação remota via API criptografada) e derrubar o canal adjacente para evitar concorrência.
3. **Conservative Timeout**: Em caso de ausência de resposta em ambos os canais dentro de 60 segundos, a missão deve ser abortada imediatamente sem alterações no sistema de arquivos.

## ⚡ PERFORMANCE OPTIMIZATION (Regras de Eficiência de Disco)
1. **Pre-Migration Cleanup**: Antes de iniciar o rsync de diretórios conhecidos por acumular lixo volátil (como `.npm` ou `.cache`), o sistema DEVE executar rotinas de prunagem/limpeza nativas para evitar o estresse mecânico de micro-arquivos no HD.
