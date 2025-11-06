#!/bin/bash
# Arch + Hyprland ARM setup script for M1 Asahi Linux
# GitHub-ready version
set -e

# --- 1. Update system ---
echo "Updating system..."
sudo pacman -Syu --noconfirm

# --- 2. Install essential packages ---
echo "Installing essential packages..."
sudo pacman -S --needed --noconfirm \
  base-devel git xorg-server xorg-xinit xorg-xrandr xorg-xinput mesa mesa-demos \
  wayland wayland-protocols wlroots \
  mako kitty alacritty swaybg networkmanager pulseaudio pavucontrol \
  ttf-dejavu ttf-liberation

# --- 3. Enable NetworkManager ---
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# --- 4. Install yay (AUR helper) ---
if ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay
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
echo "Installing your dotfiles..."
if [ -d ./dotfiles/.config ]; then
    mkdir -p ~/.config
    cp -r ./dotfiles/.config/* ~/.config/
fi

for file in .bashrc .zshrc .vimrc .gitconfig; do
    if [ -f ./dotfiles/$file ]; then
        cp ./dotfiles/$file ~/
    fi
done

echo "Setup complete! You can now start Hyprland with:"
echo "  startx"
