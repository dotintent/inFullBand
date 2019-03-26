//
//  CoreBluetooth+Extensions.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 28.11.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBManagerState {

    var description: String {

        switch self {
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
            return "other"
        }
    }
}

extension CBPeripheral {

    var realName: String {
        return self.name ?? "Unnamed peripheral"
    }
}
