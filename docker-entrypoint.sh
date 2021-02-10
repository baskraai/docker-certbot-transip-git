#!/bin/bash
set -e

# Echo functions
function echo_ok {
    echo "# [   OK   ] $1"
}

function echo_info {
    echo "# [  INFO  ] $1"
}

function echo_failed {
    echo "# [ FAILED ] $1"
}

# Check for the required variables.
for ENV_VAR in "GIT_REPO" "SSH_PUBKEY" "SSH_PRIVKEY" "MAIL"
do
	if [[ "$(env)" != *$ENV_VAR* ]]; then
		echo_failed "no $ENV_VAR variable specified"
		exit 1
	fi
done

# Check for the optional variables.
for ENV_VAR in "MODE"
do
	if [[ "$(env)" == *$ENV_VAR* ]]; then
		echo_info "$ENV_VAR variable specified"
	else
		echo_info "no $ENV_VAR variable specified"
	fi
done

echo_info "Configuring git"
mkdir ~/.ssh
echo "${SSH_PUBKEY}" > ~/.ssh/id_ecdsa.pub
chmod 600 ~/.ssh/id_ecdsa.pub
echo "${SSH_PRIVKEY}" > ~/.ssh/id_ecdsa
chmod 600 ~/.ssh/id_ecdsa
git config --global user.name "Let's Encrypt Bot"
git config --global user.email "$EMAIL"
echo_ok "Configuring git"

echo_info "Pulling the repo"
cd /etc
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone "${GIT_REPO}" letsencrypt
cd letsencrypt
if [ "$?" != 0 ]; then
	echo_failed "Error, could not pull repo"
	exit 1
fi

echo_info "Starting the Let's Encrypt process"
if [ "$MODE" == "create" ] && [[ -z "$DOMAIN" ]]; then
	echo_failed "Mode create specified but no DOMAIN variable given"
	exit 1
elif [ "$MODE" == "create" ]; then
	echo_info "Running the certonly-command"
	CERT_NAME="${DOMAIN//\*/star}"
	certbot certonly --cert-name "${CERT_NAME}" -n -d "${DOMAIN}" -a certbot-dns-transip:dns-transip --certbot-dns-transip:dns-transip-credentials /etc/letsencrypt/transip.ini --certbot-dns-transip:dns-transip-propagation-seconds 600 -m "${EMAIL}" --agree-tos	
	echo_ok "Running the certonly-command"
	echo_info "Git add and push"
	git add ./*
	git commit -m "update $(date)"
	git push
	echo_ok "Git add and push"
else
	echo_info "Running the renew-command"
	certbot renew
	echo_ok "Running the renew-command"
	echo_info "Git add and push"
	git add ./*
	git commit -m "update $(date)"
	git push
	echo_ok "Git add and push"
fi	
