void BluetoothManager::connectDevice(const QString &address) {
    QString path = pathForAddress(address);
    if (path.isEmpty()) return;

    QDBusInterface *dev = new QDBusInterface("org.bluez", path, "org.bluez.Device1", QDBusConnection::systemBus(), this);
    if (dev->isValid()) {
        dev->setProperty("Trusted", true);

        // Make Pair call ASYNCHRONOUS so the event loop stays alive to display the PIN
        QDBusPendingCall async = dev->asyncCall("Pair");
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(async, this);

        connect(watcher, &QDBusPendingCallWatcher::finished, this, [dev, watcher]() {
            watcher->deleteLater();
            dev->asyncCall("Connect");
            dev->deleteLater();
        });
    }
}
