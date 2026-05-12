#!/usr/bin/env bash
set -e

if [ ! -f "runimage-x86_64" ]; then
    curl -OL "https://github.com/VHSgunzo/runimage/releases/download/continuous/runimage-x86_64"
    chmod +x runimage-x86_64
fi

run_install() {
    set -e
    INSTALL_PKGS=(
        wine-staging winetricks-git alsa-lib alsa-plugins cups dosbox ffmpeg giflib
        gnutls gst-plugins-base-libs gtk3 lib32-alsa-lib lib32-alsa-plugins lib32-giflib lib32-gnutls
        lib32-gtk3 lib32-libcups lib32-libpulse lib32-libva lib32-libxcomposite lib32-libxinerama lib32-ocl-icd
        lib32-sdl2-compat lib32-v4l-utils lib32-vulkan-icd-loader libgphoto2 libpulse libva
        libxcomposite libxinerama ocl-icd samba sane sdl2-compat v4l-utils vulkan-icd-loader
        steam pipewire-alsa pipewire-pulse wget brave-bin
    )

    sudo sed -i 's/^#Server/Server/' /etc/pacman.d/blackarch-mirrorlist
    rim-update
    pac --needed --noconfirm -S "${INSTALL_PKGS[@]}"
    pac -S prismlauncher --noconfirm --assume-installed java-runtime
    rim-shrink --all
    ln -sf /var/host/bin/xdg-open /usr/bin/xdg-open
    
    cat <<- 'EOF' > "$RUNDIR/config/Run.rcfg"
RIM_SHARE_ICONS="${RIM_SHARE_ICONS:=1}"
RIM_SHARE_FONTS="${RIM_SHARE_FONTS:=1}"
RIM_SHARE_THEMES="${RIM_SHARE_THEMES:=1}"
RIM_HOST_XDG_OPEN="${RIM_HOST_XDG_OPEN:=1}"
RIM_SYS_NVLIBS="${RIM_SYS_NVLIBS:=1}"
EOF

    rim-build -s -z -c 3 -b 1M runimage
}

export -f run_install

RIM_OVERFS_MODE=1 RIM_NO_NVIDIA_CHECK=1 ./runimage-x86_64 bash -c run_install

# Output the package versions to a text file on the host runner
echo "Exporting package list..."
./runimage pacman -Q > package_versions.txt
