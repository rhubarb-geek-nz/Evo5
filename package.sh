#!/bin/sh -e
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

if test 0 -eq $(id -u)
then
	echo This should not need to be run as root, stay safe out there. 1>&2
	false
fi

GITVERS=$(git log --oneline . | wc -l)
MAINTAINER="$(git config user.email)"

cleanup()
{
	rm -rf data
}

trap cleanup 0

RELEASE="1"
VERSION="1.0.$GITVERS"
PKGNAME=rhubarb-pi-evo5

mkdir -p \
	data/DEBIAN \
	data/usr/lib/systemd/system \
	data/usr/share/rhubarb-pi-evo5/sbin \
	data/usr/share/rhubarb-pi-evo5/etc \
	data/etc/dnsmasq.d

cp rhubarb-pi-evo5.service data/usr/lib/systemd/system
cp hotspot.sh data/usr/share/rhubarb-pi-evo5/sbin
cp rc.local data/usr/share/rhubarb-pi-evo5/etc
cp dnsmasq.evo5.conf data/etc/dnsmasq.d

(
	set -e
	cd /
	sudo tar cf - etc/netplan/*.yaml
) | (
	set -e
	cd data
	tar xf -
)

chmod -w $(find data -type f)
chmod g-w $(find data -type d)

SIZE=$(du -sk data | while read A B; do echo $A; break; done)

cat > data/DEBIAN/control << EOF
Package: $PKGNAME
Version: $VERSION-$RELEASE
Architecture: all
Depends: systemd, dnsmasq, iptables
Section: misc
Priority: optional
Installed-Size: $SIZE
Maintainer: $MAINTAINER
Description: Rhubarb Pi Evo5 Startup
EOF

dpkg-deb --root-owner-group --build data "$PKGNAME"_"$VERSION-$RELEASE"_all.deb
