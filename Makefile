# OS-SHIELD Makefile
# Define comandos padrão para facilitar o ecossistema corporativo

.PHONY: help install uninstall lint clean

help:
	@echo "Comandos disponíveis:"
	@echo "  make install    - Executa o instalador guiado do OS-SHIELD"
	@echo "  make uninstall  - Remove o OS-SHIELD do sistema de forma segura"
	@echo "  make lint       - Executa o ShellCheck em todos os scripts Bash"
	@echo "  make clean      - Remove arquivos de log temporários"

install:
	@echo "Iniciando instalação do OS-SHIELD..."
	@bash ./install.sh

uninstall:
	@echo "Iniciando desinstalação do OS-SHIELD..."
	@bash ./uninstall.sh

lint:
	@echo "Executando análise de código (ShellCheck)..."
	@shellcheck scripts/*.sh
	@shellcheck install.sh
	@shellcheck uninstall.sh

clean:
	@echo "Limpando logs e caches temporários..."
	@rm -f logs/*.log
	@echo "Limpeza concluída."
