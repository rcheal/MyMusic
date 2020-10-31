//
//  Album+merge.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {
    
    mutating func merge(_ album: Album) {
            
        let lastDisk = contents.last?.disk ?? 1
        for var content in album.contents {
            content.disk = lastDisk + 1
            content.composition?.startDisk = content.disk
            content.single?.disk = content.disk
            addContent(content)
        }
        
    }

}
