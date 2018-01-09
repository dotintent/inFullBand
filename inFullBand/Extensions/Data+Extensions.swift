//
//  Data+Extensions.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 28.11.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import Foundation

extension Data {

    func chunkedHexEncodedString() -> String {
        let bytes = self.bytes()
        let chunkSize = 4
        return stride(from: 0, to: bytes.count, by: chunkSize)
            .map {
                Array(bytes[$0..<Swift.min($0 + chunkSize, bytes.count)])
                    .map { String(format: "%02hhx", $0) }
                    .joined()
            }
            .joined(separator: " ")
    }

    func bytes() -> [UInt8] {
        return self.map({ $0 })
    }
}
