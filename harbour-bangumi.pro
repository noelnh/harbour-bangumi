# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-bangumi

CONFIG += sailfishapp

HEADERS += \
    src/bgmnamfactory.h

SOURCES += \
    src/harbour-bangumi.cpp \
    src/bgmnamfactory.cpp

OTHER_FILES += qml/harbour-bangumi.qml \
    qml/cover/CoverPage.qml \
    qml/pages/*.qml \
    qml/js/*.js \
    qml/img/harbour-bangumi.png \
    rpm/harbour-bangumi.changes \
    rpm/harbour-bangumi.spec \
    rpm/harbour-bangumi.yaml \
    translations/*.ts \
    harbour-bangumi.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-bangumi-de.ts
