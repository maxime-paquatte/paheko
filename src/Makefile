.PHONY: dev-server release deps publish check-dependencies test minify phpstan
KD2_FILE := https://fossil.kd2.org/kd2fw/uv/KD2-7.2.zip

deps:
	$(eval TMP_KD2=$(shell mktemp -d))
	#cd ${TMP_KD2}

	wget ${KD2_FILE} -O ${TMP_KD2}/kd2.zip

	rm -rf "include/lib/KD2"
	unzip "${TMP_KD2}/kd2.zip" -d include/lib

	rm -rf ${TMP_KD2}

dev-server:
	php -S localhost:8082 -t www www/_route.php

test:
	find . -name '*.php' -print0 | xargs -0 -n1 php -l > /dev/null

phpstan:
	phpstan.phar analyze -c ../tests/phpstan.neon include www

psalm:
	@# This is required by psalm, but useless
	@-mkdir vendor
	@-echo '{"require": {}}' > vendor/autoload.php
	psalm.phar -c ../tests/psalm.xml

release: test minify
	$(eval VERSION=$(shell cat VERSION))
	rm -rf /tmp/paheko-build
	mkdir -p /tmp/paheko-build
	fossil zip ${VERSION} /tmp/paheko-build/src.zip --name paheko
	unzip -d /tmp/paheko-build /tmp/paheko-build/src.zip
	cd include/lib; \
		rsync --files-from=dependencies.list -r ./ /tmp/paheko-build/paheko/src/include/lib/
	mv www/admin/static/mini.css /tmp/paheko-build/paheko/src/www/admin/static/admin.css
	cd /tmp/paheko-build/paheko/src/www/admin/static; \
		rm -f styles/[0-9]*.css; \
		rm -f font/*.css font/*.json
	cd /tmp/paheko-build/paheko/src; \
		rm -f Makefile include/lib/KD2/data/countries.en.json
	cd /tmp/paheko-build/paheko/src/data; mkdir plugins && cd plugins; \
		wget https://fossil.kd2.org/paheko-plugins/uv/welcome.tar.gz
	mv /tmp/paheko-build/paheko/src /tmp/paheko-build/paheko-${VERSION}
	@#cd /tmp/paheko-build/; zip -r -9 paheko-${VERSION}.zip paheko-${VERSION};
	@#mv -f /tmp/paheko-build/paheko-${VERSION}.zip ./
	tar czvfh paheko-${VERSION}.tar.gz --hard-dereference -C /tmp/paheko-build paheko-${VERSION}

deb:
	cd ../debian; ./makedeb.sh

publish: release deb
	$(eval VERSION=$(shell cat VERSION))
	gpg --armor --detach-sign paheko-${VERSION}.tar.gz
	fossil uv sync
	#fossil uv ls | fgrep -v 'paheko-0.8.5' | grep '^paheko-.*\.(tar\.bz2|deb)' | xargs fossil uv rm
	fossil uv add paheko-${VERSION}.tar.gz
	fossil uv add paheko-${VERSION}.tar.gz.asc
	cd ../debian && fossil uv add paheko-${VERSION}.deb
	cd ../tools && php make_installer.php > install.php && fossil uv add install.php && rm install.php
	fossil uv sync

check-dependencies:
	grep -hEo '^use \\?KD2\\[^; ]+|\\KD2\\[^\(:; ]+' -R include/lib/Garradin www | sed -r 's/^use \\?KD2\\|^\\KD2\\//' | sort | uniq

minify:
	cat `ls www/admin/static/styles/[0-9]*.css` | sed 's/\.\.\///' > www/admin/static/mini.css
	@# Minify is only gaining 500 gzipped bytes (4kB uncompressed) but making things hard to read/hack
	@#yui-compressor --nomunge www/admin/static/mini.css -o www/admin/static/mini.css
