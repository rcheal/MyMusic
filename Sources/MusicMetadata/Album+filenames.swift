//
//  File.swift
//  
//
//  Created by Robert Cheal on 2/23/21.
//

import Foundation

extension Album {
    public func getFilenames(album: Album) -> [String] {
        var filenames = [String]()
        // Add artwork filenames
        filenames = getArtworkFilenames()
        // Add audio track filenames
        filenames.append(contentsOf: getAudioFilenames())
        return filenames
    }

    public func getArtworkFilenames() -> [String] {
        var filenames = [String]()
        let count = artworkCount()
        if count > 0 {
            for index in 0..<count {
                if let filename = artRef(index)?.filename {
                    filenames.append(filename)
                }
            }
        }
        return filenames
    }
    
    public func getAudioFilenames() -> [String] {
        var filenames: [String] = []
        for content in contents {
            if let single = content.single {
                filenames.append(single.filename)
            } else if let composition = content.composition {
                for movement in composition.movements {
                    filenames.append(movement.filename)
                }
            }
        }
        return filenames
    }

}
