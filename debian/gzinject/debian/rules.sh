_commit="e0ce0c8"

pkgname="gzinject"
pkgrel=1
url="https://github.com/PracticeROM/gzinject"

pkgver() {
	rev=$(git -C "${pkgname}" rev-list --count "${_commit}")
	printf "0.r%s.%s" "${rev}" "${_commit}"
}

clean() {
	rm -f debian/files
	rm -rf debian/tmp/
	rm -rf "${pkgname}"/
}

prepare() {
	git clone -- "${url}.git" "${pkgname}"
	git -C "${pkgname}" checkout "${_commit}"

	build=$(dpkg-architecture -q DEB_BUILD_GNU_TYPE)
	host=$(dpkg-architecture -q DEB_HOST_GNU_TYPE)

	(cd "${pkgname}" && ./configure \
		--prefix=/usr \
		--build=${build} \
		--host=${host}
	)
}

build() {
	build-arch
}

build-arch() {
	prepare

	make -C "${pkgname}" all
}

build-indep() {
	return 0
}

binary() {
	binary-arch
}

binary-arch() {
	pkgdir="${PWD}"/debian/tmp
	pkgver=$(pkgver)

	rm -rf "${pkgdir}"
	mkdir -p "${pkgdir}"
	mkdir -p "${pkgdir}"/DEBIAN

	make DESTDIR="${pkgdir}" -C "${pkgname}" install

	dpkg-gencontrol -v"${pkgver}-${pkgrel}" -p"${pkgname}"
	dpkg-deb -b "${pkgdir}" ..
}

binary-indep() {
	return 0
}
