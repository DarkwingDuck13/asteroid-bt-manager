#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusObjectPath>

// Define and register the D-Bus nested map types for GetManagedObjects
typedef QMap<QString, QVariantMap> InterfaceMap;
typedef QMap<QDBusObjectPath, InterfaceMap> ManagedObjectMap;
Q_DECLARE_METATYPE(InterfaceMap)
Q_DECLARE_METATYPE(ManagedObjectMap)

class BluetoothAgent : public QObject {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.bluez.Agent1")

public:
    explicit BluetoothAgent(QObject *parent = nullptr) : QObject(parent) {}

public Q_SLOTS:
    void Release() { emit dismissed(); }
    void Cancel() { emit dismissed(); }

    QString RequestPinCode(const QDBusObjectPath &) { return QStringLiteral("0000"); }
    void DisplayPinCode(const QDBusObjectPath &, const QString &pincode) { emit passkeyDisplayed(pincode); }

    uint RequestPasskey(const QDBusObjectPath &) { return 0; }
    void DisplayPasskey(const QDBusObjectPath &, uint passkey, ushort) {
        emit passkeyDisplayed(QString("%1").arg(passkey, 6, 10, QChar('0')));
    }

    void RequestConfirmation(const QDBusObjectPath &, uint passkey) {
        emit passkeyDisplayed(QString("%1").arg(passkey, 6, 10, QChar('0')));
    }

    void RequestAuthorization(const QDBusObjectPath &) {}
    void AuthorizeService(const QDBusObjectPath &, const QString &) {}

Q_SIGNALS:
    void passkeyDisplayed(const QString &pin);
    void dismissed();
};

class BluetoothManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(QVariantList pairedDevices READ pairedDevices NOTIFY devicesChanged)
    Q_PROPERTY(QVariantList availableDevices READ availableDevices NOTIFY devicesChanged)
    Q_PROPERTY(QString currentPin READ currentPin NOTIFY pinChanged)
    Q_PROPERTY(bool pinPromptVisible READ pinPromptVisible NOTIFY pinPromptVisibleChanged)

public:
    explicit BluetoothManager(QObject *parent = nullptr);
    ~BluetoothManager();

    bool isScanning() const { return m_scanning; }
    QVariantList pairedDevices() const;
    QVariantList availableDevices() const;
    QString currentPin() const { return m_currentPin; }
    bool pinPromptVisible() const { return m_pinPromptVisible; }

    Q_INVOKABLE void startScan();
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void pairDevice(const QString &address);
    Q_INVOKABLE void connectDevice(const QString &address);
    Q_INVOKABLE void disconnectDevice(const QString &address);
    Q_INVOKABLE void forgetDevice(const QString &address);
    Q_INVOKABLE void cancelPinPrompt();

signals:
    void scanningChanged();
    void devicesChanged();
    void pinChanged();
    void pinPromptVisibleChanged();

private slots:
    void onInterfacesAdded(const QDBusObjectPath &path, const QMap<QString, QVariantMap> &interfaces);
    void onInterfacesRemoved(const QDBusObjectPath &path, const QStringList &interfaces);
    void onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated);
    void onPasskeyDisplayed(const QString &pin);
    void onPasskeyDismissed();

private:
    void refreshDevices();
    QString pathForAddress(const QString &address) const;

    bool m_scanning = false;
    QString m_currentPin;
    bool m_pinPromptVisible = false;

    BluetoothAgent *m_agent = nullptr;
    QMap<QString, QVariantMap> m_deviceMap;
};
