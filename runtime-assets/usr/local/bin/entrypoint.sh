#!/usr/bin/env bash

create_user() {
	echo "Creating Group: $DOCKER_GROUP (GID: $DOCKER_GID)"
	if ! $(id -g "$DOCKER_GROUP" 2>/dev/null); then
		addgroup -g ${DOCKER_GID} -S ${DOCKER_GROUP}
	fi
	echo "Creating User: $DOCKER_USER (UID: $DOCKER_UID)"
	adduser -u ${DOCKER_UID} -S -k /etc/skel -h /home/${DOCKER_USER} -s /bin/zsh -G ${DOCKER_GROUP} ${DOCKER_USER}
	echo 'Set disable_coredump false' >>/etc/sudo.conf
	echo "${DOCKER_USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/${DOCKER_USER}
	chmod 0440 /etc/sudoers.d/${DOCKER_USER}
}

if [ "echo $(id -u)" == "0" ] && ! $(id -u "$DOCKER_USER" 2>/dev/null); then
	create_user
fi

# TODO this is pretty dumb.
if [ -S /var/run/docker.sock ]; then
	echo "Enabling DIND"
	sudo chmod 777 /var/run/docker.sock
fi

cd /home/${DOCKER_USER}/
su-exec ${DOCKER_USER} "$@"
