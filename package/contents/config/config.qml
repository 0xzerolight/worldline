import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18nc("@title:group for configuration dialog page", "General")  // qmllint disable unqualified
        icon: "preferences-desktop-color"
        source: "ConfigGeneral.qml"
    }
}
