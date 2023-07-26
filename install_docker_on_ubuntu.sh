set -x
set -e

echo "INSTALLING 'docker' ..."
apt update

apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

apt-cache policy docker-ce

apt install -y docker-ce


systemctl status docker

echo "SUCCESSFULY INSTALLED 'docker'."

echo "INSTALLING 'docker-compose' ..."

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

docker-compose --version

echo "SUCCESSFULY INSTALLED 'docker-compose'."