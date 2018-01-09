//
//  DateComponents+Extensions.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 07.12.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import Foundation

extension DateComponents {

    static func from(bytes: [UInt8]) -> DateComponents? {
        guard bytes.count == 7 else { return nil }
        let intValues = bytes.map { Int($0) }
        let year = intValues[0] + intValues[1] << 8
        return DateComponents(year: year, month: intValues[2], day: intValues[3], hour: intValues[4], minute: intValues[5], second: intValues[6])
    }

    var simpleDescription: String {

        let format2: (Int?) -> String = { value in
            let value = value ?? 0
            return value < 10 ? "0\(value)" : "\(value)"
        }

        return "\(year ?? 0)-\(format2(month))-\(format2(day)) \(format2(hour)):\(format2(minute)):\(format2(second))"
    }
}
