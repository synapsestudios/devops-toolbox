#!/usr/bin/env bash
create_aws_config() {
	echo "Building AWS Config files"
	mkdir -p $HOME/.aws
	cat <<-EOF >$HOME/.aws/config
		[profile default]
		region = ${AWS_DEFAULT_REGION}
	EOF

	cat <<-EOF >$HOME/.aws/credentials
		[default]
		aws_access_key_id = ${AWS_ACCESS_KEY_ID}
		aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
	EOF
}

create_aws_mfa_config() {
	echo "Creating AWS MFA Config"
	mkdir -p $HOME/.config
	echo "AWS:${AWS_MFA_PASSWORD}" >>$HOME/.config/gauth.csv
}

create_ssh_config() {
	echo "Configuring SSH"
	mkdir -p $HOME/.ssh
	echo "$SSH_PRIVATE_KEY" | base64 -d >$HOME/.ssh/id_rsa
	for trusted_host in ${TRUSTED_HOSTS//,/ }; do
		printf 'Host %s\n    StrictHostKeyChecking=no\n    UserKnownHostsFile=/dev/null\n\n' "$trusted_host" >>$HOME/.ssh/config
	done
	chmod 700 $HOME/.ssh
	chmod 644 $HOME/.ssh/config
	chmod 600 $HOME/.ssh/id_rsa
}

create_git_crypt_config() {
	echo "Configuring git-crypt"
	mkdir -p $HOME/.secrets
	echo "$GIT_CRYPT_KEY" | base64 -d >$HOME/.secrets/synapsestudios.key
}

clone_repos() {
	for repo in ${GIT_REPOS//,/ }; do
		repo_path=$(echo $repo | cut -f2 -d ':' | sed 's|//||g' | sed 's|github\.com/||g' | sed 's/\.git//g')
		echo "Cloning $repo repo to $HOME/Projects/$repo_path"
		git clone "$repo" "$HOME/Projects/$repo_path"
		cd "$HOME/Projects/$repo_path"
		if [ -f '.git-crypt' ]; then
			git-crypt unlock $(envsubst <.git-crypt)
		fi
		if [ -f '.pre-commit-config.yaml' ]; then
			pre-commit install --install-hooks
		fi
		cd "$HOME"
	done
}

configure_git() {
	git config --global user.email "$GIT_EMAIL"
	git config --global user.name "$GIT_USERNAME"
}

configure_spin() {
	echo "Configuring spin (Spinnaker CLI) with endpoint: $SPINNAKER_ENDPOINT"
	envsubst </etc/skel/.spin/config >"$HOME"/.spin/config
}

if [ ! -f "$HOME"/.config/provisioned ]; then
	create_aws_config
	create_aws_mfa_config
	create_ssh_config
	configure_git
	configure_spin
	create_git_crypt_config
	clone_repos
	touch "$HOME"/.config/provisioned
else
	echo "Skipping first time setup."
fi
