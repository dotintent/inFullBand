//
//  MiBandService.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 28.11.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import Foundation
import CoreBluetooth

class MiBandService: NSObject {

    typealias LoggerFuction = (LogEntry) -> Void

    // MARK: - Properties

    private let updatableIDs: [MiCharacteristicID] = [.dateTime, .activity, .battery]
    private let monitoredIDs: [MiCharacteristicID] = [.heartRateMeasurement, .activity, .deviceEvent]

    private var externalLog: LoggerFuction
    private var externalSpecialLog: LoggerFuction
    private lazy var manager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)

    private var miBand: CBPeripheral? {
        didSet {
            oldValue?.delegate = nil
            updatableCharacteristics = []
            guard let miBand = miBand else { return }
            miBand.delegate = self
        }
    }

    private var discoveredPeripherals: [CBPeripheral] = []
    private var updatableCharacteristics: [CBCharacteristic] = []
    private var hrControlPointCharacteristic: CBCharacteristic?
    private var alertCharacteristic: CBCharacteristic?

    // MARK: - Init

    init(log: @escaping LoggerFuction, specialLog: @escaping LoggerFuction) {
        self.externalLog = log
        self.externalSpecialLog = specialLog
        super.init()
        _ = manager
    }

    // MARK: - Actions

    func discoverPeripherals() {
        manager.scanForPeripherals(withServices: nil, options: nil)
    }

    func connectToPeripheral(at index: Int) {
        manager.connect(discoveredPeripherals[index], options: nil)
    }

    func disconnect() {
        guard let miBand = miBand else {
            errorLog("Disconnect: Mi Band not discovered!")
            return
        }
        manager.cancelPeripheralConnection(miBand)
    }

    func updateStats() {
        guard let miBand = miBand else {
            errorLog("Update: Mi Band not discovered!")
            return
        }
        log("🔄", "Update stats")
        updatableCharacteristics.forEach {
            miBand.readValue(for: $0)
        }
    }

    func startMonitoringHeartRate() {
        guard let miBand = miBand, let hrControlPoint = hrControlPointCharacteristic else {
            errorLog("Start: Invalid setup!")
            return
        }
        miBand.writeValue(Data(MiCommand.startHeartRateMonitoring), for: hrControlPoint, type: .withResponse)
        log("❤️", "Start monitoring")
    }

    func stopMonitorigHeartRate() {
        guard let miBand = miBand, let hrControlPoint = hrControlPointCharacteristic else {
            errorLog("Stop: Invalid setup!")
            return
        }
        miBand.writeValue(Data(MiCommand.stopHeartRateMonitoring), for: hrControlPoint, type: .withResponse)
        miBand.writeValue(Data(MiCommand.stopHeartRateMeasurement), for: hrControlPoint, type: .withResponse)
        log("❤️", "Stop monitoring / measurement")
    }

    func measureHeartRate() {
        guard let miBand = miBand, let hrControlPoint = hrControlPointCharacteristic else {
            errorLog("Single measurement: Invalid setup!")
            return
        }
        miBand.writeValue(Data(MiCommand.startHeartRateMeasurement), for: hrControlPoint, type: .withResponse)
        log("❤️", "Single measurement")
    }

    func setHighAlert() {
        guard let miBand = miBand, let alertCharacteristic = alertCharacteristic else {
            errorLog("Set high alert: Invalid setup!")
            return
        }
        miBand.writeValue(Data([AlertMode.high]), for: alertCharacteristic, type: .withoutResponse)
        log("📞", "Alert On")
    }

    func setMildAlert() {
        guard let miBand = miBand, let alertCharacteristic = alertCharacteristic else {
            errorLog("Set mild alert: Invalid setup!")
            return
        }
        miBand.writeValue(Data([AlertMode.mild]), for: alertCharacteristic, type: .withoutResponse)
        log("✉️", "Alert On")
    }

    func unsetAlert() {
        guard let miBand = miBand, let alertCharacteristic = alertCharacteristic else {
            errorLog("Unset alert: Invalid setup!")
            return
        }
        miBand.writeValue(Data([AlertMode.off]), for: alertCharacteristic, type: .withoutResponse)
        log("❕", "Alert Off")
    }

    // MARK: - Handling

    func handleCharacteristicValueUpdate(characteristicID: MiCharacteristicID, valueBytes: [UInt8]) {

        switch characteristicID {
        case .dateTime:
            guard let dateString = DateComponents.from(bytes: Array(valueBytes[0...6]))?.simpleDescription else { return }
            log("⏰", "Time:", "\(dateString)")

        case .heartRateMeasurement:
            let heartRate = valueBytes[1]
            log("❤️", "Heart rate:", "\(heartRate) BPM")

        case .activity:
            guard let stepsCount = UInt32.from(bytes: Array(valueBytes[1...4])),
                let meters = UInt32.from(bytes: Array(valueBytes[5...8])),
                let calories = UInt32.from(bytes: Array(valueBytes[9...12])) else { return }
            log("👞", "Distance:", "\(stepsCount) steps, \(meters) m, \(calories) kcal")

        case .battery:
            let batteryPercentage = valueBytes[1]
            guard let lastChargeDateString = DateComponents.from(bytes: Array(valueBytes[11...17]))?.simpleDescription else { return }
            log("🔋", "Battery: ", "\(batteryPercentage) %, charged: \(lastChargeDateString)")

        case .deviceEvent:
            guard valueBytes.count >= 1, valueBytes[0] == DeviceEvent.buttonPressed else { return }
            log("💡", "Button pressed")

        default:
            break
        }
    }
}

extension MiBandService: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("📳", "Bluetooth state: ", "\(central.state.description)")

        if central.state == .poweredOn, miBand == nil {
            self.discoverPeripherals()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        specialLog("🌎", "Discovered:", "\(peripheral.realName)")

        discoveredPeripherals.append(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("✅", "Connected to:", "\(peripheral.realName)")
        miBand = peripheral
        manager.stopScan()
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        errorLog("Error: \(error.debugDescription), \(peripheral.realName)")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log("❌", "Disconnected" + (error != nil ? ", with error: \(error!)" : ""))
        if error == nil {
            self.miBand = nil
        }
    }
}

extension MiBandService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(array: peripheral.services?.map({ ($0, $0.uuid.uuidString) }))
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("\n\(service)")
        print(array: service.characteristics?.map({ ($0, $0.uuid.uuidString) }))
        service.characteristics?.forEach { characteristic in

            guard let miCharacteristicID = MiCharacteristicID(rawValue: characteristic.uuid.uuidString) else { return }

            if updatableIDs.contains(miCharacteristicID) {
                peripheral.readValue(for: characteristic)
                updatableCharacteristics.append(characteristic)
            }
            if monitoredIDs.contains(miCharacteristicID) {
                peripheral.setNotifyValue(true, for: characteristic)
            }

            switch miCharacteristicID {
            case .heartRateControlPoint:
                hrControlPointCharacteristic = characteristic
            case .alert:
                alertCharacteristic = characteristic
            default:
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        guard let miCharacteristicID = MiCharacteristicID(rawValue: characteristic.uuid.uuidString),
            updatableIDs.contains(miCharacteristicID) || monitoredIDs.contains(miCharacteristicID) else { return }

        guard let value = characteristic.value else {
            print("New value: null for: \(characteristic)")
            return
        }

        let valueBytes = value.bytes()
        let hexValue = value.chunkedHexEncodedString()

        print("New value: \(hexValue) for: \(characteristic)")

        self.handleCharacteristicValueUpdate(characteristicID: miCharacteristicID, valueBytes: valueBytes)
    }
}

extension MiBandService {

    func log(_ emoji: String, _ title: String, _ subtitle: String = "") {
        externalLog(LogEntry(emoji: emoji, title: title, subtitle: subtitle))
    }

    func specialLog(_ emoji: String, _ title: String, _ subtitle: String = "") {
        externalSpecialLog(LogEntry(emoji: emoji, title: title, subtitle: subtitle))
    }

    func errorLog(_ title: String, _ subtitle: String = "") {
        externalLog(LogEntry(emoji: "🛑", title: title, subtitle: subtitle))
    }
}
