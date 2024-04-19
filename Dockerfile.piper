FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

# ------------------------------------------------------------------------------
# Create a non-root user to use if preferred
# - see https://aka.ms/vscode-remote/containers/non-root-user.
# ------------------------------------------------------------------------------
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
  && apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# ------------------------------------------------------------------------------
# Install zsh and oh-my-zsh
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -yq zsh sudo curl wget jq vim git-core gnupg locales && apt-get clean \
&& sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true \
&& sudo chsh -s /bin/zsh

RUN apt-get install build-essential -y
# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************
# [Optional] Set the default user. Omit if you want to keep the default as root.
# If specified non-root user, add sudo when running e.g. apt-get
USER $USERNAME
RUN sudo usermod -aG sudo $USERNAME

# Switch to zsh shell; note this applies to all RUN commands after
SHELL ["/bin/zsh", "-c"]

# ------------------------------------------------------------------------------
# Install zsh and oh-my-zsh
# ------------------------------------------------------------------------------
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true \
&& sudo chsh -s /bin/zsh

# ------------------------------------------------------------------------------
# Install miniconda
# ------------------------------------------------------------------------------
RUN sudo apt-get update && sudo apt-get install -y curl git
# credits: @pangyuteng
# refer to: https://gist.github.com/pangyuteng/f5b00fe63ac31a27be00c56996197597
# Use the above args during building https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# Choices
# PLATFORM: Linux, MacOSX, or Windows
# OS_TYPE : x86_64, arm64, ppc64le, s390x, or x86, armv7l
ARG CONDA_VER=latest
ARG PLATFORM=Linux
ARG OS_TYPE=x86_64
# Install miniconda to /miniconda
WORKDIR /home/${USERNAME}
RUN curl -LO "http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh"
RUN bash Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh -p ./miniconda -b
RUN rm Miniconda3-${CONDA_VER}-Linux-${OS_TYPE}.sh
ENV PATH=/home/${USERNAME}/miniconda/bin:${PATH}
RUN conda update -y conda
RUN conda init zsh

# copy files over
ARG DOCKING_DIR=/home/vscode/docking
RUN mkdir -p ${DOCKING_DIR}
COPY --chown=1000:1000 ./assets/*.tar.gz ${DOCKING_DIR}/assets/
COPY --chown=1000:1000 ./abagdocking ${DOCKING_DIR}/abagdocking
COPY --chown=1000:1000 ./setup.py ${DOCKING_DIR}/setup.py

# create environment - abagdocking (py310) and piper-py27
COPY --chown=1000:1000 ./assets/create-env.sh ${DOCKING_DIR}/assets/create-env.sh
WORKDIR ${DOCKING_DIR}/assets
RUN chmod 777 create-env.sh && zsh create-env.sh

# install bioplib, bioptools, Megadock (both cpu and gpu)
COPY --chown=1000:1000 ./assets/install.sh ${DOCKING_DIR}/assets/install.sh
WORKDIR ${DOCKING_DIR}/assets
RUN chmod 777 install.sh && zsh install.sh

# install piper
COPY --chown=1000:1000 ./assets/piper.tar.gz ${DOCKING_DIR}/assets/piper.tar.gz
COPY --chown=1000:1000 ./assets/install-piper.sh ${DOCKING_DIR}/assets/install-piper.sh
WORKDIR ${DOCKING_DIR}/assets
RUN chmod 777 install-piper.sh && zsh install-piper.sh

# entrypoint script
COPY --chown=1000:1000 ./scripts/run-piper.sh ${DOCKING_DIR}/scripts/run-piper.sh

# clean up
WORKDIR ${DOCKING_DIR}/assets
RUN rm *.tar.gz

# ------------------------------------------------------------------------------
# End of base image
# ------------------------------------------------------------------------------
ENV PIPER_SCRIPT=${DOCKING_DIR}/abagdocking/piper/run_piper.py \
  PIPER_INDIR=${DOCKING_DIR}/input \
  PIPER_OUTDIR=${DOCKING_DIR}/output \
  ENTRY_SCRIPT=${DOCKING_DIR}/scripts/run-piper.sh \
  DATADIR=/opt/bioplib/data
RUN mkdir -p ${PIPER_INDIR} ${PIPER_OUTDIR}
WORKDIR ${DOCKING_DIR}
ENTRYPOINT [ "zsh", "scripts/run-piper.sh" ]