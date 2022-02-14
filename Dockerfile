FROM archlinux:latest

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd --uid 1000 -m nettest && usermod -aG wheel,adm nettest

WORKDIR /
COPY package*.json app.js ./

RUN set -x \
	&& pacman -Syyu --needed --noconfirm \
    && pacman -S --needed --noconfirm nodejs npm which awk git base-devel \
       nano \
       ansible curl traceroute nmap vulscan gnu-netcat \
    && npm install \
    && echo 'nettest ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/20-nettest-nopasswd \
    && chmod 0440 /etc/sudoers.d/20-nettest-nopasswd

USER 1000
ENV HOME /home/nettest

RUN set -x \
	&& mkdir $HOME/h-aur \
    && git clone https://aur.archlinux.org/trizen.git $HOME/h-aur \
    && (cd $HOME/h-aur && makepkg -si --needed --noconfirm) \
    && trizen --version \
    && trizen -S --needed --noconfirm --noedit fing tcptraceroute

EXPOSE 3000
CMD ["node", "app.js"]
