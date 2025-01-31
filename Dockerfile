FROM ubuntu:24.04
LABEL maintainer="maxmilio@kiv.zcu.cz" \
      org.opencontainers.image.source="hhttps://github.com/maxotta/kiv-cloudlet-k8s-dev-container"

# Set the default workspace directory   
ARG WORKSPACE_DIR=/workspace
# Path to the configuration directory
ARG CONFIG_DIR=/etc/cloudlet-config

ENV DEBIAN_FRONTEND noninteractive

# Prepare for the installation of external repositories
RUN set -uex; \
    apt-get update ; \
    apt-get -y install gnupg software-properties-common ca-certificates curl apt-transport-https ; \
    mkdir -p /etc/apt/keyrings

# Install Python toolset, Ansible and Docker libraries
RUN apt-get -y install git python3 python3-pip pipenv

# Install Ansible
RUN add-apt-repository --yes --update ppa:ansible/ansible
RUN apt update
RUN apt-get -y install ansible
RUN apt-get -y install ansible-lint

# Install OpenVPN client necessary to connect to the RPi cloudlet
RUN apt-get -y install openvpn

# Install Kubernetes tools
RUN mkdir -p -m 755 /etc/apt/keyrings
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
RUN chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
RUN echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
RUN chmod 644 /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get -y install kubectl
RUN apt-get -y install kubeadm

# Install Helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update
RUN apt-get -y install helm

# Install other fancy stuff
RUN apt-get -y install inetutils-ping
RUN apt-get -y install apt-utils
RUN apt-get -y install cowsay
RUN apt-get -y install lolcat

COPY init-dev-container.sh /etc
COPY help.txt /etc

RUN echo '. /etc/init-dev-container.sh' >> /root/.bashrc
RUN echo 'LANG=C.UTF-8' > /etc/default/locale

WORKDIR ${WORKSPACE_DIR}

VOLUME [${WORKSPACE_DIR}, ${CONFIG_DIR}]

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV CONFIG_DIR ${CONFIG_DIR}
ENV OPENVPN_CONFIG ${CONFIG_DIR}/OpenVPN-Config.ovpn
ENV ENV_CONFIG ${CONFIG_DIR}/.env
ENV SHELL /bin/bash
ENV ANSIBLE_HOST_KEY_CHECKING False
ENV LC_ALL C.UTF-8

# Prevent the container to exit
CMD [ "sleep", "infinity" ]
