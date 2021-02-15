//
//  Interface.swift
//  CoreBluetoothClient
//
//  Created by Igor Kravchenko on 09.02.2021.
//

import CoreBluetooth
import Combine

public struct CentralManager {
    public var state: () -> CBManagerState
    public var authorization: () -> CBManagerAuthorization
    public var delegate: AnyPublisher<DelegateEvent, Never>
    public var isScanning: () -> Bool
    public var supportsFeatures: (CBCentralManager.Feature) -> Bool
    public var retrievePeripheralsWithIdentifiers: ([UUID]) -> [Peripheral]
    public var retrieveConnectedPeripheralsWithServices: ([CBUUID]) -> [Peripheral]
    public var scanForPeripheralsWithSerivicesAndOptions: ([CBUUID]?, [String: Any]?) -> Void
    public var stopScan: () -> Void
    public var connectPeripheralWithOptions: (_ peripheral: Peripheral, _ options: [String : Any]?) -> Void
    public var cancelPeripheralConnection: (Peripheral) -> Void
    public var registerForConnectionEvents: ([CBConnectionEventMatchingOption : Any]?) -> Void
    
    public init(
        state: @escaping () -> CBManagerState,
        authorization: @escaping () -> CBManagerAuthorization,
        delegate: AnyPublisher<CentralManager.DelegateEvent, Never>,
        isScanning: @escaping () -> Bool,
        supportsFeatures: @escaping (CBCentralManager.Feature) -> Bool,
        retrievePeripheralsWithIdentifiers: @escaping ([UUID]) -> [Peripheral],
        retrieveConnectedPeripheralsWithServices: @escaping ([CBUUID]) -> [Peripheral],
        scanForPeripheralsWithSerivicesAndOptions: @escaping ([CBUUID]?, [String : Any]?) -> Void,
        stopScan: @escaping () -> Void,
        connectPeripheralWithOptions: @escaping (Peripheral, [String : Any]?) -> Void,
        cancelPeripheralConnection: @escaping (Peripheral) -> Void,
        registerForConnectionEvents: @escaping ([CBConnectionEventMatchingOption : Any]?) -> Void
    ) {
        self.state = state
        self.authorization = authorization
        self.delegate = delegate
        self.isScanning = isScanning
        self.supportsFeatures = supportsFeatures
        self.retrievePeripheralsWithIdentifiers = retrievePeripheralsWithIdentifiers
        self.retrieveConnectedPeripheralsWithServices = retrieveConnectedPeripheralsWithServices
        self.scanForPeripheralsWithSerivicesAndOptions = scanForPeripheralsWithSerivicesAndOptions
        self.stopScan = stopScan
        self.connectPeripheralWithOptions = connectPeripheralWithOptions
        self.cancelPeripheralConnection = cancelPeripheralConnection
        self.registerForConnectionEvents = registerForConnectionEvents
    }

    public enum DelegateEvent {
        case centralManagerDidUpdateState(CBManagerState)
        case centralManagerWillRestoreState([String : Any])
        case centralManagerDidDiscover(peripheral: Peripheral, advertisementData: AdvertisementData, rssi: NSNumber)
        case centralManagerDidConnectPeripheral(Peripheral)
        case centralManagerDidFailToConnectPeripheral(Peripheral, error: Error?)
        case centralManagerDidDisconnectPeripheral(peripheral: Peripheral, error: Error?)
        case centralManagerConnectionEventDidOccurForPeripheral(CBConnectionEvent, peripheral:  Peripheral)
        case centralManagerDidUpdateANCSAuthorizationForPeripheral(Peripheral)
    }
}

extension CentralManager {
    public static func stateAsString(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        @unknown default:
            return "unknown default"
        }
    }
}

public struct Peripheral {
    public var identifier: () -> UUID
    public var ancsAuthorized: () -> Bool
    public var canSendWriteWithoutResponse: () -> Bool
    public var delegate: AnyPublisher<DelegateEvent, Never>
    public var discoverCharacteristicsForService: ([CBUUID]?, Service) -> Void
    public var discoverDescriptors: (Characteristic) -> Void
    public var discoverIncludedServicesForService: ([CBUUID]?, Service) -> Void
    public var discoverServices: ([CBUUID]?) -> Void
    public var maximumWriteValueLength: (CBCharacteristicWriteType) -> Int
    public var name: () -> String?
    public var openL2CAPChannel: (CBL2CAPPSM) -> Void
    public var readRSSI: () -> Void
    public var readValueForCharasteristic: (Characteristic) -> Void
    public var readValueForDescriptor: (Descriptor) -> Void
    public var services: () -> [Service]?
    public var setNotifyValueEnabledForCharasteristic: (Bool, Characteristic) -> Void
    public var state: () -> CBPeripheralState
    public var writeValueForDescriptor: (Data, Descriptor) -> Void
    public var writeValueForCharacteristicWithType: (Data, Characteristic, CBCharacteristicWriteType) -> Void
    public var cb: () -> CBPeripheral
    
    public init(
        identifier: @escaping () -> UUID,
        ancsAuthorized: @escaping () -> Bool,
        canSendWriteWithoutResponse: @escaping () -> Bool,
        delegate: AnyPublisher<Peripheral.DelegateEvent, Never>,
        discoverCharacteristicsForService: @escaping ([CBUUID]?, Service) -> Void,
        discoverDescriptors: @escaping (Characteristic) -> Void,
        discoverIncludedServicesForService: @escaping ([CBUUID]?, Service) -> Void,
        discoverServices: @escaping ([CBUUID]?) -> Void,
        maximumWriteValueLength: @escaping (CBCharacteristicWriteType) -> Int,
        name: @escaping () -> String?,
        openL2CAPChannel: @escaping (CBL2CAPPSM) -> Void,
        readRSSI: @escaping () -> Void,
        readValueForCharasteristic: @escaping (Characteristic) -> Void,
        readValueForDescriptor: @escaping (Descriptor) -> Void,
        services: @escaping () -> [Service]?,
        setNotifyValueEnabledForCharasteristic: @escaping (Bool, Characteristic) -> Void,
        state: @escaping () -> CBPeripheralState,
        writeValueForDescriptor: @escaping (Data, Descriptor) -> Void,
        writeValueForCharacteristicWithType: @escaping (Data, Characteristic, CBCharacteristicWriteType) -> Void,
        cb: @escaping () -> CBPeripheral
    ) {
        self.identifier = identifier
        self.ancsAuthorized = ancsAuthorized
        self.canSendWriteWithoutResponse = canSendWriteWithoutResponse
        self.delegate = delegate
        self.discoverCharacteristicsForService = discoverCharacteristicsForService
        self.discoverDescriptors = discoverDescriptors
        self.discoverIncludedServicesForService = discoverIncludedServicesForService
        self.discoverServices = discoverServices
        self.maximumWriteValueLength = maximumWriteValueLength
        self.name = name
        self.openL2CAPChannel = openL2CAPChannel
        self.readRSSI = readRSSI
        self.readValueForCharasteristic = readValueForCharasteristic
        self.readValueForDescriptor = readValueForDescriptor
        self.services = services
        self.setNotifyValueEnabledForCharasteristic = setNotifyValueEnabledForCharasteristic
        self.state = state
        self.writeValueForDescriptor = writeValueForDescriptor
        self.writeValueForCharacteristicWithType = writeValueForCharacteristicWithType
        self.cb = cb
    }
    
    public enum DelegateEvent {
        case peripheralDidUpdateName(String?)
        case peripheralDidModifyServices(invalidatedServices: [Service])
        case peripheralDidUpdateRSSI(Error?)
        case peripheralDidReadRSSI(Error?)
        case peripheralDidDiscoverServices(Error?)
        case peripheralDidDiscoverIncludedServicesForService(Service, Error?)
        case peripheralDidDiscoverCharacteristicsForService(Service, Error?)
        case peripheralDidUpdateValueForCharacteristic(Characteristic, Error?)
        case peripheralDidWriteValueForCharacteristic(Characteristic, Error?)
        case peripheralDidUpdateNotificationStateForCharacteristic(Characteristic, Error?)
        case peripheralDidDiscoverDescriptorsForCharacteristic(Characteristic, Error?)
        case peripheralDidUpdateValueForDescriptor(Descriptor, error: Error?)
        case peripheralDidWriteValueForDescriptor(Descriptor, error: Error?)
        case peripheralIsReadyToSendWriteWithoutResponse
        case peripheralDidOpenChannel(Result<L2CAPChannel, Error>)
    }
}

extension Peripheral {
    public static func stateAsString(_ state: CBPeripheralState) -> String {
        switch state {
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .disconnecting:
            return "disconnecting"
        @unknown default:
            return "unknown default"
        }
    }
}

public struct Descriptor {
    public var uuid: () -> CBUUID
    public var characteristic: () -> Characteristic
    public var value: () -> Any?
    public var cb: () -> CBDescriptor
    
    public init(
        uuid: @escaping () -> CBUUID,
        characteristic: @escaping () -> Characteristic,
        value: @escaping () -> Any?,
        cb: @escaping () -> CBDescriptor
    ) {
        self.uuid = uuid
        self.characteristic = characteristic
        self.value = value
        self.cb = cb
    }
}

public struct MutableDescriptor {
    public var uuid: () -> CBUUID
    public var characteristic: () -> Characteristic
    public var value: () -> Any?
    public var cb: () -> CBMutableDescriptor
    
    public init(
        uuid: @escaping () -> CBUUID,
        characteristic: @escaping () -> Characteristic,
        value: @escaping () -> Any?,
        cb: @escaping () -> CBMutableDescriptor
    ) {
        self.uuid = uuid
        self.characteristic = characteristic
        self.value = value
        self.cb = cb
    }
}

public struct Characteristic {
    public var uuid: () -> CBUUID
    public var service: () -> Service
    public var properties: () -> CBCharacteristicProperties
    public var value: () -> Data?
    public var descriptors: () -> [Descriptor]?
    public var isNotifying: () -> Bool
    public var cb: () -> CBCharacteristic
    
    public init(
        uuid: @escaping () -> CBUUID,
        service: @escaping () -> Service,
        properties: @escaping () -> CBCharacteristicProperties,
        value: @escaping () -> Data?,
        descriptors: @escaping () -> [Descriptor]?,
        isNotifying: @escaping () -> Bool,
        cb: @escaping () -> CBCharacteristic
    ) {
        self.uuid = uuid
        self.service = service
        self.properties = properties
        self.value = value
        self.descriptors = descriptors
        self.isNotifying = isNotifying
        self.cb = cb
    }
}

public struct Service {
    public var uuid: () -> CBUUID
    public var peripheral: () -> Peripheral
    public var isPrimary: () -> Bool
    public var includedServices: () -> [Service]?
    public var characteristics: () -> [Characteristic]?
    public var cb: () -> CBService
    
    public init(
        uuid: @escaping () -> CBUUID,
        peripheral: @escaping () -> Peripheral,
        isPrimary: @escaping () -> Bool,
        includedServices: @escaping () -> [Service]?,
        characteristics: @escaping () -> [Characteristic]?,
        cb: @escaping () -> CBService
    ) {
        self.uuid = uuid
        self.peripheral = peripheral
        self.isPrimary = isPrimary
        self.includedServices = includedServices
        self.characteristics = characteristics
        self.cb = cb
    }
}

public struct L2CAPChannel {
    public var peer: () -> Peer
    public var inputStream: () -> InputStream
    public var outputStream: () -> OutputStream
    public var psm: () -> CBL2CAPPSM
    public var cb: () -> CBL2CAPChannel
    
    public init(
        peer: @escaping () -> Peer,
        inputStream: @escaping () -> InputStream,
        outputStream: @escaping () -> OutputStream,
        psm: @escaping () -> CBL2CAPPSM,
        cb: @escaping () -> CBL2CAPChannel
    ) {
        self.peer = peer
        self.inputStream = inputStream
        self.outputStream = outputStream
        self.psm = psm
        self.cb = cb
    }
}

public struct Peer {
    public var identifier: () -> UUID
    
    public init(identifier: @escaping () -> UUID) {
        self.identifier = identifier
    }
}

public struct AdvertisementData: Equatable {
    /// A Boolean value that indicates whether the advertising event type is connectable.
    public var isConnectable: Bool?
    /// The local name of a peripheral.
    public var localName: String?
    /// The manufacturer data of a peripheral.
    public var manufacturerData: Data?
    /// An array of UUIDs found in the overflow area of the advertisement data.
    public var overflowServiceUUIDs: [CBUUID]?
    /// A dictionary that contains service-specific advertisement data.
    public var serviceData: [CBUUID: Data]?
    /// An array of service UUIDs.
    public var serviceUUIDs: [CBUUID]?
    /// An array of solicited service UUIDs.
    public var solicitedServiceUUIDs: [CBUUID]?
    /// The transmit power of a peripheral.
    public var txPowerLevel: Double?
    
    public init(
        isConnectable: Bool?,
        localName: String?,
        manufacturerData: Data?,
        overflowServiceUUIDs: [CBUUID]?,
        serviceData: [CBUUID: Data]?,
        serviceUUIDs: [CBUUID]?,
        solicitedServiceUUIDs: [CBUUID]?,
        txPowerLevel: Double?
    ) {
        self.isConnectable = isConnectable
        self.localName = localName
        self.manufacturerData = manufacturerData
        self.overflowServiceUUIDs = overflowServiceUUIDs
        self.serviceData = serviceData
        self.serviceUUIDs = serviceUUIDs
        self.solicitedServiceUUIDs = solicitedServiceUUIDs
        self.txPowerLevel = txPowerLevel
    }
    
}


