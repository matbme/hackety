FROM debian:unstable
LABEL maintainer="Mateus Melchiades"

ARG DEBIAN_FRONTEND=noninteractive

# Install: dependencies, clean: apt cache, remove dir: cache, man, doc, change mod time of cache dir.
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
       software-properties-common \
       rsyslog systemd systemd-cron sudo gpg zstd rsync \
       linux-image-generic \
       systemd-sysv \
       grub-efi-amd64

# Setup vanilla snapshot repository
RUN rm -f /etc/apt/sources.list.d/debian.sources
RUN echo 'deb [arch=amd64] http://repo.vanillaos.org/ sid main' > /etc/apt/sources.list.d/vanilla-base.list
COPY os/etc/config/archives/vanilla-main.key /tmp/
RUN cat /tmp/vanilla-main.key | gpg --dearmor -o /etc/apt/keyrings/vanilla-main-keyring.gpg

# Setup Vanilla OBS repository
COPY os/etc/config/archives/vanilla.key /tmp/
RUN cat /tmp/vanilla.key | gpg --dearmor -o /etc/apt/keyrings/vanilla-keyring.gpg
COPY os/etc/config/archives/vanilla.list /etc/apt/sources.list.d/
RUN apt-get update \
    && apt-get install -y \
    vanilla-base-meta \
    vanilla-base-desktop \
    vanilla-backgrounds \
    switcheroo-control \
    epiphany-browser \
    gnome-calculator \
    gnome-music \
    gnome-photos \
    gnome-software \
    gnome-disk-utility \
    gnome-sushi \
    epiphany-browser \
    evince \
    yelp \
    file-roller \
    eog \
    orca \
    totem


RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# These symlinks break during the installation process, fix them here
RUN ln -sf /usr/lib/os-release /etc/os-release
RUN ln -sf /proc/self/mounts /etc/mtab

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]

