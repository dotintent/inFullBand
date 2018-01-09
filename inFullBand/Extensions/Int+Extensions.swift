//
//  Int+Extensions.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 07.12.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import Foundation

extension UInt32 {

    static func from(bytes: [UInt8]) -> UInt32? {
        guard bytes.count <= 4 else { return nil }
        return bytes
            .enumerated()
            .map { UInt32($0.element) << UInt32($0.offset * 8) }
            .reduce(0, +)
    }
}
