#!/usr/bin/env bash

echo -e "\n**\nInstall dependencies"
pip install -r requirements.txt

# Export envvars for envsubst
export GUNICORN=$(which gunicorn)
export WORKERS=2
export PORT=7879

echo -e "\n**\nDeploy pygments-server.service"
cat systemd/pygments-server.service | envsubst | sudo tee /etc/systemd/system/pygments-server.service

echo "Deploy pygments-server.socket"
cat systemd/pygments-server.socket | envsubst | sudo tee /etc/systemd/system/pygments-server.socket

echo -e "\n**\nsystemctl daemon-reload && systemctl enable --now pygments-server.socket"
sudo systemctl daemon-reload
sudo systemctl enable --now pygments-server.socket

echo -e "\n**\nCreate /usr/local/bin/pygmentize"
sudo ln -s "${PWD}/pygmentize.socket" /usr/local/bin/pygmentize && \
echo -e "\n**\nYou are ready to use: /usr/local/bin/pygmentize\n""For MediaWiki use: \$wgPygmentizePath = \"/usr/local/bin/pygmentize\";"
