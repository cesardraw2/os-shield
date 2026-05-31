#!/bin/bash
# ==============================================================================
# SCRIPT: env_fix_permissions.sh
# PROPÓSITO: Ajuste cirúrgico de permissões de Dev e Mídias
# ==============================================================================

TARGET="/mnt/hd_novo"
USUARIO="cesardraw"

echo -e "\033[1;33m[!] Corrigindo governança de proprietários no HD Novo...\033[0m"

if [ -d "$TARGET" ]; then
    # Garante que as pastas operacionais pertencem ao seu usuário de desenvolvimento
    sudo chown -R $USUARIO:$USUARIO "$TARGET/desenv" "$TARGET/Android" "$TARGET/.npm" "$TARGET/.nvm" "$TARGET/Imagens" "$TARGET/Vídeos" "$TARGET/toolbox" 2>/dev/null
    
    # Aplica permissões padrão de leitura e escrita para segurança
    sudo chmod -R u+rwX,g+rX,o-rwx "$TARGET/desenv" 2>/dev/null
    
    echo -e "\033[0;32m✅ Governança e permissões restabelecidas com sucesso!\033[0m"
else
    echo -e "\033[0;31m[X] Erro: Diretorio $TARGET não encontrado.\033[0m"
fi
