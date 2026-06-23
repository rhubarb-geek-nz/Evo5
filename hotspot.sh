#!/bin/sh -ex
# Copyright (c) 2026 Roger Brown.
# Licensed under the MIT License.

if nmcli connection show ap0 > /dev/null
then
	nmcli connection delete ap0
fi

nmcli connection add \
	con-name ap0 \
	type wifi \
	ifname wlan1 \
	ssid MYSSID \
	802-11-wireless.mode ap \
	802-11-wireless.band bg \
	wifi-sec.pairwise ccmp \
	wifi-sec.key-mgmt wpa-psk \
 	wifi-sec.psk ENCRYPTED_PSK_IS_HERE \
	ipv4.method static \
	ipv4.address 10.1.3.1/24 \
	802-11-wireless-security.pmf 1\
	autoconnect yes

nmcli connection up ap0
