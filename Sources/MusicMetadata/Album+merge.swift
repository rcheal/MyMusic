//
//  Album+merge.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

private let delim = "$"

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
                result = a! + delim + b!
            } else {
                var a2 = a!
                var b2 = b!
                a2.removeSubrange(a2.range(of: prefix)!)
                b2.removeSubrange(b2.range(of: prefix)!)
                result = prefix + delim + a2 + delim + b2
            }
        } else {    // a == b
            result = a
        }
        return result
    }
    
    private func splitString(_ string: String?, count: Int) -> [String]? {
        var result: [String] = []
        if let s = string {
            let values = s.components(separatedBy: delim)
            if values.count == count {
                result = values
            } else if values.count == (count + 1) {
                let prefix = values[0]
                for suffixIndex in 1...count {
                    result.append(prefix + values[suffixIndex])
                }
            } else {
                for _ in 1...count {
                    result.append(s)
                }
            }
            return result
        }
        return nil
    }
    
    public func mergeYears(_ yeara: Int?, _ yearb: Int?) -> Int? {
        if yeara == nil {
            return yearb
        } else if yearb == nil {
            return yeara
        }
         
        return max(yeara!, yearb!)
    }
    
    public func mergeSupportingArtists(_ artistsa: String?, _ artistsb: String?) -> String? {
        if var contentsa = artistsa?.components(separatedBy: "\n") {
            if let contentsb = artistsb?.components(separatedBy: "\n") {
                for content in contentsb {
                    if !contentsa.contains(content) {
                        contentsa.append(content)
                    }
                }
                return contentsa.joined(separator: "\n")
            }
                
            return artistsa
        }
        
        return artistsb
    }
    
    public mutating func mergeAlbumArt(_ albumArta: AlbumArtwork, _ albumArtb: AlbumArtwork) -> AlbumArtwork {
        
        var resultArt: AlbumArtwork = AlbumArtwork()
        if albumArta.count > 0 {
            if albumArtb.count > 0 {
                // Merge front art
                if let front = albumArta.frontArtRef() {
                    resultArt.addArt(front)
                    if var front2 = albumArtb.frontArtRef() {
                        resultArt.addArt(front)
                        // Add albumArtb front artwork as page...
                        front2.type = .page
                        resultArt.addArt(front2)
                    } else {
                        resultArt.addArt(front)
                    }
                } else {
                    if let front2 = albumArtb.frontArtRef() {
                        resultArt.addArt(front2)
                    }
                }

                // Merge pages

                // Add albumArta pages
                var pageNumber = 1
                while let page = albumArta.pageArtRef(pageNumber) {
                    resultArt.addArt(page)
                    pageNumber += 1
                }
                
                // Add albumArtb pages
                pageNumber = 1
                while let page = albumArtb.pageArtRef(pageNumber) {
                    resultArt.addArt(page)
                    pageNumber += 1
                }
                
                // Merge back art
                if let back = albumArta.backArtRef() {
                    resultArt.addArt(back)
                    if var back2 = albumArtb.backArtRef() {
                        resultArt.addArt(back)
                        // Add albumArtb back artwork as page...
                        back2.type = .page
                        resultArt.addArt(back2)
                    } else {
                        resultArt.addArt(back)
                    }
                } else {
                    if let back2 = albumArtb.backArtRef() {
                        resultArt.addArt(back2)
                    }
                }

            } else {
                resultArt = albumArta
            }
        } else {
            resultArt = albumArtb
        }
        return resultArt
    }
    
    public mutating func merge(_ album: Album) {
         
        // Merge Album metadata
        title = mergeStrings(title, album.title)!
        subtitle = mergeStrings(subtitle, album.subtitle)
        artist = mergeStrings(artist, album.artist)
        supportingArtists = mergeSupportingArtists(supportingArtists, album.supportingArtists)
        composer = mergeStrings(composer, album.composer)
        conductor = mergeStrings(conductor, album.conductor)
        orchestra = mergeStrings(orchestra, album.orchestra)
        lyricist = mergeStrings(lyricist, album.lyricist)
        genre = mergeStrings(genre, album.genre)
        publisher = mergeStrings(publisher, album.publisher)
        copyright = mergeStrings(copyright, album.copyright)
        encodedBy = mergeStrings(encodedBy, album.encodedBy)
        encoderSettings = mergeStrings(encoderSettings, album.encoderSettings)
        recordingYear = mergeYears(recordingYear, album.recordingYear)
        albumArt = mergeAlbumArt(albumArt, album.albumArt)
        
        // Merge contents
        for index in contents.indices {
            if let composition = contents[index].composition {
                for index2 in composition.movements.indices {
                    let movement = composition.movements[index2]
                    if movement.disk == nil {
                        contents[index].composition?.movements[index2].disk = 1
                    }
                }
            } else if let single = contents[index].single {
                if single.disk == nil {
                    contents[index].single?.disk = 1
                }
            }
        }
        let lastDisk = contents.last?.disk ?? 1
        for var content in album.contents {
            if let composition = content.composition {
                for index in composition.movements.indices {
                    var movement = composition.movements[index]
                    movement.disk = lastDisk + 1
                    content.composition?.movements[index] = movement
                }
            } else if var single = content.single {
                single.disk = lastDisk + 1
                content.single = single
                content.disk = single.disk
                content.track = single.track
            }
            addContent(content)
        }
        
        update()
        
    }
    
    private mutating func setDisk(_ disk: Int?) {
        for index in contents.indices {
            if let composition = contents[index].composition {
                for index2 in composition.movements.indices {
                    var movement = composition.movements[index2]
                    movement.disk = disk
                    contents[index].composition?.movements[index2] = movement
                }
            } else if var single = contents[index].single {
                single.disk = disk
                contents[index].single = single
            }
        }
    }
    
    public mutating func split() -> [Album] {
        var lastDisk: Int = 1
        var album = self
        var albums: [Album] = []
        album.removeAllContents()
        
        sortContents()
        
        for content in contents {
            let disk = content.disk ?? 1
            if disk > lastDisk {
                album.setDisk(nil)
                album.updateDuration()
                album.update()
                albums.append(album)
                album = self
                album.removeAllContents()
                lastDisk = disk
            }
            album.addContent(content)
        }
        album.setDisk(nil)
        album.updateDuration()
        album.update()
        
        albums.append(album)
        
        let resultAlbumCount = albums.count
        
        let titles = splitString(title, count: resultAlbumCount)
        let subtitles = splitString(subtitle, count: resultAlbumCount)
        let artists = splitString(artist, count: resultAlbumCount)
        let composers = splitString(composer, count: resultAlbumCount)
        let conductors = splitString(conductor, count: resultAlbumCount)
        let orchestras = splitString(orchestra, count: resultAlbumCount)
        let lyricists = splitString(lyricist, count: resultAlbumCount)
        let genres = splitString(genre, count: resultAlbumCount)
        let publishers = splitString(publisher, count: resultAlbumCount)
        let copyrights = splitString(copyright, count: resultAlbumCount)
        let encodedBys = splitString(encodedBy, count: resultAlbumCount)
        let encodersSettings = splitString(encoderSettings, count: resultAlbumCount)

        for index in albums.indices {
            albums[index].title = titles![index]
            albums[index].subtitle = subtitles?[index]
            albums[index].artist = artists?[index]
            albums[index].composer = composers?[index]
            albums[index].conductor = conductors?[index]
            albums[index].orchestra = orchestras?[index]
            albums[index].lyricist = lyricists?[index]
            albums[index].genre = genres?[index]
            albums[index].publisher = publishers?[index]
            albums[index].copyright = copyrights?[index]
            albums[index].encodedBy = encodedBys?[index]
            albums[index].encoderSettings = encodersSettings?[index]
        }

        return albums
    }

}
