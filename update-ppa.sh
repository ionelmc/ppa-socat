#!/bin/bash -eux

if ! which gpg-agent; then
    sudo apt-get install gnupg-agent
fi
if ! which pull-lp-source; then
    sudo apt-get install ubuntu-dev-tools
fi
if ! which /dh_autoreconf; then
    sudo apt-get install dh-autoreconf
fi
gpg-agent || eval `gpg-agent --daemon`
echo ==============================
echo        making packages
echo ==============================

for dist in trusty xenial; do
    rm -rf socat*
    pull-lp-source socat $dist
    (
        cd socat*
        dch --force-distribution -D $dist -l"+ionelmc+ppa" "Enable readline. Disable openssl."
        patch -lp1 < ../enable-readline.patch
        debuild -S -sa
    )
    dput -f ppa:ionel-mc/socat *.changes
done
