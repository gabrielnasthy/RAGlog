#!/usr/bin/env bash
# shellcheck source=/dev/null

#-----------------------------------------| Váriaveis|-------------------------------------------------#
# O diretório de cache para logs e downloads do script.
DIR="$HOME/.cache/RAGlog"

# Códigos de cores para mensagens no terminal.
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

# Mapeamento de nomes amigáveis para nomes de pacotes de navegadores.
declare -A NAVEGADORES=(
    ["edge-dev"]="microsoft-edge-dev-bin"
    ["edge-stable"]="microsoft-edge-stable-bin"
    ["chrome"]="google-chrome"
    ["firefox"]="firefox"
)

# Mapeamento de fabricantes de GPU para os pacotes de driver necessários.
declare -A DRIVERS_GRAFICOS=(
    ["AMD"]="lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader"
    ["INTEL"]="lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader"
    ["NVIDIA"]="nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader"
)

# Mapeamento de Kernels para instalação.
declare -A KERNELS=(
    [1]="linux-xanmod linux-xanmod-headers"
    [2]="linux-lts linux-lts-headers"
    [3]="linux linux-headers"
    [4]="linux-cachyos linux-cachyos-headers"
)

# Lista de pacotes essenciais a serem instalados via pacman.
PAC_ESSENCIAIS=(
    base-devel
    git
    zsh
    zsh-completions
)

# Lista de dependências para o Wallpaper Engine.
WALLPAPER_ENGINE_DEPS=(
    extra-cmake-modules
    plasma-framework
    gst-libav
    mpv
    python-websockets
    qt5-declarative
    qt5-websockets
    qt5-webchannel
    vulkan-headers
    cmake
)

# --- Listas de Pacotes para Interfaces Gráficas ---
KDE_APP_INSTALL=(
    wget nano plasma-desktop plasma-wayland-session plasma-nm plasma-framework plasma-pa kate gwenview kscreen powerdevil sddm dolphin dolphin-plugins noto-fonts-emoji ffmpegthumbnailer ffmpegthumbs tilix spectacle plasma-integration plasma-workspace kded kwayland kwayland-integration systemsettings plasma-workspace-wallpapers ntfs-3g ark ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base gst-plugins-bad gst-libav gstreamer btrfs-progs kio-gdrive neofetch htop grub-customizer gufw fwupd xorg-server xorg-xinit xorg-apps mesa pulseaudio alsa-utils pulseaudio-bluetooth packagekit-qt5 archlinux-appstream-data
)
GNOME_APP_INSTALL=(
    gnome gnome-extra gnome-shell gnome-terminal nautilus gnome-control-center gnome-tweaks gnome-calculator gnome-system-monitor evince gedit gnome-software file-roller gnome-screenshot gnome-disk-utility gnome-keyring gvfs networkmanager pulseaudio pulseaudio-bluetooth
)
XFCE_APP_INSTALL=(
    xfce4 xfce4-goodies xfce4-terminal thunar xfce4-taskmanager xfce4-settings xfce4-power-manager xfce4-screenshooter xfce4-pulseaudio-plugin xfce4-notifyd networkmanager gvfs evince mousepad pulseaudio-bluetooth
)
CINNAMON_APP_INSTALL=(
    cinnamon nemo cinnamon-control-center cinnamon-screensaver gnome-terminal xed cinnamon-settings-daemon cinnamon-session networkmanager pulseaudio gnome-screenshot gvfs file-roller pulseaudio-bluetooth
)
I3WM_APP_INSTALL=(
    i3-wm i3lock i3status tilix spectacle ntfs-3g ark ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base gst-plugins-bad gst-libav gstreamer btrfs-progs neofetch htop grub-customizer gufw fwupd xorg-server xorg-xinit xorg-apps mesa pulseaudio alsa-utils pulseaudio-bluetooth
)

# --- Lista de Pacotes do YAY/AUR ---
YAY_APP_INSTALL=(
    # Aplicativos de Produtividade e Desenvolvimento
    visual-studio-code-bin
    mysql-workbench
    xampp
    github-desktop-bin
    anydesk-bin
    # Comunicação e Social
    discord
    whatsapp-electron-bin
    # Jogos e Lançadores
    steam
    heroic-games-launcher
    lutris
    atlauncher
    # Utilitários e Multimídia
    balena-etcher
    obs-studio
    kdenlive
    spotify
    piper # Para configurar mouses gamer
    portmaster-stub-bin # Firewall de aplicativos
    # Outros
    arduino
    # Dependências completas do Wine (unificadas aqui)
    wine-staging
    winetricks
    wine-mono
    wine-gecko
    giflib lib32-giflib
    libpng lib32-libpng
    libldap lib32-libldap
    gnutls lib32-gnutls
    mpg123 lib32-mpg123
    openal lib32-openal
    v4l-utils lib32-v4l-utils
    libpulse lib32-libpulse
    libgpg-error lib32-libgpg-error
    alsa-plugins lib32-alsa-plugins
    alsa-lib lib32-alsa-lib
    libjpeg-turbo lib32-libjpeg-turbo
    sqlite lib32-sqlite
    libxcomposite lib32-libxcomposite
    libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama
    ncurses lib32-ncurses
    opencl-icd-loader lib32-opencl-icd-loader
    libxslt lib32-libxslt
    libva lib32-libva
    gtk3 lib32-gtk3
    gst-plugins-base-libs lib32-gst-plugins-base-libs
    vulkan-icd-loader lib32-vulkan-icd-loader
)


#------------------------------------------| Funções Auxiliares |------------------------------------------------#

# Exibe uma mensagem de erro e sai do script.
erro() {
    echo -e "${VERMELHO}[ERRO] - $1${SEM_COR}" >&2
    exit 1
}

# Exibe uma mensagem de informação.
info() {
    echo -e "${VERDE}[INFO] - $1${SEM_COR}"
}

# Instala uma lista de pacotes usando o gerenciador de pacotes especificado (pacman ou yay).
instalar_pacotes() {
    local gerenciador=$1
    shift
    local pacotes=("$@")
    local pacotes_com_falha=()

    if [ ${#pacotes[@]} -eq 0 ]; then
        echo -e "${VERMELHO}[AVISO] - Nenhuma lista de pacotes fornecida para o gerenciador $gerenciador.${SEM_COR}"
        return 1
    fi

    info "Instalando pacotes com $gerenciador..."
    for pacote in "${pacotes[@]}"; do
        # Use -Q para pacman e yay, que são compatíveis com essa flag.
        if ! $gerenciador -Q "$pacote" &>/dev/null; then
            info "Instalando $pacote..."
            if [ "$gerenciador" == "pacman" ]; then
                sudo pacman -S "$pacote" --noconfirm --needed || pacotes_com_falha+=("$pacote")
            else
                $gerenciador -S "$pacote" --noconfirm --needed || pacotes_com_falha+=("$pacote")
            fi
        else
            info "O pacote $pacote já está instalado."
        fi
    done

    if [ ${#pacotes_com_falha[@]} -gt 0 ]; then
        echo -e "${VERMELHO}[ERRO] - Falha ao instalar os seguintes pacotes: ${pacotes_com_falha[*]}.${SEM_COR}"
        return 1
    fi
    return 0
}


#------------------------------------------| Testes e Atualizações Iniciais |------------------------------------------------#

# Verifica a conexão com a internet e atualiza o sistema.
preparar_sistema() {
    if ! ping -c 1 8.8.8.8 -q &>/dev/null; then
        erro "Seu computador não tem conexão com a internet."
    fi
    info "Conexão com a internet funcionando normalmente."

    info "Atualizando o sistema com pacman..."
    sudo pacman -Syu --noconfirm || erro "Falha ao atualizar os pacotes Pacman."

    instalar_pacotes "pacman" "${PAC_ESSENCIAIS[@]}"

    # Instala o YAY se não estiver presente, pois é necessário para muitas funções.
    if ! command -v yay &>/dev/null; then
        instalar_yay
    fi
    
    info "Atualizando pacotes do AUR com YAY..."
    yay -Syu --noconfirm || erro "Falha ao atualizar os pacotes YAY."
}

#-------------------------------------------| Funções Principais |-----------------------------------------------#

# Exibe o cabeçalho do script.
cabecalho() {
    clear
    echo "                                                                                                        ";
    echo " █████╗ ██████╗  ██████╗██╗  ██╗███████╗██╗███╗   ██╗███████╗████████╗██╗   ██╗███╗   ██╗███████╗██████╗ ";
    echo "██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║████╗  ██║██╔════╝╚══██╔══╝██║   ██║████╗  ██║██╔════╝██╔══██╗";
    echo "███████║██████╔╝██║     ███████║█████╗  ██║██╔██╗ ██║█████╗     ██║   ██║   ██║██╔██╗ ██║█████╗  ██████╔╝";
    echo "██╔══██║██╔══██╗██║     ██╔══██║██╔══╝  ██║██║╚██╗██║██╔══╝     ██║   ██║   ██║██║╚██╗██║██╔══╝  ██╔══██╗";
    echo "██║  ██║██║  ██║╚██████╗██║  ██║██║     ██║██║ ╚████║███████╗   ██║   ╚██████╔╝██║ ╚████║███████╗██║  ██║";
    echo "╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝";
    echo "                                                                                                        ";
}

# Instala o Paru (AUR Helper) se ainda não estiver instalado.
instalar_paru() {
    if command -v paru &>/dev/null; then
        info "O Paru já está instalado."
        return
    fi

    info "Instalando gerenciador de pacotes Paru..."
    cd "$DIR" || return
    git clone https://aur.archlinux.org/paru.git
    cd paru || return
    makepkg -si --noconfirm
    cd "$DIR" && rm -rf paru
}

# Instala o Yay (AUR Helper) se ainda não estiver instalado.
instalar_yay() {
    if command -v yay &>/dev/null; then
        info "O Yay já está instalado."
        return
    fi

    info "Instalando gerenciador de pacotes Yay..."
    cd "$DIR" || return
    git clone https://aur.archlinux.org/yay.git
    cd yay || return
    makepkg -si --noconfirm
    cd "$DIR" && rm -rf yay
}

# Modifica o /etc/pacman.conf para adicionar o chaotic-aur e habilitar o multilib.
modificar_pacman_conf() {
    info "Configurando /etc/pacman.conf..."
    if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
        echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null
        info "Seção [chaotic-aur] adicionada."
    else
        info "A seção [chaotic-aur] já existe."
    fi

    if grep -q '^#\[multilib\]' /etc/pacman.conf; then
        sudo sed -i '/^#\[multilib\]/{N;s/#//g}' /etc/pacman.conf
        info "Seção [multilib] descomentada."
    else
        info "A seção [multilib] já está habilitada."
    fi
    
    sudo pacman -Sy
}

# Adiciona o repositório Chaotic-AUR ao sistema.
adicionar_repo_chaotic() {
    info "Adicionando repositório Chaotic-AUR."
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
    modificar_pacman_conf
}

# Verifica se o diretório de cache do script existe e o cria se necessário.
verificar_diretorio_cache() {
    if [[ ! -d "$DIR" ]]; then
        mkdir -p "$DIR"
        info "Diretório $DIR criado com sucesso!"
    fi
}

# Menu para instalação de drivers gráficos.
instalar_drivers_graficos() {
    echo "---------------------------------------------"
    echo "|     Escolha sua placa de vídeo (GPU)      |"
    echo "---------------------------------------------"
    echo "1 - AMD"
    echo "2 - INTEL"
    echo "3 - NVIDIA"
    echo "q - Voltar"
    read -rp "Opção: " opcao
    case $opcao in
        1) instalar_pacotes "pacman" ${DRIVERS_GRAFICOS["AMD"]} ;;
        2) instalar_pacotes "pacman" ${DRIVERS_GRAFICOS["INTEL"]} ;;
        3) instalar_pacotes "pacman" ${DRIVERS_GRAFICOS["NVIDIA"]} ;;
        q) info "Voltando ao menu." ;;
        *) echo -e "${VERMELHO}Opção inválida.${SEM_COR}" ;;
    esac
}

# Gera uma nova chave GPG para o usuário.
criar_chave_gpg() {
    info "Iniciando a criação da chave GPG..."
    read -rp "Qual o tamanho da chave (ex: 4096)? " chave_tamanho
    read -rp "Adicione um comentário para a chave (ex: 'Chave para Github'): " chave_comentario
    read -rp "Defina um prazo de validade (ex: 2y, deixe em branco para nunca expirar): " chave_prazo

    gpg --batch --full-generate-key <<EOF
Key-Type: RSA
Key-Length: ${chave_tamanho:-4096}
Subkey-Type: RSA
Subkey-Length: ${chave_tamanho:-4096}
Name-Real: $USER
Comment: $chave_comentario
$( [ -n "$chave_prazo" ] && echo "Expire-Date: $chave_prazo" )
%no-protection
%commit
EOF
    [[ $? -ne 0 ]] && erro "Falha ao gerar a chave GPG."
    info "Chave GPG criada com sucesso! ID da chave:"
    gpg --list-keys --keyid-format LONG "$USER"
}

# Instala Zsh, Oh My Zsh e plugins.
instalar_zsh_e_plugins() {
    instalar_pacotes "pacman" "zsh"
    local oh_my_zsh_dir="$HOME/.oh-my-zsh"
    if [ ! -d "$oh_my_zsh_dir" ]; then
        info "Instalando o OH MY ZSH..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        info "OH MY ZSH já está instalado."
    fi
    local plugins_dir="$oh_my_zsh_dir/custom/plugins"
    [ ! -d "$plugins_dir/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git "$plugins_dir/zsh-autosuggestions"
    [ ! -d "$plugins_dir/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    info "Plugins instalados. Adicione 'zsh-autosuggestions' e 'zsh-syntax-highlighting' ao seu ~/.zshrc"
}

# Instala o tema DedSec para o GRUB.
instalar_tema_grub() {
    info "Instalando tema DedSec para o GRUB..."
    cd "$DIR" || return
    [ ! -d "$DIR/dedsec-grub-theme" ] && git clone --depth 1 https://gitlab.com/VandalByte/dedsec-grub-theme.git
    cd dedsec-grub-theme || return
    sudo python3 dedsec-theme.py --install
    cd "$DIR" && rm -rf dedsec-grub-theme
}

# Habilita serviços essenciais do systemd.
ativar_servicos_essenciais() {
    info "Ativando serviços (NetworkManager, sddm, bluetooth)..."
    sudo systemctl enable NetworkManager.service sddm.service bluetooth.service
    info "Serviços ativados para iniciar no próximo boot."
}

# Menu para instalação de um navegador web.
instalar_navegador() {
    echo "---------------------------------------------"
    echo "|         Escolha o seu Navegador           |"
    echo "---------------------------------------------"
    local i=1
    local opcoes=()
    for nome in "${!NAVEGADORES[@]}"; do
        echo "$i - $nome"; opcoes+=("$nome"); ((i++)); done
    echo "q - Voltar"
    read -rp "Opção: " opcao
    if [[ "$opcao" == "q" ]]; then return; fi
    if [[ "$opcao" =~ ^[0-9]+$ ]] && [ "$opcao" -ge 1 ] && [ "$opcao" -le ${#opcoes[@]} ]; then
        local navegador_selecionado=${opcoes[opcao-1]}
        local pacote=${NAVEGADORES[$navegador_selecionado]}
        instalar_pacotes "yay" "$pacote"
    else
        echo -e "${VERMELHO}Opção inválida.${SEM_COR}"
    fi
}

# Instala o Wallpaper Engine para KDE.
instalar_wallpaper_engine() {
    info "Instalando Wallpaper Engine para KDE."
    instalar_pacotes "pacman" "${WALLPAPER_ENGINE_DEPS[@]}"
    [[ $? -ne 0 ]] && erro "Falha ao instalar dependências. Abortando."
    cd "$DIR" || return
    git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git
    cd wallpaper-engine-kde-plugin || return
    git submodule update --init
    mkdir -p build && cd build
    cmake .. -DUSE_PLASMAPKG=ON || erro "Falha no cmake."
    make -j"$(nproc)" || erro "Falha na compilação."
    sudo make install || erro "Falha na instalação."
    info "Wallpaper Engine para KDE instalado! Reinicie a sessão para aplicar."
    cd "$DIR" && rm -rf wallpaper-engine-kde-plugin
}

# Menu para escolher e instalar uma interface gráfica.
escolher_interface() {
    echo "---------------------------------------------"
    echo "|   Escolha uma Interface Gráfica (DE)      |"
    echo "---------------------------------------------"
    echo "1) KDE Plasma"
    echo "2) GNOME"
    echo "3) XFCE"
    echo "4) Cinnamon"
    echo "5) I3wm (Window Manager)"
    echo "q) Voltar"
    read -rp "Digite o número da interface: " opcao
    case $opcao in
        1) instalar_pacotes "pacman" "${KDE_APP_INSTALL[@]}" ;;
        2) instalar_pacotes "pacman" "${GNOME_APP_INSTALL[@]}" ;;
        3) instalar_pacotes "pacman" "${XFCE_APP_INSTALL[@]}" ;;
        4) instalar_pacotes "pacman" "${CINNAMON_APP_INSTALL[@]}" ;;
        5) instalar_pacotes "pacman" "${I3WM_APP_INSTALL[@]}" ;;
        q) info "Voltando ao menu." ;;
        *) echo -e "${VERMELHO}Opção inválida.${SEM_COR}" ;;
    esac
}

# Instala um Kernel selecionado.
instalar_kernel() {
    local nome_pacote="${KERNELS[$1]}"
    info "Verificando o kernel $nome_pacote..."
    if ! pacman -Q "${nome_pacote%% *}" &>/dev/null; then
        if pacman -Si "$nome_pacote" &> /dev/null; then
            instalar_pacotes "pacman" "$nome_pacote"
        elif yay -Si "$nome_pacote" &> /dev/null; then
            instalar_pacotes "yay" "$nome_pacote"
        else
            echo -e "${VERMELHO}[ERRO] - O pacote $nome_pacote não foi encontrado.${SEM_COR}"
        fi
    else
        info "O kernel $nome_pacote já está instalado."
    fi
}

# Menu para escolher e instalar um Kernel.
menu_kernels() {
    echo "---------------------------------------------"
    echo "|      Escolha um Kernel para Instalar      |"
    echo "---------------------------------------------"
    for key in "${!KERNELS[@]}"; do echo "$key) ${KERNELS[$key]}"; done
    echo "q) Voltar"
    read -rp "Digite o número do kernel: " escolha
    if [[ "$escolha" == "q" ]]; then return; fi
    if [[ -n "${KERNELS[$escolha]}" ]]; then
        instalar_kernel "$escolha"
        info "Atualizando o GRUB..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo "Opção inválida."
    fi
}

# Instala a lista de aplicativos do AUR.
instalar_apps_yay() {
    info "Iniciando instalação de aplicativos padrão via YAY."
    instalar_pacotes "yay" "${YAY_APP_INSTALL[@]}"
}

# (NOVA FUNÇÃO) - Menu para instalar lojas de aplicativos.
instalar_lojas_app() {
    echo "---------------------------------------------"
    echo "|      Escolha uma Loja de Aplicativos      |"
    echo "---------------------------------------------"
    echo "1) Pamac (Loja do Manjaro)"
    echo "2) Octopi (Leve, baseada em Qt)"
    echo "q) Voltar"
    read -rp "Opção: " opcao
    case $opcao in
        1) instalar_pacotes "yay" "pamac-aur" "libpamac-aur" ;;
        2) instalar_pacotes "yay" "octopi" ;;
        q) info "Voltando ao menu." ;;
        *) echo -e "${VERMELHO}Opção inválida.${SEM_COR}" ;;
    esac
}

#-------------------------------------------| Menu Principal |-----------------------------------------------#

main_menu() {
  local todas_funcoes=(
      instalar_paru adicionar_repo_chaotic escolher_interface instalar_drivers_graficos 
      instalar_navegador menu_kernels instalar_zsh_e_plugins instalar_apps_yay 
      instalar_tema_grub criar_chave_gpg instalar_wallpaper_engine ativar_servicos_essenciais
      instalar_lojas_app
  )

  while true; do
    cabecalho
    echo "1) Instalar Paru (AUR Helper alternativo)"
    echo "2) Adicionar Repositório Chaotic-AUR"
    echo "3) Escolher e Instalar Interface Gráfica"
    echo "4) Instalar Drivers Gráficos"
    echo "5) Instalar Navegador"
    echo "6) Instalar outro Kernel"
    echo "7) Instalar ZSH e Plugins"
    echo "8) Instalar Programas Padrão (AUR/YAY)"
    echo "9) Instalar Tema DedSec para o GRUB"
    echo "10) Criar Chave GPG (para KWallet/Github)"
    echo "11) Instalar Wallpaper Engine (KDE)"
    echo "12) Ativar Serviços Essenciais (Rede, Bluetooth, SDDM)"
    echo "13) Instalar Lojas de Aplicativos (Pamac, Octopi)"
    echo "---------------------------------------------"
    echo "14) RODAR TUDO (Recomendado para primeira vez)"
    echo "q) Sair"

    read -rp "Escolha uma opção: " opcao

    case $opcao in
      1) instalar_paru ;;
      2) adicionar_repo_chaotic ;;
      3) escolher_interface ;;
      4) instalar_drivers_graficos ;;
      5) instalar_navegador ;;
      6) menu_kernels ;;
      7) instalar_zsh_e_plugins ;;
      8) instalar_apps_yay ;;
      9) instalar_tema_grub ;;
      10) criar_chave_gpg ;;
      11) instalar_wallpaper_engine ;;
      12) ativar_servicos_essenciais ;;
      13) instalar_lojas_app ;;
      14)
        for funcao in "${todas_funcoes[@]}"; do
            "$funcao"
            if [[ $? -ne 0 ]]; then
                read -rp "A função $funcao falhou. Pressione ENTER para continuar com as próximas ou CTRL+C para sair."
            fi
        done
        info "Instalação completa!"
        ;;
      q) echo "Saindo..."; exit 0 ;;
      *) echo "Opção inválida. Tente novamente."; sleep 1 ;;
    esac
    
    # Pausa antes de limpar a tela e mostrar o menu novamente.
    if [[ "$opcao" != "q" ]]; then
        read -rp "Pressione ENTER para voltar ao menu."
    fi
  done
}

#-------------------------------------------| Execução |-----------------------------------------------#

# Função principal que inicia o script.
main() {
    verificar_diretorio_cache
    preparar_sistema
    main_menu
}

# Chama a função principal para iniciar o script.
main
