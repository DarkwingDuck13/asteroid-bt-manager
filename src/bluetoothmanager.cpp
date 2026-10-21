#include "bluetoothmanager.h"
#include <QtDBus/QDBusReply>
#include <QtDBus/QDBusMessage>
#include <QDebug>

BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent) {
    QDBusConnection::systemBus().connect(
        "org.bluez", "/", "org.freedesktop.DBus.ObjectManager",
        "InterfacesAdded", this, SLOT(onInterfacesAdded(QDBusObjectPath, QMap<QString, QVariantMap>))
    );
    QDBusConnection::systemBus().connect(
        "org.bluez", "/", "org.freedesktop.DBus.ObjectManager",
        "InterfacesRemoved", this, SLOT(onInterfacesRemoved(QDBusObjectPath, QStringList))
    );

    refreshDevices();
}

QVariantList BluetoothManager::devices() const {
    QVariantList list;
    for (auto it = m_deviceMap.begin(); it != m_deviceMap.end(); ++it) {
        list.append(it.value());
    }
    return list;
}

void BluetoothManager::startScan() {
    QDBusInterface adapter("org.bluez", "/org/bluez/hci0", "org.bluez.Adapter1", QDBusConnection::systemBus());
    if (adapter.isValid()) {
        adapter.call("StartDiscovery");
        m_scanning = true;
        emit scanningChanged();
    }
}

void BluetoothManager::stopScan() {
    QDBusInterface adapter("org.bluez", "/org/bluez/hci0", "org.bluez.Adapter1", QDBusConnection::systemBus());
    if (adapter.isValid()) {
        adapter.call("StopDiscovery");
        m_scanning = false;
        emit scanningChanged();
    }
}

void BluetoothManager::connectDevice(const QString &address) {
    QString path = pathForAddress(address);
    if (path.isEmpty()) return;

    QDBusInterface dev("org.bluez", path, "org.bluez.Device1", QDBusConnection::systemBus());
    if (dev.isValid()) {
        dev.call("Pair");
        dev.setProperty("Trusted", true);
        dev.call("Connect");
    }
}

void BluetoothManager::disconnectDevice(const QString &address) {
    QString path = pathForAddress(address);
    if (path.isEmpty()) return;

    QDBusInterface dev("org.bluez", path, "org.bluez.Device1", QDBusConnection::systemBus());
    if (dev.isValid()) {
        dev.call("Disconnect");
    }
}

void BluetoothManager::removeDevice(const QString &address) {
    QString path = pathForAddress(address);
    if (path.isEmpty()) return;

    QDBusInterface adapter("org.bluez", "/org/bluez/hci0", "org.bluez.Adapter1", QDBusConnection::systemBus());
    if (adapter.isValid()) {
        adapter.call("RemoveDevice", QVariant::fromValue(QDBusObjectPath(path)));
    }
}

QString BluetoothManager::pathForAddress(const QString &address) const {
    QString formatted = address;
    formatted.replace(":", "_");
    return "/org/bluez/hci0/dev_" + formatted;
}

void BluetoothManager::refreshDevices() {
    QDBusInterface manager("org.bluez", "/", "org.freedesktop.DBus.ObjectManager", QDBusConnection::systemBus());
    QDBusReply<QMap<QDBusObjectPath, QMap<QString, QVariantMap>>> reply = manager.call("GetManagedObjects");

    if (reply.isValid()) {
        m_deviceMap.clear();
        for (auto it = reply.value().begin(); it != reply.value().end(); ++it) {
            if (it.value().contains("org.bluez.Device1")) {
                QVariantMap props = it.value()["org.bluez.Device1"];
                QString addr = props.value("Address").toString();
                if (!addr.isEmpty()) {
                    m_deviceMap[addr] = props;
                }
            }
        }
        emit devicesChanged();
    }
}

void BluetoothManager::onInterfacesAdded(const QDBusObjectPath &path, const QMap<QString, QVariantMap> &interfaces) {
    if (interfaces.contains("org.bluez.Device1")) {
        QVariantMap props = interfaces["org.bluez.Device1"];
        QString addr = props.value("Address").toString();
        if (!addr.isEmpty()) {
            m_deviceMap[addr] = props;
            emit devicesChanged();
        }
    }
}

void BluetoothManager::onInterfacesRemoved(const QDBusObjectPath &path, const QStringList &interfaces) {
    if (interfaces.contains("org.bluez.Device1")) {
        for (auto it = m_deviceMap.begin(); it != m_deviceMap.end(); ++it) {
            if (pathForAddress(it.key()) == path.path()) {
                m_deviceMap.erase(it);
                emit devicesChanged();
                break;
            }
        }
    }
}

void BluetoothManager::onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated) {
    Q_UNUSED(interface);
    Q_UNUSED(invalidated);
    refreshDevices();
}
