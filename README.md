# SynapseStudios DevOps ToolBox

 [![Docker Automated build](https://img.shields.io/docker/automated/synapsestudios/devops-toolbox.svg)](https://hub.docker.com/r/synapsestudios/devops-toolbox/) [![Docker Pulls](https://img.shields.io/docker/pulls/synapsestudios/devops-toolbox.svg)](https://hub.docker.com/r/synapsestudios/devops-toolbox/) [![Docker Stars](https://img.shields.io/docker/stars/synapsestudios/devops-toolbox.svg)](https://hub.docker.com/r/synapsestudios/devops-toolbox/) [![](https://images.microbadger.com/badges/image/synapsestudios/devops-toolbox.svg)](https://microbadger.com/images/synapsestudios/devops-toolbox "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/synapsestudios/devops-toolbox.svg)](https://microbadger.com/images/synapsestudios/devops-toolbox "Get your own version badge on microbadger.com")  


## About

This an [Alpine] based docker image used as a general toolkit for DevOps related tasks and projects. It is intended to be used as an interactive shell and comes pre-loaded with useful tools and scripts. The size of this image will likely grow over time, but the goal of using Alpine is to help mitigate that growth.

### Some Notable Included Tools

 * [ansible]
 * [awscli]
 * [certbot]
 * [cw] (CloudWatch CLI)
 * [fly] (Concourse CLI)
 * [gauth]
 * [git-crypt]
 * [git-secrets]
 * [jq]
 * [k6] (Load Testing)
 * [kind] (Kubernetes in Docker)
 * [kops]
 * [kubectl]
 * [packer]
 * [pre-commit]
 * [spin] (Spinnaker CLI)
 * [starship]
 * [tag]
 * [terraform-docs]
 * [terraform-lsp] (Terraform Language Server Protocol)
 * [terraform]
 * [tflint]
 * Docker (DIND Support)
 * docker-compose
 * zsh

### Recommended Prerequisites

This Docker image is primarily tested on macOS. For best functionality it is recommended to use [powerline-fonts] or my preference which is [fira-code] fonts. Included in this repo is an example [iterm2] profile which can be imported and used. This profile uses FiraCode fonts which can be install using homebrew. 

```shell
brew tap homebrew/cask-fonts
brew cask install font-fira-code
```

**You may need to restart Iterm2 for fonts to load.**

## Building

To build the project:
```shell
make
```

To list the images:
```shell
make list
```

To run any tests:
```shell
make test
```

To push image to remote docker repository:
```shell
REPO_PASSWORD='MyPassword!$' make push
```

To update README on remote docker repository (docker hub):

```shell
REPO_PASSWORD='MyPassword!$' make push-readme
```

To cleanup and remove built images:
```shell
make clean
```

### Build Args
The following build args can be used to modify the build. To override these values simply present them to make as a variable.
for example:
```shell
# Use Alpine 3.10
BASE_IMAGE='alpine:3.10' make
# Use NodeJS Alpine 
BASE_IMAGE='node:12.16.1-alpine3.11' make
```

Builds can also be tagged with a `TAG_SUFFIX` like so:
```shell
TAG_SUFFIX=-nodejs BASE_IMAGE='node:12.16.1-alpine3.11' make
# Given you have already built the default image, your results may look like the following
make list
REPOSITORY                   TAG                 IMAGE ID            CREATED              SIZE
synapsestudios/devops-toolbox   a68f89b-nodejs      82699f575aa4        38 seconds ago       1.28GB
synapsestudios/devops-toolbox   latest-nodejs       82699f575aa4        38 seconds ago       1.28GB
synapsestudios/devops-toolbox   master-nodejs       82699f575aa4        38 seconds ago       1.28GB
synapsestudios/devops-toolbox   a68f89b             45337831581a        About a minute ago   1.2GB
synapsestudios/devops-toolbox   latest              45337831581a        About a minute ago   1.2GB
synapsestudios/devops-toolbox   master              45337831581a        About a minute ago   1.2GB
```

| Variable                 | Default Value    | Description                                           |
| ------------------------ | ---------------- | ----------------------------------------------------- |
| `BASE_IMAGE`             | `alpine:3.11`    | Base Docker Image to build from ([Alpine] Only)       |
| `DOCKER_GID`             | `1001`           | Group ID to use within the container                  |
| `DOCKER_GROUP`           | `synapse`        | Group Name to use within the container                |
| `DOCKER_UID`             | `1001`           | User ID to use within the container                   |
| `DOCKER_USER`            | `synapse`        | User Name to use within the container                 |
| `FLY_VERSION`            | `6.0.0`          | [fly] (Concourse CI CLI) version to install           |
| `GIT_CRYPT_VERSION`      | `master`         | [git-crypt] version (commit ref) to build and install |
| `KOPS_VERSION`           | `v1.17.0-beta.1` | [kops] version to install                             |
| `KUBECTL_VERSION`        | `v1.18.0`        | [kubectl] version to install                          |
| `PACKER_VERSION`         | `1.5.5`          | [packer] version to install                           |
| `STARSHIP_VERSION`       | `v0.38.0`        | [starship] version to install                         |
| `SPIN_VERSION`           | `1.14.0`         | [spin] (Spinnaker CLI) version to install             |
| `TERRAFORM_DOCS_VERSION` | `v0.9.1`         | [terraform-docs] version to install                   |
| `TERRAFORM_VERSION`      | `0.12.24`        | [terraform] version to install                        |
| `TFLINT_VERSION`         | `v0.15.3`        | [tflint] version to install                           |

## Usage

Copy the provided `.env.example` to `.env` and populate it with your personal credentials.  
To set your `SSH_PRIVATE_KEY`, and `GIT_CRYPT_KEY` use base64 encoding.

```shell
cat ~/.ssh/id_rsa | base64
```

To run the container:
```shell
docker run -i -t \
    --env-file .env \
    --name toolbox \
    synapsestudios/devops-toolbox
```

Or to run with DIND (Docker in Docker) support:
```shell
docker run -i -t \
    --env-file .env \
    --name toolbox \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    synapsestudios/devops-toolbox
```

Optionally running with host network mode (Does not work correctly on macOS):
```shell
docker run -i -t \
    --env-file .env \
    --name toolbox \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --net=host \
    synapsestudios/devops-toolbox
```

Run with a bind mounted volume:
```shell
docker run -i -t \
    --env-file .env \
    --name toolbox \
    --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/toolbox:/home \
    --net=host \
    synapsestudios/devops-toolbox
```

Once launched you will be authenticated to the your AWS Account (If credentials provided) in an interactive ZSH terminal. ZSH is used because everything else is just wrong.


## Environment Variables

The following ENV variables should be set in the `.env`.

| Variable                        | Default Value                        | Description                                                                                                       |
| ------------------------------- | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`             | `REDACTED`                           | Your AWS Access Key ID                                                                                            |
| `AWS_SECRET_ACCESS_KEY`         | `REDACTED`                           | Your AWS Secret Access Key for                                                                                    |
| `AWS_MFA_PASSWORD`              | `REDACTED`                           | Your personal AWS MFA Password                                                                                    |
| `AWS_PROFILE`                   | `default`                            | The AWS Profile to use                                                                                            |
| `AWS_DEFAULT_REGION`            | `us-west-2`                          | The Default AWS Region to use                                                                                     |
| `DOCKER_GID`                    | `1001`                               | Group ID to use within the container                                                                              |
| `DOCKER_GROUP`                  | `synapse`                            | Group Name to use within the container                                                                            |
| `DOCKER_UID`                    | `1001`                               | User ID to use within the container                                                                               |
| `DOCKER_USER`                   | `synapse`                            | User Name to use within the container                                                                             |
| `GIT_CRYPT_KEY`                 | `REDACTED`                           | Optional base64 encoded git-crypt key to inject into container                                                    |
| `GIT_EMAIL`                     | `email@example.com`                  | E-Mail address to use with git config (Should be your E-Mail)                                                     |
| `GIT_REPOS`                     | **NULL**                             | Comma separated list of git repositories to clone on startup                                                      |
| `GIT_USERNAME`                  | `myusername`                         | User name to use with git config (Should be your name)                                                            |
| `SSH_PRIVATE_KEY`               | `REDACTED`                           | base64 encoded ssh private key, used to access Github                                                             |
| `SPINNAKER_ACCESS_TOKEN`        | `REDACTED`                           | Spinnaker Access Token                                                                                            |
| `SPINNAKER_ENDPOINT`            | `https://spinnaker.example.com:8084` | Spinnaker Gate Endpoint                                                                                           |
| `SPINNAKER_OAUTH_CLIENT_ID`     | `REDACTED`                           | Spinnaker OAuth Client ID (GitHub)                                                                                |
| `SPINNAKER_OAUTH_CLIENT_SECRET` | `REDACTED`                           | Spinnaker OAuth Client Secret (GitHub)                                                                            |
| `TRUSTED_HOSTS`                 | `github.com`                         | Comma separated list of trusted hosts to add to ssh configuration (Disables StrictHostKey checking for each host) |

[Alpine]: https://alpinelinux.org/
[ansible]: https://www.ansible.com/
[awscli]: https://aws.amazon.com/cli/
[certbot]: https://certbot.eff.org/
[cw]: https://github.com/lucagrulla/cw
[fira-code]: https://github.com/tonsky/FiraCode
[fly]: https://concourse-ci.org/fly.html
[gauth]: https://github.com/pcarrier/gauth
[git-crypt]: https://github.com/AGWA/git-crypt/
[git-secrets]: https://github.com/awslabs/git-secrets
[iterm2]: https://www.iterm2.com/
[jq]: https://stedolan.github.io/jq/
[k6]: https://k6.io/
[kind]: https://kind.sigs.k8s.io/
[kops]: https://github.com/kubernetes/kops
[kubectl]: https://github.com/kubernetes/kubectl
[packer]: https://packer.io/
[powerline-fonts]: https://github.com/powerline/fonts
[pre-commit]: https://pre-commit.com/
[spin]: https://www.spinnaker.io/setup/spin/
[starship]: https://starship.rs/
[tag]: https://github.com/aykamko/tag
[terraform-docs]: https://github.com/segmentio/terraform-docs
[terraform-lsp]: https://github.com/juliosueiras/terraform-lsp
[terraform]:https://www.terraform.io/
[tflint]: https://github.com/terraform-linters/tflint
[vscode-remote]: https://code.visualstudio.com/docs/remote/remote-overview