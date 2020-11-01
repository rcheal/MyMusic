//
//  Album+merge.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {
    
    private func mergeStrings(_ a: String?, _ b: String?) -> String? {
        var result: String?
        if a == nil {
            result = b
        } else if b == nil {
            result = a
        } else if a != b {
            let prefix = a!.commonPrefix(with: b!)
            if prefix.isEmpty {
                result = a! + "$" + b!
            } else {
                var a2 = a!
                var b2 = b!
                a2.removeSubrange(a2.range(of: prefix)!)
                b2.removeSubrange(b2.range(of: prefix)!)
                result = prefix + "$" + a2 + "$" + b2
            }
        }
        return result
    }
    
    public mutating func merge(_ album: Album) {
         
        // Merge Album metadata
        title = mergeStrings(title, album.title)!
        subtitle = mergeStrings(subtitle, album.subtitle)
        artist = mergeStrings(artist, album.artist)
        composer = mergeStrings(composer, album.composer)
        conductor = mergeStrings(conductor, album.conductor)
        orchestra = mergeStrings(orchestra, album.orchestra)
        lyricist = mergeStrings(lyricist, album.lyricist)
        genre = mergeStrings(genre, album.genre)
        publisher = mergeStrings(publisher, album.publisher)
        copyright = mergeStrings(copyright, album.copyright)
        encodedBy = mergeStrings(encodedBy, album.encodedBy)
        encoderSettings = mergeStrings(encoderSettings, album.encoderSettings)
        
        // Merge contents
        for index in contents.indices {
            if let composition = contents[index].composition {
                for index2 in composition.contents.indices {
                    var single = composition.contents[index2]
                    if single.disk == nil {
                        single.disk = 1
                        contents[index].composition?.contents[index2] = single
                    }
                }
            } else if var single = contents[index].single {
                if single.disk == nil {
                    single.disk = 1
                    contents[index].single = single
                }
            }
        }
        let lastDisk = contents.last?.disk ?? 1
        for var content in album.contents {
            if let composition = content.composition {
                for index in composition.contents.indices {
                    var single = composition.contents[index]
                    single.disk = lastDisk + 1
                    content.composition?.contents[index] = single
                }
            } else if var single = content.single {
                single.disk = lastDisk + 1
                content.single = single
            }
            addContent(content)
        }
        
        update()
        
    }

}
