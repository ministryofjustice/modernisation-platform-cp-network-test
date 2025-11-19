FROM archlinux:latest

# Create user
RUN useradd --uid 1000 -m nettest && usermod -aG wheel,adm nettest

WORKDIR /
COPY package*.json app.js ./

# Install base packages
RUN set -x \
    && pacman -Syyu --noconfirm \
    && pacman -S --needed --noconfirm \
       nodejs npm which awk git base-devel nano ansible curl traceroute nmap \
       openbsd-netcat iperf3 inetutils \
    && npm install \
    && echo 'nettest ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/20-nettest-nopasswd \
    && chmod 0440 /etc/sudoers.d/20-nettest-nopasswd \
    && rm -rf /var/cache/pacman/pkg/*

USER nettest
ENV HOME=/home/nettest

# Install AUR helper and tcptraceroute
RUN set -x \
    && mkdir $HOME/h-aur \
    && git clone https://aur.archlinux.org/trizen.git $HOME/h-aur \
    && cd $HOME/h-aur && makepkg -si --needed --noconfirm \
    && trizen -S --needed --noconfirm --noedit tcptraceroute

# Install vulscan manually
RUN set -x \
    && mkdir -p $HOME/nmap-scripts \
    && git clone https://github.com/scipag/vulscan.git $HOME/nmap-scripts/vulscan \
    && sudo cp -r $HOME/nmap-scripts/vulscan /usr/share/nmap/scripts/

EXPOSE 3000
CMD ["node", "app.js"]
