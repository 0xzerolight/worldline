QTBIN ?= /usr/lib/qt6/bin
ID := io.github.0xzerolight.worldline
QML := $(wildcard package/contents/ui/*.qml package/contents/config/*.qml dev/*.qml tests/*.qml)
SHOTS ?=

.PHONY: check json lint test install uninstall package preview

check: json lint test

json:
	python3 -m json.tool package/metadata.json > /dev/null

lint:
	$(QTBIN)/qmllint --max-warnings 0 $(QML)

test:
	QT_QPA_PLATFORM=offscreen $(QTBIN)/qmltestrunner -input tests

install:
	kpackagetool6 -t Plasma/Applet --upgrade package 2>/dev/null || kpackagetool6 -t Plasma/Applet --install package

uninstall:
	kpackagetool6 -t Plasma/Applet --remove $(ID)

package:
	rm -f worldline.plasmoid
	cd package && zip -qr ../worldline.plasmoid metadata.json contents

preview:
	$(QTBIN)/qml dev/preview.qml $(if $(SHOTS),-- --shots $(SHOTS))
