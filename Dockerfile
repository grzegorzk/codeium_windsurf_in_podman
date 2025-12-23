ARG GROUP_ID=1001
ARG USER_ID=1001

ARG ARCH_BASE_IMAGE

FROM docker.io/${ARCH_BASE_IMAGE} AS x11_arch

RUN pacman -Sy --disable-download-timeout --noconfirm \
        archlinux-keyring \
    && pacman-key --refresh-keys \
    && pacman -Sy --disable-download-timeout --noconfirm \
        base-devel \
        binutils \
        fakeroot \
        firefox \
        git \
        gnome-keyring \
        mesa \
        openssh \
        sudo \
        procps \
        pulseaudio \
        pulseaudio-alsa \
        python \
        xorg-server \
        xorg-apps \
    && /bin/bash /root/skim.sh

ARG WITH_CUDA

RUN [ -n "${WITH_CUDA}" ] \
    && pacman -Sy --disable-download-timeout --noconfirm \
        nvidia \
        cuda \
        cudnn \
    || echo "Not installing CUDA"

RUN sed -i -- 's/#[ ]*\(%wheel[ ]*ALL[ ]*=[ ]*([ ]*ALL[ ]*:[ ]*ALL[ ]*)[ ]*NOPASSWD[ ]*:[ ]*ALL\)$/\1/gw /tmp/sed.done' /etc/sudoers \
    && [ -z "$(cat /tmp/sed.done | wc -l)" ] && echo "Failed to enable sudo for wheel group" && exit 1 \
    || echo "Enabled sudo for wheel group" && rm /tmp/sed.done

ARG GROUP_ID
ARG USER_ID
ARG USER_NAME

RUN groupadd -g $GROUP_ID $USER_NAME \
    && useradd -u $USER_ID -g $GROUP_ID -G wheel -m $USER_NAME

USER $USER_NAME

RUN cd /tmp \
    && git clone https://github.com/trizen/trizen.git \
    && cd trizen/archlinux \
    && makepkg -si --noconfirm \
    && cd / \
    && rm -r /tmp/trizen

RUN cd /tmp \
    && trizen -S --noconfirm \
        python311 \
        python312 \
        windsurf \
        windsurf-features \
        windsurf-marketplace \
    && rm -rf /tmp/windsurf* \
    && trizen -Scc --aur --noconfirm

USER root

RUN sed -i -- 's/^[ ]*\(%wheel[ ]*ALL[ ]*=[ ]*([ ]*ALL[ ]*:[ ]*ALL[ ]*)[ ]*NOPASSWD[ ]*:[ ]*ALL\)$/# \1/gw /tmp/sed.done' /etc/sudoers \
   && [ -z "$(cat /tmp/sed.done | wc -l)" ] && echo "Failed to disable sudo for wheel group" && exit 1 \
   || echo "Disabled sudo for wheel group" && rm /tmp/sed.done

USER $USER_NAME

COPY docker_files/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD []
