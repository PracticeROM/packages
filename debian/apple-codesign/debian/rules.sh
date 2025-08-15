pkgname="apple-codesign"
pkgver=0.29.0
pkgrel=2
url="https://github.com/indygreg/apple-platform-rs"

export CARGO_HOME="${PWD}"/.cargo
export RUSTUP_HOME="${PWD}"/.rustup

clean() {
	rm -f debian/files
	rm -rf debian/tmp/
	rm -rf apple-platform-rs/
	rm -rf "${CARGO_HOME}"
	rm -rf "${RUSTUP_HOME}"
}

prepare() {
	git clone -- "${url}.git" apple-platform-rs
	git -C apple-platform-rs checkout "${pkgname}"/"${pkgver}"
}

build() {
	build-arch
}

build-arch() {
	prepare

	host=$(dpkg-architecture -qDEB_HOST_GNU_TYPE)
	cpu=$(dpkg-architecture -qDEB_HOST_GNU_CPU)
	system=$(dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
	target=${cpu}-unknown-${system}

	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
		sh -s -- -y --target ${target}

	(cd apple-platform-rs/"${pkgname}" && "${CARGO_HOME}"/bin/cargo build \
		--config "target.${target}.linker='${host}-gcc'" \
		--target ${target} \
		--profile release \
		--bin rcodesign
	)
}

build-indep() {
	return 0
}

binary() {
	binary-arch
}

binary-arch() {
	pkgdir="${PWD}"/debian/tmp

	rm -rf "${pkgdir}"
	mkdir -p "${pkgdir}"
	mkdir -p "${pkgdir}"/DEBIAN

	host=$(dpkg-architecture -qDEB_HOST_GNU_TYPE)
	cpu=$(dpkg-architecture -qDEB_HOST_GNU_CPU)
	system=$(dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
	target=${cpu}-unknown-${system}

	(cd apple-platform-rs/"${pkgname}" && "${CARGO_HOME}"/bin/cargo install \
		--path . \
		--config "target.${target}.linker='${host}-gcc'" \
		--target ${target} \
		--root="${pkgdir}"/usr \
		--no-track \
		--profile release \
		--bin rcodesign
	)

	dpkg-gencontrol -v"${pkgver}-${pkgrel}" -p"${pkgname}"
	dpkg-deb -b "${pkgdir}" ..
}

binary-indep() {
	return 0
}
