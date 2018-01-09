//
//  Array+Extensions.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 28.11.2017.
//  Copyright © 2017 inFullMobile. All rights reserved.
//

import Foundation

func print<T>(array: [T]?) {
    guard let array = array, array.isEmpty == false else {
        print("[]")
        return
    }

    array.enumerated().forEach {
        switch $0.offset {
        case ...0:
            print("[\($0.element),")
        case 1..<(array.count - 1):
            print(" \($0.element),")
        default:
            print(" \($0.element)]")
        }
    }
}
