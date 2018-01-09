//
//  MiBandConstants.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 28.11.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import Foundation

enum MiCharacteristicID: String {
    case dateTime = "2A2B"
    case alert = "2A06"
    case heartRateMeasurement = "2A37"
    case heartRateControlPoint = "2A39"
    case battery = "00000006-0000-3512-2118-0009AF100700"
    case activity = "00000007-0000-3512-2118-0009AF100700"
}

struct AlertMode {
    static let off: UInt8 = 0x0
    static let mild: UInt8 = 0x1
    static let high: UInt8 = 0x2

    private init() {}
}

struct HeartRateReadingMode {
    static let sleep: UInt8 = 0x0
    static let continuous: UInt8 = 0x1
    static let manual: UInt8 = 0x2

    private init() {}
}

struct Toggle {
    static let off: UInt8 = 0x0
    static let on: UInt8 = 0x1

    private init() {}
}

struct MiCommand {
    static let startHeartRateMonitoring: [UInt8] = [0x15, HeartRateReadingMode.continuous, Toggle.on]
    static let stopHeartRateMonitoring: [UInt8] = [0x15, HeartRateReadingMode.continuous, Toggle.off]
    static let startHeartRateMeasurement: [UInt8] = [0x15, HeartRateReadingMode.manual, Toggle.on]
    static let stopHeartRateMeasurement: [UInt8] = [0x15, HeartRateReadingMode.manual, Toggle.off]
}
