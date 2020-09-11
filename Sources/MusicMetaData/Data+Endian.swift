//
//  Data+Endian.swift
//  
//
//  Created by Robert Cheal on 9/7/20.
//

import Foundation

extension Data {

    func int8() -> UInt8 {
        return UInt8(self[startIndex])
    }
    
    func bigEndian16() -> Int {
        var index = startIndex
        var value: Int = Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        return value
    }
    
    func bigEndian24() -> Int {
        var index = startIndex
        var value: Int = Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        return value
    }
    
    func bigEndian32() -> Int {
        var index = startIndex
        var value: Int = Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        return value
    }
    
    func bigEndian40() -> Int {
        var index = startIndex
        var value: Int = Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        index += 1
        value <<= 8
        value += Int(self[index])
        return value

    }
    
    func littleEndian32() -> UInt32 {
        var index = endIndex-1
        var value: UInt32 = UInt32(self[index])
        index -= 1
        value <<= 8
        value += UInt32(self[index])
        index -= 1
        value <<= 8
        value += UInt32(self[index])
        index -= 1
        value <<= 8
        value += UInt32(self[index])
        return value
    }
}

