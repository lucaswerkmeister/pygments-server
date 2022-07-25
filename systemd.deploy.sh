#!/usr/bin/env bash

. "$(dirname -- "$0")/pygmentize.env" 2>/dev/null || true
: "${PYGMENTIZE_HOST:=localhost}"
: "${PYGMENTIZE_PORT:=7879}"
: "${GUNICORN:=$(which gunicorn)}"
: "${GUNICORN_WORKERS:=4}"
: "${SERVICE_WORK_DIR:=$PWD}"
: "${SERVICE_USER:=$USER}"

function user_dialog() {
    read -rp "$(echo -e "Do you want to proceed? [Y/n]:") " USER_INPUT
    if [[ ${USER_INPUT:="Yes"} =~ ^[yY] ]]; then return 0; else exit; fi
}

echo -e "\n**\nInstall the dependencies"
user_dialog && pip install -r requirements.txt

echo -e "\n**" # Install Gunicorn
if [[ -z $GUNICORN ]]
then
	echo "The service uses 'gunicorn' to run the application."
	echo "We will do 'pip install gunicorn' for you."
	echo "If you are prefer to install it via 'apt' or other"
	echo "package manager interrupt the script."
	user_dialog && pip install gunicorn
else
	echo "The service uses 'gunicorn' to run the application."
	echo "It is already available as '$GUNICORN'"
	user_dialog 
fi

echo -e "\n**\nThe following environment variables will be used"
echo \$PYGMENTIZE_HOST = $PYGMENTIZE_HOST
echo \$PYGMENTIZE_PORT = $PYGMENTIZE_PORT
echo \$GUNICORN = $GUNICORN
echo \$GUNICORN_WORKERS = $GUNICORN_WORKERS
echo \$SERVICE_WORK_DIR = $SERVICE_WORK_DIR
echo \$SERVICE_USER = $SERVICE_USER
user_dialog
export PYGMENTIZE_HOST
export PYGMENTIZE_PORT
export GUNICORN
export GUNICORN_WORKERS
export SERVICE_WORK_DIR
export SERVICE_USER
export MAINPID_WA='$MAINPID' # workaround for envsubst

echo -e "\n**\nDeploy 'pygments-server.service'"
user_dialog && cat systemd.units/pygments-server.service | envsubst | sudo tee /etc/systemd/system/pygments-server.service

echo -e "\n**\nDeploy 'pygments-server.socket'"
user_dialog && cat systemd.units/pygments-server.socket | envsubst | sudo tee /etc/systemd/system/pygments-server.socket

echo -e "\n**\nEnable the service 'systemctl daemon-reload && systemctl enable --now pygments-server.socket'"
user_dialog && sudo systemctl daemon-reload && sudo systemctl enable --now pygments-server.socket

echo -e "\n**\nCreate connector 'cp "${SERVICE_WORK_DIR}/systemd.pygmentize" /usr/local/bin/pygmentize'"
FINAL_MESSAGE="\n**\nYou are ready to use: /usr/local/bin/pygmentize\nFor MediaWiki use: \$wgPygmentizePath = \"/usr/local/bin/pygmentize\";"
if [[ -f /usr/local/bin/pygmentize ]]
then
	echo "The file '/usr/local/bin/pygmentize' already exists and will be replaced."
	user_dialog && sudo rm /usr/local/bin/pygmentize && \
	sudo cp "${SERVICE_WORK_DIR}/systemd.pygmentize" /usr/local/bin/pygmentize && \
	echo -e "$FINAL_MESSAGE"	

else
	user_dialog && sudo cp "${SERVICE_WORK_DIR}/systemd.pygmentize" /usr/local/bin/pygmentize && \
	echo -e "$FINAL_MESSAGE"
fi
