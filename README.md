# RAGlog - Script de Pós-Instalação para Arch Linux

![Arch Linux Logo](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Shell Script](https://img.shields.io/badge/Shell%20Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Licença](https://img.shields.io/badge/Licen%C3%A7a-MIT-blue.svg?style=for-the-badge)

## 📖 Sobre o Script

Este repositório contém um script Bash poderoso e flexível projetado para automatizar e simplificar o processo de configuração pós-instalação em sistemas Arch Linux e derivados. O objetivo é economizar tempo, reduzir a chance de erros manuais e criar um ambiente de desktop funcional e completo com apenas alguns cliques.

## ✨ Funcionalidades

-   ✅ **Setup Inicial Automatizado:** Atualiza o sistema, instala pacotes essenciais (`base-devel`, `git`) e habilita o repositório `multilib`.
-   ✅ **Adição de Repositórios:** Configura automaticamente o popular repositório **Chaotic-AUR** para acesso a pacotes pré-compilados.
-   ✅ **Escolha de AUR Helper:** Permite que o usuário escolha entre `yay` e `paru`, os dois AUR helpers mais populares.
-   ✅ **Múltiplas Interfaces Gráficas:** Oferece um menu para instalar facilmente diversos Ambientes de Desktop (DE) e Gerenciadores de Janelas (WM), incluindo:
    -   KDE Plasma
    -   GNOME
    -   XFCE
    -   Cinnamon
    -   MATE
    -   Budgie
    -   LXQt (super leve)
    -   i3wm (Tiling Window Manager para X11)
    -   Hyprland (Tiling Window Manager para Wayland)
-   ✅ **Manutenção de Interfaces:** Permite remover uma interface gráfica instalada de forma limpa.
-   ✅ **Servidor de Áudio Moderno:** Dá a opção de escolher entre o tradicional `PulseAudio` e o moderno `PipeWire`.
-   ✅ **Drivers Gráficos:** Instalação simplificada dos drivers para placas **AMD**, **NVIDIA** e **INTEL**.
-   ✅ **Gerenciamento de Kernels:** Permite instalar kernels alternativos como `linux-lts`, `linux-xanmod` e `linux-cachyos`.
-   ✅ **Ferramentas de Desenvolvedor:** Um menu dedicado para instalar um ambiente de contêineres com **Docker**, `kubectl`, `oc` (cliente OpenShift) e `minikube`.
-   ✅ **Instalação de Aplicativos:** Instala uma lista selecionada de aplicativos populares dos repositórios oficiais e do AUR.
-   ✅ **Robusto e Seguro:** O script possui tratamento de erros e é construído com práticas seguras para evitar problemas.

## 🚀 Como Usar

### Pré-requisitos
Antes de executar o script, você precisa de:

1.  Uma instalação base do Arch Linux (ou um derivado como EndeavourOS, Artix, etc.).
2.  Uma conexão ativa com a internet.
3.  Um usuário padrão com privilégios `sudo`.

### Passos para Execução

#### Opção 1: Git Clone (Recomendado)
```bash
# Clone o repositório
git clone [https://github.com/gabrielnasthy/nome-do-seu-repositorio.git](https://github.com/gabrielnasthy/nome-do-seu-repositorio.git)

# Entre no diretório
cd nome-do-seu-repositorio

# Dê permissão de execução
chmod +x raglog.sh

# Execute o script
./raglog.sh
