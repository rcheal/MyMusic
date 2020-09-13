//
//  NSImage+Data.swift
//  MyMusicManager
//
//  Created by Robert Cheal on 9/1/20.
//

import Foundation
import Cocoa

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:])}
    var jpg: Data? { representation(using: .jpeg, properties: [:])}
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self)}
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png}
    var jpg: Data? { tiffRepresentation?.bitmap?.jpg}
}

