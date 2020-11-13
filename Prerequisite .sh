
#! /bin/sh

set -ex

apk add --update --no-cache bash wget openssh libc6-compat

wget -O hub.tgz  --progress=dot:mega https://github.com/github/hub/releases/download/v2.14.2/hub-linux-amd64-2.14.2.tgz
mkdir /hub
tar -xvf hub.tgz -C /hub --strip-components 1
alias git=hub
bash /hub/install
hub --version
#=========== Clenaup ===========
rm -v hub.tgz
rm -frv /hub
apk del bash wget

apk update
apk upgrade
apk add bash
apk add jq
jq --version
bash --version
hub --version


cd ~/.config/
echo "github.com:
- user: Vikramana
  oauth_token: 02a1d6fb82d954ad235eee370b78747bf3ee35d9
  protocol: https" > hub
cat ~/.config/hub



