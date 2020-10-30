ARG BASE_IMAGE=alpine:3.12
FROM ${BASE_IMAGE}

# Install runtime deps.
RUN set -xe; \
    apk add --update  --no-cache --virtual .runtime-deps \
        bash \
        ca-certificates \
        certbot \
        coreutils \
        curl \
        docker \
        docker-compose \
        gawk \
        gettext \
        git \
        grep \
        htop \
        jq \
        krb5-libs \
        less \
        libffi \
        libgcc \
        libintl \
        libstdc++ \
        lttng-ust \
        make \
        openssh-client \
        openssl \
        perl \
        postgresql-client \
        procps \
        py3-pip \
        python3 \
        sed \
        shadow \
        su-exec \
        sudo \
        the_silver_searcher \
        tmux \
        tzdata \
        userspace-rcu \
        vim \
        wget \
        zsh;

# Install additional pre-built packages
ARG CIRCLE_CI_CLI_VERSION=0.1.8599
ARG FLY_VERSION=6.0.0
ARG K6_VERSION=v0.26.2
ARG KOPS_VERSION=v1.17.0-beta.1
ARG KUBECTL_VERSION=v1.18.0
ARG LEGO_VERSION=3.8.0
ARG PACKER_VERSION=1.5.5
ARG SPIN_VERSION=1.14.0
ARG STARSHIP_VERSION=v0.46.2
ARG TERRAFORM_DOCS_VERSION=v0.9.1
ARG TERRAFORM_VERSION=0.12.24
ARG TFLINT_VERSION=v0.15.3
RUN set -xe; \
    curl -fSL https://github.com/segmentio/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64 -o /usr/local/bin/terraform-docs; \
    chmod 0755 /usr/local/bin/terraform-docs; \
    curl -fSL https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip -o /tmp/tflint.zip; \
    unzip /tmp/tflint.zip; \
    rm /tmp/tflint.zip; \
    mv tflint /usr/local/bin/; \
    chmod 0755 /usr/local/bin/tflint; \
    curl -fSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip; \
    unzip /tmp/terraform.zip; \
    rm /tmp/terraform.zip; \
    mv terraform /usr/local/bin; \
    chmod 0755 /usr/local/bin/terraform; \
    curl -fSL https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -o /tmp/packer.zip; \
    unzip /tmp/packer.zip; \
    rm /tmp/packer.zip; \
    mv packer /usr/local/bin/packer; \
    chmod 0755 /usr/local/bin/packer; \
    curl -fSL https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-x86_64-unknown-linux-musl.tar.gz -o /tmp/starship.tar.gz; \
    tar xfv /tmp/starship.tar.gz; \
    rm /tmp/starship.tar.gz; \
    mv starship /usr/local/bin/; \
    chmod 0755 /usr/local/bin/starship; \
    curl -fSL git.io/antigen -o /usr/local/bin/antigen.zsh; \
    curl -fSL https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz -o /tmp/kubectl.tar.gz; \
    tar xfv /tmp/kubectl.tar.gz; \
    rm /tmp/kubectl.tar.gz; \
    mv kubernetes/client/bin/kubectl /usr/local/bin/; \
    chmod 0755 /usr/local/bin/kubectl; \
    rm -rf kubernetes; \
    curl -fSL https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 -o /usr/local/bin/kops; \
    chmod 0755 /usr/local/bin/kops; \ 
    curl -fSL https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/fly-${FLY_VERSION}-linux-amd64.tgz -o /tmp/fly.tgz; \
    tar xfv /tmp/fly.tgz; \
    rm /tmp/fly.tgz; \
    mv fly /usr/local/bin/; \
    chmod 0755 /usr/local/bin/fly; \
    curl -fSL https://storage.googleapis.com/spinnaker-artifacts/spin/${SPIN_VERSION}/linux/amd64/spin -o /usr/local/bin/spin; \
    chmod 0755 /usr/local/bin/spin; \
    curl -fSL https://github.com/loadimpact/k6/releases/download/${K6_VERSION}/k6-${K6_VERSION}-linux64.tar.gz -o /tmp/k6-${K6_VERSION}-linux64.tar.gz; \
    tar xfv /tmp/k6-${K6_VERSION}-linux64.tar.gz; \
    rm /tmp/k6-${K6_VERSION}-linux64.tar.gz; \
    mv k6-${K6_VERSION}-linux64/k6 /usr/local/bin/; \
    rm -rf k6-${K6_VERSION}-linux64; \
    chmod 0755 /usr/local/bin/k6; \
    curl -fSL https://github.com/CircleCI-Public/circleci-cli/releases/download/v${CIRCLE_CI_CLI_VERSION}/circleci-cli_${CIRCLE_CI_CLI_VERSION}_linux_amd64.tar.gz -o /tmp/circleci-cli_${CIRCLE_CI_CLI_VERSION}_linux_amd64.tar.gz; \
    tar xfv /tmp/circleci-cli_${CIRCLE_CI_CLI_VERSION}_linux_amd64.tar.gz; \
    rm /tmp/circleci-cli_${CIRCLE_CI_CLI_VERSION}_linux_amd64.tar.gz; \
    mv circleci-cli_${CIRCLE_CI_CLI_VERSION}_linux_amd64/circleci /usr/local/bin; \
    chmod 0755 /usr/local/bin/circleci; \
    rm -rf circleci-cli_${CIRCLE_CI_CLI_VERSION}_linux_amd64; \
    curl -fSL https://github.com/go-acme/lego/releases/download/v${LEGO_VERSION}/lego_v${LEGO_VERSION}_linux_amd64.tar.gz -o /tmp/lego_v${LEGO_VERSION}_linux_amd64.tar.gz; \
    tar xfv /tmp/lego_v${LEGO_VERSION}_linux_amd64.tar.gz; \
    rm /tmp/lego_v${LEGO_VERSION}_linux_amd64.tar.gz; \
    rm LICENSE CHANGELOG.md; \
    mv lego /usr/local/bin; \
    chmod 0755 /usr/local/bin/lego;


# Build additional packages
ARG AZURE_CLI_VERSION=2.8.0
ARG GIT_CRYPT_VERSION=master
ARG KIND_VERSION=v0.7.0
ARG TERRAFORM_LSP_VERSION=0.0.10
RUN set -xe; \
    cd /tmp; \
    apk add --update  --no-cache --virtual .build-deps \
        alpine-sdk \
        go \
        libffi-dev \
        musl-dev \
        openssl-dev \
        postgresql-dev \
        python3-dev; \
    pip3 install --upgrade pip --no-cache-dir; \
    pip3 install awscli --no-cache-dir --ignore-installed distlib; \
    pip3 install ansible --no-cache-dir; \
    pip3 install psycopg2 --no-cache-dir; \
    pip3 install pre-commit --no-cache-dir; \
    pip3 install mkdocs --no-cache-dir; \
    pip3 install mkdocs-material --no-cache-dir; \
    pip3 install azure-cli=="${AZURE_CLI_VERSION}" --no-cache-dir; \
    cd /tmp; \
    git clone https://github.com/awslabs/git-secrets.git; \
    cd git-secrets; \
    make install; \
    cd /tmp; \
    rm -rf git-secrets; \
    go get github.com/pcarrier/gauth; \
    go get github.com/lucagrulla/cw; \
    go get github.com/aykamko/tag; \
    GO111MODULE="on" go get sigs.k8s.io/kind@${KIND_VERSION}; \
    mv /root/go/bin/gauth /usr/local/bin/; \
    mv /root/go/bin/cw /usr/local/bin/; \
    mv /root/go/bin/tag /usr/local/bin/; \
    mv /root/go/bin/kind /usr/local/bin/; \
    git clone https://github.com/AGWA/git-crypt.git; \
    cd git-crypt; \
    git checkout ${GIT_CRYPT_VERSION}; \
    make; \
    make install PREFIX=/usr/local; \
    cd /tmp; \
    rm -rf /tmp/git-crypt; \
    mkdir -p /root/.bin; \
    git clone https://github.com/juliosueiras/terraform-lsp.git; \
    cd terraform-lsp; \
    GO111MODULE=on go mod download; \
    make; \
    make copy; \
    cp /root/.bin/terraform-lsp /usr/local/bin/; \
    chmod 0755 /usr/local/bin/terraform-lsp; \
    cd /tmp; \
    rm -rf terraform-lsp; \
    rm -rf /root/go; \
    rm -rf /root/.bin; \
    apk del .build-deps; \
    mkdir -p /usr/local/share/zsh/site-functions; \
    /usr/local/bin/kind completion zsh > /usr/local/share/zsh/site-functions/_kind;

# Copy our entrypoint into the container.
COPY ./runtime-assets /

# Create a user for use with vscode
ARG DOCKER_GID="1010"
ARG DOCKER_GROUP="synapse"
ARG DOCKER_UID="1010"
ARG DOCKER_USER="synapse"
RUN set -xe; \
    if ! $(id -g "$DOCKER_GROUP" 2>/dev/null); then \
		addgroup -g ${DOCKER_GID} -S ${DOCKER_GROUP}; \
	fi; \
	adduser -u ${DOCKER_UID} -S -k /etc/skel -h /home/${DOCKER_USER} -s /bin/zsh -G ${DOCKER_GROUP} ${DOCKER_USER} ;\
	echo 'Set disable_coredump false' >>/etc/sudo.conf; \
	echo "${DOCKER_USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/${DOCKER_USER}; \
	chmod 0440 /etc/sudoers.d/${DOCKER_USER}; \
    mkdir -p /var/run; \
	touch /var/run/docker.sock; \
    mkdir -p /home/${DOCKER_USER}/.vscode-server/extensions; \
    mkdir -p /home/${DOCKER_USER}/.vscode-server-insider/extensions; \
    mkdir -p /home/"${DOCKER_USER}"/.vscode-server/extensions/mauve.terraform-1.4.0/lspbin; \
    ln -sf /usr/local/bin/terraform-lsp /home/"${DOCKER_USER}"/.vscode-server/extensions/mauve.terraform-1.4.0/lspbin/terraform-lsp; \
    chown -R "${DOCKER_USER}":"${DOCKER_GROUP}" /home/${DOCKER_USER}

# Labels / Metadata.
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
LABEL \
    org.opencontainers.image.authors="James Brink <james@synapsestudios.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="Synapse Studios DevOps ToolBox" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="https://github.com/synapsestudios/devops-toolbox" \
    org.opencontainers.image.title="toolbox" \
    org.opencontainers.image.vendor="synapsestudios.com" \
    org.opencontainers.image.version="${VERSION}"

# Setup our environment variables.
ENV \
    AWS_ACCESS_KEY_ID="" \
    AWS_DEFAULT_REGION="us-west-2" \
    AWS_MFA_PASSWORD="" \
    AWS_PROFILE="default" \
    AWS_SECRET_ACCESS_KEY="" \
    DOCKER_GID="${DOCKER_GID}" \
    DOCKER_GROUP="${DOCKER_GROUP}" \
    DOCKER_UID="${DOCKER_UID}" \
    DOCKER_USER="${DOCKER_USER}" \
    GIT_CRYPT_KEY="" \
    GIT_EMAIL="email@example.com" \
    GIT_REPOS="" \
    GIT_USERNAME="myusername" \
    PATH="/usr/local/bin:$PATH" \
    SPINNAKER_ACCESS_TOKEN="" \
    SPINNAKER_ENDPOINT="" \
    SPINNAKER_OAUTH_CLIENT_ID="" \
    SPINNAKER_OAUTH_CLIENT_SECRET="" \
    SSH_PRIVATE_KEY="" \
    TRUSTED_HOSTS="github.com" \
    VERSION="${VERSION}"

# Set the entrypoint.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command
CMD ["/bin/zsh"]