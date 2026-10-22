#include "bluetoothmanager.h"
#include <QtDBus/QDBusReply>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusPendingCall>
#include <QtDBus/QDBusPendingCallWatcher>
#include <QtDBus/QDBusVariant>
#include <QDebug>

// Helper to unwrap QDBusVariant containers into native types
static QVariantMap unwrapDbusProps(const QVariantMap &props) {
    QVariantMap clean;
    for (auto it = props.begin(); it != props.end(); ++it) {
        QVariant val = it.value();
        if (val.userType() == qMetaTypeId<QDBusVariant>() || val.canConvert<QDBusVariant>()) {
            val = val.value<QDBusVariant>().variant();
        }
        clean[it.key()] = val;
    }
    return clean;
}

BluetoothManager::BluetoothManager(QObject *parent) : QObject(parent) {
    m_agent = new BluetoothAgent(this);
    connect(m_agent, &BluetoothAgent::passkeyDisplayed, this, &BluetoothManager::onPasskeyDisplayed);
    connect(m_agent, &BluetoothAgent::dismissed, this, &BluetoothManager::onPasskeyDismissed);

    QDBusConnection::systemBus().registerObject("/app/agent", m_agent, QDBusConnection::ExportAllSlots);

    QDBusInterface agentManager("org.bluez", "/org/bluez", "org.bluez.AgentManager1", QDBusConnection::systemBus());
    if (agentManager.isValid()) {
        agentManager.call("RegisterAgent", QVariant::fromValue(QDBusObjectPath("/app/agent")), "KeyboardDisplay");
        agentManager.call("RequestDefaultAgent", QVariant::fromValue(QDBusObjectPath("/app/agent")));
    }

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

BluetoothManager::~BluetoothManager() {
    QDBusInterface agentManager("org.bluez", "/org/bluez", "org.bluez.AgentManager1", QDBusConnection::systemBus());
    if (agentManager.isValid()) {
        agentManager.call("UnregisterAgent", QVariant::fromValue(QDBusObjectPath("/app/agent")));
    }
}

QVariantList BluetoothManager::pairedDevices() const {
    QVariantList list;
    for (auto it = m_deviceMap.begin(); it != m_deviceMap.end(); ++it) {
        if (it.value().value("Paired").toBool()) {
            list.append(it.value());
        }
    }
    return list;
}

QVariantList BluetoothManager::availableDevices() const {
    QVariantList list;
    for (auto it = m_deviceMap.begin(); it != m_deviceMap.end(); ++it) {
        if (!it.value().value("Paired").toBool()) {
            list.append(it.value());
        }
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

void BluetoothManager::pairDevice(const QString &address) {
    QString path = pathForAddress(address);
    if (path.isEmpty()) return;
