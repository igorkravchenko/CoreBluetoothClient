//
//  Live.swift
//  CoreBluetoothClient
//
//  Created by Igor Kravchenko on 05.02.2021.
//

import CoreBluetooth
import Combine
import CoreBluetoothClient

extension CentralManager {
    public static func live(centalManager: CBCentralManager) -> Self {
        class Delegate: NSObject, CBCentralManagerDelegate {
            let subject: PassthroughSubject<DelegateEvent, Never>
            
            init(subject: PassthroughSubject<DelegateEvent, Never>) {
                self.subject = subject
                super.init()
            }
            
            func centralManagerDidUpdateState(_ central: CBCentralManager) {
                subject.send(.centralManagerDidUpdateState(central.state))
            }
            
            func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
                subject.send(.centralManagerWillRestoreState(.live(dict)))
            }
            
            func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
                subject.send(.centralManagerDidDiscover(peripheral: .live(peripheral),
                                                        advertisementData: .live(advertisementData), rssi: RSSI))
            }
            
            func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
                subject.send(.centralManagerDidConnectPeripheral(.live(peripheral)))
            }
            
            func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
                subject.send(.centralManagerDidFailToConnectPeripheral(.live(peripheral), error: error))
            }
            
            func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
                subject.send(.centralManagerDidDisconnectPeripheral(peripheral: .live(peripheral), error: error))
            }
            
            func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral:  CBPeripheral) {
                subject.send(.centralManagerConnectionEventDidOccurForPeripheral(event, peripheral: .live(peripheral)))
            }
            func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
                subject.send(.centralManagerDidUpdateANCSAuthorizationForPeripheral(.live(peripheral)))
            }
        }
        
        let subject: PassthroughSubject<DelegateEvent, Never>
        var delegate: Delegate?
        // reuse delegate if one was created before, otherwice it may be overwritten
        if centalManager.delegate != nil, let storedDelegate = centalManager.delegate as? Delegate {
            delegate = storedDelegate
            subject = storedDelegate.subject
        } else {
            precondition(centalManager.delegate == nil, "CBCentralManager.delegate must be nil")
            subject = .init()
            delegate = Delegate(subject: subject)
            centalManager.delegate = delegate
        }
            
        return Self(
            state: { centalManager.state },
            authorization: {
                if #available(iOS 13.1, *) {
                    return CBCentralManager.authorization
                } else {
                    return centalManager.authorization
                }
            },
            delegate: subject
                        .handleEvents(receiveCancel: { delegate = nil })
                        .eraseToAnyPublisher(),
            isScanning: { centalManager.isScanning },
            supportsFeatures: CBCentralManager.supports(_:),
            retrievePeripheralsWithIdentifiers: {
                centalManager.retrievePeripherals(withIdentifiers: $0).map(Peripheral.live)
            },
            retrieveConnectedPeripheralsWithServices: {
                centalManager.retrieveConnectedPeripherals(withServices: $0).map(Peripheral.live)
            },
            scanForPeripheralsWithSerivicesAndOptions: centalManager.scanForPeripherals(withServices:options:),
            stopScan: centalManager.stopScan,
            connectPeripheralWithOptions: { centalManager.connect($0.cb(), options: $1) },
            cancelPeripheralConnection: {
                centalManager.cancelPeripheralConnection($0.cb())
            },
            registerForConnectionEvents: centalManager.registerForConnectionEvents(options:)
        )
    }
}

extension Peripheral {
    public static func live(_ cb: CBPeripheral) -> Self {
        class Delegate: NSObject, CBPeripheralDelegate {
            let subject: PassthroughSubject<DelegateEvent, Never>
            
            init(subject: PassthroughSubject<DelegateEvent, Never>) {
                self.subject = subject
            }
            
            func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
                subject.send(.peripheralDidUpdateName(peripheral.name))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
                subject.send(.peripheralDidModifyServices(invalidatedServices: invalidatedServices.map(Service.live)))
            }

            func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
                subject.send(.peripheralDidUpdateRSSI(error))
            }

            func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
                subject.send(.peripheralDidReadRSSI(error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
                subject.send(.peripheralDidDiscoverServices(error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
                subject.send(.peripheralDidDiscoverIncludedServicesForService(.live(service), error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
                subject.send(.peripheralDidDiscoverCharacteristicsForService(.live(service), error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
                subject.send(.peripheralDidUpdateValueForCharacteristic(.live(characteristic), error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
                subject.send(.peripheralDidWriteValueForCharacteristic(.live(characteristic), error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
                subject.send(.peripheralDidUpdateNotificationStateForCharacteristic(.live(characteristic), error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
                subject.send(.peripheralDidDiscoverDescriptorsForCharacteristic(.live(characteristic), error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
                subject.send(.peripheralDidUpdateValueForDescriptor(.live(descriptor), error: error))
            }
            
            func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
                subject.send(.peripheralDidWriteValueForDescriptor(.live(descriptor), error: error))
            }
            
            func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
                subject.send(.peripheralIsReadyToSendWriteWithoutResponse)
            }
            
            func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
                subject.send(.peripheralDidOpenChannel(error.map(Result.failure) ?? channel.map(L2CAPChannel.live).map(Result.success) ?? .failure(NSError(domain: #function, code: 0, userInfo: nil))))
            }
        }
        
        let subject: PassthroughSubject<DelegateEvent, Never>
        var delegate: Delegate?
        // reuse delegate if one was created before, otherwice it may be overwritten
        if cb.delegate != nil, let storedDelegate = cb.delegate as? Delegate {
            delegate = storedDelegate
            subject = storedDelegate.subject
        } else {
            precondition(cb.delegate == nil, "CBPeripheral.delegate must be nil")
            subject = .init()
            delegate = Delegate(subject: subject)
            cb.delegate = delegate
        }
        
        return Self(
            identifier: { cb.identifier },
            ancsAuthorized: { cb.ancsAuthorized },
            canSendWriteWithoutResponse: { cb.canSendWriteWithoutResponse },
            delegate: subject.handleEvents(receiveCancel: { delegate = nil }).eraseToAnyPublisher(),
            discoverCharacteristicsForService: { cb.discoverCharacteristics($0, for: $1.cb()) },
            discoverDescriptors: { cb.discoverDescriptors(for: $0.cb()) },
            discoverIncludedServicesForService: { cb.discoverIncludedServices($0, for: $1.cb()) },
            discoverServices: { cb.discoverServices($0) },
            maximumWriteValueLength: cb.maximumWriteValueLength(for:) ,
            name: { cb.name },
            openL2CAPChannel: cb.openL2CAPChannel,
            readRSSI: cb.readRSSI,
            readValueForCharasteristic: { cb.readValue(for: $0.cb()) },
            readValueForDescriptor: { cb.readValue(for: $0.cb()) },
            services: { cb.services.map { list in list.map(Service.live) } },
            setNotifyValueEnabledForCharasteristic: { cb.setNotifyValue($0, for:  $1.cb()) },
            state: { cb.state },
            writeValueForDescriptor: { cb.writeValue($0, for: $1.cb()) },
            writeValueForCharacteristicWithType: { cb.writeValue($0, for: $1.cb(), type: $2) },
            cb: { cb }
        )
    }
}

extension Descriptor {
    public static func live(_ cb: CBDescriptor) -> Self {
        Self(
            uuid: { cb.uuid },
            characteristic: { .live(cb.characteristic) },
            value: { cb.value },
            cb: { cb }
        )
    }
}

extension MutableDescriptor {
    public static func live(_ cb: CBMutableDescriptor) -> Self {
        Self(
            uuid: { cb.uuid },
            characteristic: { .live(cb.characteristic) },
            value: { cb.value },
            cb: { cb }
        )
    }
}

extension Characteristic {
    public static func live(_ cb: CBCharacteristic) -> Self {
        Self(
            uuid: { cb.uuid },
            service: { .live(cb.service) },
            properties: { cb.properties },
            value: { cb.value },
            descriptors: { cb.descriptors.map { cbList in cbList.map(Descriptor.live) } },
            isNotifying: { cb.isNotifying },
            cb: { cb }
        )
    }
}

extension Service {
    public static func live(_ cb: CBService) -> Self {
        Self(
            uuid: { cb.uuid },
            peripheral: { .live(cb.peripheral) },
            isPrimary: { cb.isPrimary },
            includedServices: { cb.includedServices.map { list in list.map(Service.live) } },
            characteristics: { cb.characteristics.map { list in list.map(Characteristic.live) } },
            cb: { cb }
        )
    }
}

extension L2CAPChannel {
    public static func live(_ cb: CBL2CAPChannel) -> Self {
        Self(
            peer: { .live(cb.peer) },
            inputStream: { cb.inputStream },
            outputStream: { cb.outputStream },
            psm: { cb.psm },
            cb: { cb }
        )
    }
}

extension Peer {
    public static func live(_ cb: CBPeer) -> Self {
        Self(identifier: { cb.identifier })
    }
}

extension AdvertisementData {
    public static func live(_ rawValue: [String: Any]) -> Self {
        Self(
            isConnectable: rawValue[CBAdvertisementDataIsConnectable] as? Bool,
            localName: rawValue[CBAdvertisementDataLocalNameKey] as? String,
            manufacturerData: rawValue[CBAdvertisementDataManufacturerDataKey] as? Data,
            overflowServiceUUIDs: (rawValue[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]),
            serviceData: (rawValue[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]),
            serviceUUIDs: (rawValue[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]),
            solicitedServiceUUIDs: (rawValue[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]),
            txPowerLevel: (rawValue[CBAdvertisementDataTxPowerLevelKey] as? Double)
        )
    }
}

extension CentralManagerRestoredState {
    public static func live(_ rawValue: [String: Any]) -> Self {
        Self.init(
            peripherals: (rawValue[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral])
                .map { unwrapped in unwrapped.map(Peripheral.live) } ?? [],
            services: rawValue[CBCentralManagerRestoredStateScanServicesKey] as? [CBUUID] ?? [],
            scanOptions: (rawValue[CBCentralManagerRestoredStateScanOptionsKey] as? [String: Any])
                .map(ScanOptions.live)
        )
    }
}

extension ScanOptions {
    public static func live(_ rawValue: [String: Any]) -> Self {
        Self(
            allowDuplicates: rawValue[CBCentralManagerScanOptionAllowDuplicatesKey] as? Bool,
            solicitedServiceUUIDs: rawValue[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] as? [CBUUID]
        )
    }
}
