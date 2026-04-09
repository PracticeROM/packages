#!/bin/sh
set -e

install_repository() {
	pkg_url="http://practicerom.com/public/packages/debian"
	gpg_url="https://practicerom.com/public/packages/debian/practicerom-archive-keyring.asc"
	gpg_key="/usr/share/keyrings/practicerom-archive-keyring.gpg"
	arch="all,arm64"
	dist="stable"
	comp="main"
	sources_file="/etc/apt/sources.list.d/practicerom.list"

	curl -fsSL "${gpg_url}" | sudo gpg --dearmor --output "${gpg_key}"

	echo "deb [arch=${arch} signed-by=${gpg_key}] ${pkg_url} ${dist} ${comp}" > "${sources_file}"

	apt-get update
}

install_repository
