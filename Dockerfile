FROM fedora

LABEL 'maintainer=Furutanian <furutanian@gmail.com>'

ARG TZ
ARG http_proxy
ARG https_proxy

RUN set -x \
	&& dnf install -y \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
	&& dnf install -y \
		cronie \
		ruby \
		ffmpeg \
		git \
		procps-ng \
		net-tools \
	&& rm -rf /var/cache/dnf/* \
	&& dnf clean all

RUN systemctl enable crond

## git clone radiorec しておくこと
COPY radiorec /root/radiorec

# Dockerfile 中の設定スクリプトを抽出するスクリプトを出力、実行
COPY Dockerfile .
RUN echo $'\
cat Dockerfile | sed -n \'/^##__BEGIN0/,/^##__END0/p\' | sed \'s/^#//\' > startup.sh\n\
' > extract.sh && bash extract.sh

# docker-compose up の最後に実行される設定スクリプト
##__BEGIN0__startup.sh__
#
#	ln -fs ../usr/share/zoneinfo/$TZ /etc/localtime
#	crontab /root/radiorec/crontab
#
##__END0__startup.sh__

