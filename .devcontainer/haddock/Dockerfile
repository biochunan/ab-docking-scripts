FROM centos:7

# Arguments defined in devcontainer.json
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install Common Tools
RUN yum -y update && \
    yum -y install sudo git zsh wget curl vim jq which nano make gcc-c++ openssl-devel bzip2-devel libffi-devel && \
    yum clean all

# Create a non-root user to use if preferred
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    # [Optional] Add sudo support for the non-root user
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Install oh-my-zsh
USER $USERNAME
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# Setting the ENTRYPOINT to init.sh will configure non-root access to
# the Docker socket if "overrideCommand": false is set in devcontainer.json.
USER root
COPY init.sh /usr/local/share/init.sh
RUN chmod +x /usr/local/share/init.sh
ENTRYPOINT [ "/usr/local/share/init.sh" ]
CMD ["sleep", "infinity"]
