#!/bin/bash
# Arch + Hyprland ARM setup script for M1 Asahi Linux
# User-friendly version with ASCII banner, password pauses, and auto-launch

set -e

# --- ASCII Banner ---
clear
cat << "EOF"
                       $$\       $$\ $$\                               
                     $$ |      $$ |\__|                              
$$\    $$\  $$$$$$\  $$ |      $$ |$$\ $$$$$$$\  $$\   $$\ $$\   $$\ 
\$$\  $$  |$$  __$$\ $$ |      $$ |$$ |$$  __$$\ $$ |  $$ |\$$\ $$  |
 \$$\$$  / $$$$$$$$ |$$ |      $$ |$$ |$$ |  $$ |$$ |  $$ | \$$$$  / 
  \$$$  /  $$   ____|$$ |      $$ |$$ |$$ |  $$ |$$ |  $$ | $$  $$<  
   \$  /   \$$$$$$$\ $$ |      $$ |$$ |$$ |  $$ |\$$$$$$  |$$  /\$$\ 
    \_/     \_______|\__|      \__|\__|\__|  \__| \______/ \__/  \__|
                                                                     
EOF


# --- Function to pause for sudo ---
pause_sudo() {
    echo "You may be asked for your password..."
    sudo -v  # asks for password, pauses until entered
}

# --- 1. Update system ---
pause_sudo
echo "Updating system..."
sudo pacman -Syu --noconfirm

# --- 2. Install essential packages ---
pause_sudo
echo "Installing essential packages..."
sudo pacman -S --needed --noconfirm \
  base-devel git xorg-server xorg-xinit xorg-xrandr xorg-xinput mesa mesa-demos \
  wayland wayland-protocols wlroots \
  mako kitty alacritty swaybg networkmanager pulseaudio pavucontrol \
  ttf-dejavu ttf-liberation

# --- 3. Enable NetworkManager ---
pause_sudo
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# --- 4. Install yay ---
if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay
    pause_sudo
    makepkg -si --noconfirm
    cd ~
    rm -rf ~/yay
fi

# --- 5. Install Hyprland dependencies via AUR ---
echo "Installing Hyprland dependencies via AUR..."
yay -S --noconfirm hyprland-git waybar-git wlogout-git

# --- 6. Clone binnewbs/arch-hyprland configs ---
echo "Cloning binnewbs/arch-hyprland..."
git clone https://github.com/binnewbs/arch-hyprland.git ~/arch-hyprland

# --- 7. Backup existing configs and copy Hyprland configs ---
echo "Backing up existing configs..."
mkdir -p ~/.config_backup_$(date +%s)
if [ -d ~/.config ]; then
    mv ~/.config ~/.config_backup_$(date +%s)
fi

echo "Copying Hyprland configs..."
cp -r ~/arch-hyprland/* ~/.config/

# --- 8. Setup .xinitrc ---
echo "Setting up .xinitrc..."
cat > ~/.xinitrc <<'EOF'
#!/bin/sh
exec Hyprland
EOF
chmod +x ~/.xinitrc

# --- 9. Install user dotfiles ---
echo "Cloning your dotfiles..."
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles

echo "Installing dotfiles..."
if [ -d ~/dotfiles/.config ]; then
    mkdir -p ~/.config
    cp -r ~/dotfiles/.config/* ~/.config/
fi

for file in .bashrc .zshrc .vimrc .gitconfig; do
    if [ -f ~/dotfiles/$file ]; then
        cp ~/dotfiles/$file ~/
    fi
done

# --- 10. Auto-launch Hyprland with a message ---
echo
echo "=================================="
echo "Booting into your new OS in 5 seconds..."
echo "Press Ctrl+C to cancel."
echo "=================================="
sleep 5
echo "Starting Hyprland..."
startx
