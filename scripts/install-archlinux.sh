#!/bin/sh
set -e

install_repository() {
	pkg_url="http://practicerom.com/public/packages/archlinux"
	gpg_url="https://practicerom.com/public/packages/practicerom.gpg"
	repo="practicerom"

	pacman-key --init

	(curl "${gpg_url}" || wget -O - "${gpg_url}") |
		tee -p >(pacman-key --add - >/dev/null) |
		gpg --with-colons --with-fingerprint --show-key - |
		awk -F: '$1=="fpr" {print($10)}' | head -n 1 |
		xargs pacman-key --lsign

	if ! grep -F "[${repo}]" /etc/pacman.conf >/dev/null; then
		printf "\n[${repo}]\nServer = ${pkg_url}\n" >> /etc/pacman.conf
	fi

	pacman -Sy
}

install_repository
