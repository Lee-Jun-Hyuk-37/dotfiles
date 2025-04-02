# docker build --no-cache --platform linux/amd64 -t my-image-name .
FROM python:3.11.11-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt update && apt install -y \
    vim \
    htop \
    # iotop \
    # nethogs \
    # iftop \
    procps \
    git \
    curl \
    && apt clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vim/colors
COPY .vim/colors/habamax.vim /root/.vim/colors/habamax.vim
COPY .vimrc /root/.vimrc
RUN curl -fLo /root/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN vim +'PlugInstall --sync' +qa

RUN pip install --no-cache-dir gpustat

RUN mkdir jh_workspace

WORKDIR /root/jh_workspace
