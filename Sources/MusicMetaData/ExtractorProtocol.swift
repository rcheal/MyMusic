//
//  ExtractorProtocol.swift
//  
//
//  Created by Robert Cheal on 9/10/20.
//

import Foundation

protocol ExtractorProtocol {
    var filename: String { get }

    var relativeFilename: String { get }

    mutating func removeItem(_ type: MetadataType) 
    func getDataItem(_ type: MetadataType) -> MetadataItem?
    mutating func extractTags() -> (Bool, String) 
    func printAudioFile()
    func getImage(_ type: MetadataImageType) -> (String, Data)?


}
