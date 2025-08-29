
  RAGlog - Script de Pós-Instalação para Arch Linux



SOBRE O SCRIPT
-----------------
Este repositório contém um script Bash poderoso e flexível projetado para automatizar e simplificar o processo de configuração pós-instalação em sistemas Arch Linux e derivados. O objetivo é economizar tempo, reduzir a chance de erros manuais e criar um ambiente de desktop funcional e completo com apenas alguns cliques.


FUNCIONALIDADES
---------------
* Setup Inicial Automatizado: Atualiza o sistema, instala pacotes essenciais (base-devel, git, etc.) e habilita o repositório multilib.

* Adição de Repositórios: Configura automaticamente o popular repositório Chaotic-AUR para acesso a pacotes pré-compilados.

* Escolha de AUR Helper: Permite que o usuário escolha entre yay e paru, os dois AUR helpers mais populares.

* Múltiplas Interfaces Gráficas: Oferece um menu para instalar facilmente diversos Ambientes de Desktop (DE) e Gerenciadores de Janelas (WM), incluindo:
    - KDE Plasma
    - GNOME
    - XFCE
    - Cinnamon
    - MATE
    - Budgie
    - LXQt (super leve)
    - i3wm (Tiling Window Manager)
    - Hyprland (Tiling p/ Wayland)

* Manutenção de Interfaces: Permite remover uma interface gráfica instalada de forma limpa, desativando os serviços e removendo os pacotes relacionados.

* Servidor de Áudio Moderno: Dá a opção de escolher entre o tradicional PulseAudio e o moderno PipeWire, recomendado para melhor compatibilidade de hardware.

* Drivers Gráficos: Instalação simplificada dos drivers para placas AMD, NVIDIA e INTEL.

* Gerenciamento de Kernels: Permite instalar kernels alternativos como linux-lts, linux-xanmod e linux-cachyos.

* Ferramentas de Desenvolvedor: Um menu dedicado para instalar um ambiente de contêineres com Docker, kubectl, oc (cliente OpenShift) e minikube.

* Instalação de Aplicativos: Instala uma lista selecionada de aplicativos populares do AUR/repositórios oficiais.

* Robusto e Seguro: O script possui tratamento de erros, não deve ser executado como root e é construído com práticas seguras (set -euo pipefail).


PRÉ-REQUISITOS
---------------
Antes de executar o script, você precisa de:

1. Uma instalação base do Arch Linux (ou um derivado como EndeavourOS, Artix, etc.).
2. Uma conexão ativa com a internet.
3. Um usuário padrão com privilégios sudo.


COMO USAR
----------
1. BAIXE O SCRIPT
   Você pode baixar o script usando o comando curl em seu terminal:

   curl -O https://url-do-seu-script/raglog.sh

   (Substitua o URL pelo link real do script)

2. DÊ PERMISSÃO DE EXECUÇÃO AO SCRIPT
   chmod +x raglog.sh

3. EXECUTE O SCRIPT
   ./raglog.sh

   O script irá iniciar, realizar uma atualização inicial do sistema, guiar você na escolha do AUR helper e, em seguida, apresentar o menu principal com todas as opções disponíveis.


DETALHES DO MENU PRINCIPAL
--------------------------
* 1) Escolher e Instalar AUR Helper: Essencial para o primeiro uso. Instala yay ou paru.
* 2) Habilitar Multilib e Chaotic-AUR: Configura seu pacman.conf para acesso a mais pacotes.
* 3) Escolher e Instalar Interface Gráfica: Onde você escolhe seu ambiente de desktop principal.
* 4) Escolher Servidor de Áudio: Recomenda-se PipeWire para sistemas modernos.
* 5) Instalar Drivers Gráficos: Selecione o fabricante da sua GPU para instalar os drivers corretos.
* 6) Instalar Navegador: Instala seu navegador web preferido.
* 7) Instalar outro Kernel: Para usuários que desejam um kernel otimizado ou de suporte estendido (LTS).
* 8) Instalar ZSH e Plugins: Configura o Zsh com o popular framework "Oh My Zsh" e plugins úteis.
* 9) Instalar Programas Padrão (AUR): Instala uma lista de softwares úteis como VS Code, Steam, Discord, etc.
* 10) Instalar Ferramentas de Desenvolvedor: Configura o ambiente para desenvolvimento com contêineres.
* 11) Ativar Serviços Essenciais: Habilita serviços como NetworkManager, bluetooth e o Display Manager (tela de login) da sua DE.
* 12) Remover Interface Gráfica Instalada: (Use com cuidado) Desinstala um ambiente de desktop do sistema.
* 13) RODAR TUDO: Executa as principais funções de instalação em sequência. Ideal para a primeira configuração do sistema.


CONSIDERAÇÕES IMPORTANTES
------------------------
- Revise o Código: É sempre uma boa prática de segurança ler o código de um script antes de executá-lo em seu sistema, especialmente um que usa privilégios sudo.

- Não Execute como Root: O script foi projetado para ser executado por um usuário padrão. Ele solicitará a senha sudo apenas quando necessário. Executá-lo como root pode causar problemas de permissão em sua pasta pessoal.

- Função de Remoção: A opção de remover uma interface é destrutiva e deixará seu sistema sem ambiente gráfico. Use-a apenas se tiver certeza de que deseja instalar outra ou sabe como operar o sistema em modo texto.

- Backups: Para sistemas críticos, considere usar uma ferramenta de backup e snapshot como o Timeshift antes de realizar grandes alterações.


CONTRIBUIÇÕES
-------------
Sinta-se à vontade para abrir um "issue" para relatar bugs ou sugerir novas funcionalidades. "Pull requests" são sempre bem-vindos!


LICENÇA
-------
Este projeto está licenciado sob a Licença MIT.
