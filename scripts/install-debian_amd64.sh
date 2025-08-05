#!/bin/sh
set -e

install_repository() {
	pkg_url="http://practicerom.com/public/packages/debian"
	gpg_url="https://practicerom.com/public/packages/debian/practicerom-archive-keyring.gpg"
	gpg_key="/usr/share/keyrings/practicerom-archive-keyring.gpg"
	arch="all,amd64"
	dist="unstable"
	comp="main"
	sources_file="/etc/apt/sources.list.d/practicerom.list"

	curl -o "${gpg_key}" "${gpg_url}"

	echo "deb [arch=${arch} signed-by=${gpg_key}] ${pkg_url} ${dist} ${comp}" > "${sources_file}"

	apt-get update
}

install_repository
