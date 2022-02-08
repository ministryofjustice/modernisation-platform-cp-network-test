FROM archlinux:latest

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN useradd --uid 1000 -m nettest && usermod -aG wheel,adm nettest

WORKDIR /
COPY package*.json app.js ./

RUN set -x \
	&& pacman -Syyu --needed --noconfirm \
    && pacman -S --needed --noconfirm nodejs npm which awk git base-devel \
       nano \
       ansible curl traceroute nmap vulscan \
    && npm install

USER 1000
ENV HOME /home/nettest
EXPOSE 3000
CMD ["node", "app.js"]
