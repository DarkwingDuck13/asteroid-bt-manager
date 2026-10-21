#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>

class BluetoothManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(QVariantList devices READ devices NOTIFY devicesChanged)

public:
    explicit BluetoothManager(QObject *parent = nullptr);

    bool isScanning() const { return m_scanning; }
    QVariantList devices() const;

    Q_INVOKABLE void startScan();
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void connectDevice(const QString &address);
    Q_INVOKABLE void disconnectDevice(const QString &address);
    Q_INVOKABLE void removeDevice(const QString &address);

signals:
    void scanningChanged();
    void devicesChanged();

private slots:
    void onInterfacesAdded(const QDBusObjectPath &path, const QMap<QString, QVariantMap> &interfaces);
    void onInterfacesRemoved(const QDBusObjectPath &path, const QStringList &interfaces);
    void onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated);

private:
    void refreshDevices();
    QString pathForAddress(const QString &address) const;

    bool m_scanning = false;
    QMap<QString, QVariantMap> m_deviceMap;
};