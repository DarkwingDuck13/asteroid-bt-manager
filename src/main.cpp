#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include "bluetoothmanager.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("asteroid-bt-manager");

    QQuickView view;
    BluetoothManager btManager;

    view.rootContext()->setContextProperty("btManager", &btManager);
    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.showFullScreen();

    return app.exec();
}
