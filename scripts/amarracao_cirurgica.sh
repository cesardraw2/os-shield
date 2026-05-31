# 1. Cria a lixeira com permissões de root
sudo mkdir -p /mnt/hd_novo/trash/

# 2. Transfere os resíduos físicos do SSD para a lixeira do HD Novo com privilégios
for pasta in desenv Android .npm .nvm Imagens Vídeos; do
    if [ -d "$HOME/$pasta" ] && [ ! -L "$HOME/$pasta" ]; then
        echo -e "\033[0;33m[!] Movendo resíduo físico do SSD com segurança: $pasta\033[0m"
        sudo mv "$HOME/$pasta" /mnt/hd_novo/trash/
    fi
done

# 3. Força a criação limpa dos links simbólicos lógicos na sua Home
echo -e "\n\033[0;32m[+] Consolidando a malha de links simbólicos lógicos...\033[0m"
ln -snf /mnt/hd_novo/desenv "$HOME/desenv"
ln -snf /mnt/hd_novo/Android "$HOME/Android"
ln -snf /mnt/hd_novo/.npm "$HOME/.npm"
ln -snf /mnt/hd_novo/.nvm "$HOME/.nvm"
ln -snf /mnt/hd_novo/Imagens "$HOME/Imagens"
ln -snf /mnt/hd_novo/Vídeos "$HOME/Vídeos"
