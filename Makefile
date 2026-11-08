QTBIN ?= /usr/lib/qt6/bin
ID := io.github.0xzerolight.worldline
QML := $(wildcard package/contents/ui/*.qml package/contents/config/*.qml dev/*.qml tests/*.qml)
SHOTS ?=

.PHONY: check json lint test site webtest svgcheck serve install uninstall package preview screenshot

check: json lint test site webtest svgcheck

json:
	python3 -m json.tool package/metadata.json > /dev/null

lint:
	$(QTBIN)/qmllint --max-warnings 0 $(QML)

test:
	QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software $(QTBIN)/qmltestrunner -input tests

site:
	rm -rf _site
	node web/build.mjs _site

webtest: site
	for f in web/*.js; do node --check $$f || exit 1; done
	node --test 'web/test/*.test.js'

svgcheck: site
	python3 -c "import sys, xml.etree.ElementTree as E; E.parse(sys.argv[1])" _site/today.svg

serve: site
	python3 -m http.server -d _site 8000

install:
	kpackagetool6 -t Plasma/Applet --upgrade package 2>/dev/null || kpackagetool6 -t Plasma/Applet --install package

uninstall:
	kpackagetool6 -t Plasma/Applet --remove $(ID)

package:
	rm -f worldline.plasmoid
	cd package && zip -qr ../worldline.plasmoid metadata.json contents

preview:
	$(QTBIN)/qml dev/preview.qml $(if $(SHOTS),-- --shots $(SHOTS))

screenshot:
	$(QTBIN)/qml dev/shot.qml -- assets/screenshot.png
