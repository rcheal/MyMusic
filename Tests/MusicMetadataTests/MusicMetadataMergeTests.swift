//
//  MusicMetadataMergeTests.swift
//  
//
//  Created by Robert Cheal on 12/11/20.
//

import XCTest
@testable import MusicMetadata


@available(OSX 11.0, *)
final class MusicMetadataMergeTests: XCTestCase {
    
    func createAlbum(_ group1: Int, group2: Int? = nil) -> Album {
        var album = Album(title: "My Album")
        
        if group1 == 1 {
            album.title += " [Disk 1]"
            album.subtitle = "ASubtitle"
            album.artist = "D1 Artist"
            album.supportingArtists = "Yo yo Ma\nEmanual Ax\nHeinz Holliger"
            album.composer = "D1 Composer"
//            album.conductor = "Conductor1"
            album.orchestra = "Orchestra1"
            album.lyricist = "Lyricist1"
            album.genre = "Classical"
            album.recordingYear = 1992
            album.addArt(AlbumArtRef(type: .front, format: .jpg))
            album.addArt(AlbumArtRef(type: .back, format: .png))
            album.addArt(AlbumArtRef(type: .page, format: .png))
        } else {
            album.title += " [Disk 2]"
            album.subtitle = "BSubtitle"
            album.artist = "D2 Artist"
            album.supportingArtists = "Emma Johnson\nEmanual Ax\nVladimir Horowitz\nYo yo Ma"
            album.composer = "D2 Composer"
            album.conductor = "Conductor2"
//            album.orchestra = "Orchestra2"
            album.lyricist = "Lyricist2"
            album.genre = "Clasical"
            album.copyright = "Copyright"
            album.recordingYear = 2013
            album.addArt(AlbumArtRef(type: .front, format: .png))
            album.addArt(AlbumArtRef(type: .back, format: .jpg))
            album.addArt(AlbumArtRef(type: .page, format: .png))
        }
        
        
        var group: Int? = group1
        
        for var argIndex in 1...3 {
            
            if argIndex == 2 {
                group = group2
            }
            
            if let contentGroup = group {
                switch contentGroup {
                case 1:
                    var single = Single(title: "Single1", filename: "file1.mp3", track: 1)
                    if argIndex > 1 {
                        single.disk = argIndex
                    }
                    single.duration = 200
                    var movementa = Movement(title: "Movement1", filename: "file2.mp3", track: 2)
                    if argIndex > 1 {
                        movementa.disk = argIndex
                    }
                    movementa.duration = 380
                    var movementb = Movement(title: "Movement2", filename: "file3.mp3", track: 3)
                    if argIndex > 1 {
                        movementb.disk = argIndex
                    }
                    movementb.duration = 270
                    var movementc = Movement(title: "Movement3", filename: "file4.mp3", track: 4)
                    if argIndex > 1 {
                        movementc.disk = argIndex
                    }
                    movementc.duration = 210
                    var composition = Composition(title: "Composition1", track: 2)
                    composition.addMovement(movementa)
                    composition.addMovement(movementb)
                    composition.addMovement(movementc)
                    
                    album.addSingle(single)
                    album.addComposition(composition)
                case 2:
                    var single1 = Single(title: "Single2", filename: "file21.mp3", track: 1)
                    if argIndex > 1 {
                        single1.disk = argIndex
                    }
                    single1.duration = 320
                    var single2 = Single(title: "Single3", filename: "file22.mp3", track: 2)
                    if argIndex > 1 {
                        single2.disk = argIndex
                    }
                    single2.duration = 200
                    var movementa = Movement(title: "Movement31", filename: "file2.mp3", track: 3)
                    if argIndex > 1 {
                        movementa.disk = argIndex
                    }
                    movementa.duration = 380
                    var movementb = Movement(title: "Movement32", filename: "file3.mp3", track: 4)
                    if argIndex > 1 {
                        movementb.disk = argIndex
                    }
                    movementb.duration = 270
                    var movementc = Movement(title: "Movement33", filename: "file4.mp3", track: 5)
                    if argIndex > 1 {
                        movementc.disk = argIndex
                    }
                    movementc.duration = 210
                    var composition = Composition(title: "Composition2", track: 3)
                    composition.addMovement(movementa)
                    composition.addMovement(movementb)
                    composition.addMovement(movementc)

                    album.addSingle(single1)
                    album.addSingle(single2)
                    album.addComposition(composition)

                default:
                    break
                }
                argIndex += 1
            }
        }
        
        return album
    }
    
    func testAlbumMerge() throws {
        var album1 = createAlbum(1)
        let album2 = createAlbum(2)
        
        let duration1 = album1.duration
        let duration2 = album2.duration
        
        album1.merge(album2)
        
        XCTAssertEqual(album1.title, "My Album [Disk $1]$2]")
        XCTAssertEqual(album1.subtitle, "ASubtitle$BSubtitle")
        XCTAssertEqual(album1.artist, "D$1 Artist$2 Artist")
        XCTAssertEqual(album1.supportingArtists, "Yo yo Ma\nEmanual Ax\nHeinz Holliger\nEmma Johnson\nVladimir Horowitz")
        XCTAssertEqual(album1.composer, "D$1 Composer$2 Composer")
        XCTAssertEqual(album1.conductor, "Conductor2")
        XCTAssertEqual(album1.orchestra, "Orchestra1")
        XCTAssertEqual(album1.lyricist, "Lyricist$1$2")
        XCTAssertEqual(album1.genre, "Clas$sical$ical")
        XCTAssertNil(album1.publisher)
        XCTAssertEqual(album1.copyright, "Copyright")
        XCTAssertEqual(album1.recordingYear, 2013)
        XCTAssertEqual(album1.duration, duration1 + duration2)
        XCTAssertEqual(album1.frontArtRef(), AlbumArtRef(type: .front, format: .jpg))
        XCTAssertEqual(album1.backArtRef(), AlbumArtRef(type: .back, format: .png))
        XCTAssertEqual(album1.albumArt.pageCount, 4)
        for seq in 1...4 {
            XCTAssertEqual(album1.pageArtRef(seq)?.type, .page)
            XCTAssertEqual(album1.pageArtRef(seq)?.seq, seq)
            switch seq {
            case 1:
                XCTAssertEqual(album1.pageArtRef(seq)?.format, .png)
                XCTAssertEqual(album1.pageArtRef(seq)?.filename, "page1.png")
            case 2:
                XCTAssertEqual(album1.pageArtRef(seq)?.format, .png)
                XCTAssertEqual(album1.pageArtRef(seq)?.filename, "page2.png")
            case 3:
                XCTAssertEqual(album1.pageArtRef(seq)?.format, .png)
                XCTAssertEqual(album1.pageArtRef(seq)?.filename, "page3.png")
            case 4:
                XCTAssertEqual(album1.pageArtRef(seq)?.format, .jpg)
                XCTAssertEqual(album1.pageArtRef(seq)?.filename, "page4.jpg")
            default:
                break
            }
        }

        
        XCTAssertEqual(album1.contents.count, 5)
        
        var index = 0
        for content in album1.contents {
            switch index {
            case 0:
                XCTAssertEqual(content.disk, 1)
                XCTAssertEqual(content.track, 1)
                if let single = content.single {
                    XCTAssertEqual(single.title, "Single1")
                    XCTAssertEqual(single.filename, "file1.mp3")
                } else {
                    XCTFail("Single expected, index = \(index)")
                }
            case 1:
                XCTAssertEqual(content.disk, 1)
                XCTAssertEqual(content.track, 2)
                if let composition = content.composition {
                    XCTAssertEqual(composition.startDisk, 1)
                    XCTAssertEqual(composition.startTrack, 2)
                    XCTAssertEqual(composition.title, "Composition1")
                    XCTAssertEqual(composition.movements.count, 3)
                    var cIndex = 0
                    
                    for movement in composition.movements {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(movement.disk, 1)
                            XCTAssertEqual(movement.track, 2)
                        case 1:
                            XCTAssertEqual(movement.disk, 1)
                            XCTAssertEqual(movement.track, 3)
                        case 2:
                            XCTAssertEqual(movement.disk, 1)
                            XCTAssertEqual(movement.track, 4)
                        default:
                            XCTFail("Unexpected content, index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }
                } else {
                    XCTFail("Composition expected, index = \(index)")
                }
            case 2:
                XCTAssertEqual(content.disk, 2)
                XCTAssertEqual(content.track, 1)
                if let single = content.single {
                    XCTAssertEqual(single.title, "Single2")
                    XCTAssertEqual(single.filename, "file21.mp3")
                } else {
                    XCTFail("Single expected, index = \(index)")
                }
            case 3:
                XCTAssertEqual(content.disk, 2)
                XCTAssertEqual(content.track, 2)
                if let single = content.single {
                    XCTAssertEqual(single.title, "Single3")
                    XCTAssertEqual(single.filename, "file22.mp3")
                } else {
                    XCTFail("Single expected, index = \(index)")
                }
            case 4:
                XCTAssertEqual(content.disk, 2)
                XCTAssertEqual(content.track, 3)
                if let composition = content.composition {
                    XCTAssertEqual(composition.startDisk, 2)
                    XCTAssertEqual(composition.startTrack, 3)
                    XCTAssertEqual(composition.title, "Composition2")
                    XCTAssertEqual(composition.movements.count, 3)
                    var cIndex = 0
                    
                    for movement in composition.movements {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(movement.disk, 2)
                            XCTAssertEqual(movement.track, 3)
                        case 1:
                            XCTAssertEqual(movement.disk, 2)
                            XCTAssertEqual(movement.track, 4)
                        case 2:
                            XCTAssertEqual(movement.disk, 2)
                            XCTAssertEqual(movement.track, 5)
                        default:
                            XCTFail("Unexpected content, index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }

                } else {
                    XCTFail("Composition expected, index = \(index)")
                }
            default:
                XCTFail("Unexpected contents, index = \(index)")
            }
            index += 1
        }
    }
    
    func testAlbumMerge2() throws {
        var album1 = createAlbum(1)
        var album2 = createAlbum(2)
        album2.recordingYear = nil
        album2.supportingArtists = nil
        album2.removeAllArt()
        
        let duration1 = album1.duration
        let duration2 = album2.duration
        
        album1.merge(album2)
        
        XCTAssertEqual(album1.title, "My Album [Disk $1]$2]")
        XCTAssertEqual(album1.subtitle, "ASubtitle$BSubtitle")
        XCTAssertEqual(album1.artist, "D$1 Artist$2 Artist")
        XCTAssertEqual(album1.supportingArtists, "Yo yo Ma\nEmanual Ax\nHeinz Holliger")
        XCTAssertEqual(album1.composer, "D$1 Composer$2 Composer")
        XCTAssertEqual(album1.conductor, "Conductor2")
        XCTAssertEqual(album1.orchestra, "Orchestra1")
        XCTAssertEqual(album1.lyricist, "Lyricist$1$2")
        XCTAssertEqual(album1.genre, "Clas$sical$ical")
        XCTAssertNil(album1.publisher)
        XCTAssertEqual(album1.copyright, "Copyright")
        XCTAssertEqual(album1.recordingYear, 1992)
        XCTAssertEqual(album1.duration, duration1 + duration2)
        XCTAssertEqual(album1.frontArtRef(), AlbumArtRef(type: .front, format: .jpg))
        XCTAssertEqual(album1.backArtRef(), AlbumArtRef(type: .back, format: .png))
        XCTAssertEqual(album1.albumArt.pageCount, 1)
        XCTAssertEqual(album1.pageArtRef(1)?.type, .page)
        XCTAssertEqual(album1.pageArtRef(1)?.seq, 1)
        XCTAssertEqual(album1.pageArtRef(1)?.format, .png)
        XCTAssertEqual(album1.pageArtRef(1)?.name, "Page1")

    }

    func testAlbumMerge3() throws {
        var album1 = createAlbum(1)
        var album2 = createAlbum(2)
        album2.recordingYear = 1952
        album1.recordingYear = nil
        album1.supportingArtists = nil
        album1.removeAllArt()
        
        let duration1 = album1.duration
        let duration2 = album2.duration
        
        album1.merge(album2)
        
        XCTAssertEqual(album1.title, "My Album [Disk $1]$2]")
        XCTAssertEqual(album1.subtitle, "ASubtitle$BSubtitle")
        XCTAssertEqual(album1.artist, "D$1 Artist$2 Artist")
        XCTAssertEqual(album1.supportingArtists, "Emma Johnson\nEmanual Ax\nVladimir Horowitz\nYo yo Ma")
        XCTAssertEqual(album1.composer, "D$1 Composer$2 Composer")
        XCTAssertEqual(album1.conductor, "Conductor2")
        XCTAssertEqual(album1.orchestra, "Orchestra1")
        XCTAssertEqual(album1.lyricist, "Lyricist$1$2")
        XCTAssertEqual(album1.genre, "Clas$sical$ical")
        XCTAssertNil(album1.publisher)
        XCTAssertEqual(album1.copyright, "Copyright")
        XCTAssertEqual(album1.recordingYear, 1952)
        XCTAssertEqual(album1.duration, duration1 + duration2)
        XCTAssertEqual(album1.frontArtRef(), AlbumArtRef(type: .front, format: .png))
        XCTAssertEqual(album1.backArtRef(), AlbumArtRef(type: .back, format: .jpg))
        XCTAssertEqual(album1.albumArt.pageCount, 1)
        XCTAssertEqual(album1.pageArtRef(1)?.type, .page)
        XCTAssertEqual(album1.pageArtRef(1)?.seq, 1)
        XCTAssertEqual(album1.pageArtRef(1)?.format, .png)
        XCTAssertEqual(album1.pageArtRef(1)?.name, "Page1")

    }
    
    func testAlbumMerge4() throws {
        var album1 = createAlbum(1)
        var album2 = createAlbum(2)
        album2.recordingYear = nil
        album2.supportingArtists = nil
        album2.removeFrontArt()
        album1.removeBackArt()
        
        let duration1 = album1.duration
        let duration2 = album2.duration
        
        album1.merge(album2)
        
        XCTAssertEqual(album1.title, "My Album [Disk $1]$2]")
        XCTAssertEqual(album1.subtitle, "ASubtitle$BSubtitle")
        XCTAssertEqual(album1.artist, "D$1 Artist$2 Artist")
        XCTAssertEqual(album1.supportingArtists, "Yo yo Ma\nEmanual Ax\nHeinz Holliger")
        XCTAssertEqual(album1.composer, "D$1 Composer$2 Composer")
        XCTAssertEqual(album1.conductor, "Conductor2")
        XCTAssertEqual(album1.orchestra, "Orchestra1")
        XCTAssertEqual(album1.lyricist, "Lyricist$1$2")
        XCTAssertEqual(album1.genre, "Clas$sical$ical")
        XCTAssertNil(album1.publisher)
        XCTAssertEqual(album1.copyright, "Copyright")
        XCTAssertEqual(album1.recordingYear, 1992)
        XCTAssertEqual(album1.duration, duration1 + duration2)
        XCTAssertEqual(album1.frontArtRef(), AlbumArtRef(type: .front, format: .jpg))
        XCTAssertEqual(album1.backArtRef(), AlbumArtRef(type: .back, format: .jpg))
        XCTAssertEqual(album1.albumArt.pageCount, 2)
        XCTAssertEqual(album1.pageArtRef(1)?.type, .page)
        XCTAssertEqual(album1.pageArtRef(1)?.seq, 1)
        XCTAssertEqual(album1.pageArtRef(1)?.format, .png)
        XCTAssertEqual(album1.pageArtRef(1)?.name, "Page1")
        XCTAssertEqual(album1.pageArtRef(2)?.type, .page)
        XCTAssertEqual(album1.pageArtRef(2)?.seq, 2)
        XCTAssertEqual(album1.pageArtRef(2)?.format, .png)
        XCTAssertEqual(album1.pageArtRef(2)?.name, "Page2")

    }

    func testAlbumMerge5() throws {
        var album1 = createAlbum(1)
        var album2 = createAlbum(2)
        album2.recordingYear = nil
        album2.supportingArtists = nil
        album2.removeBackArt()
        album1.removeFrontArt()
        
        let duration1 = album1.duration
        let duration2 = album2.duration
        
        album1.merge(album2)
        
        XCTAssertEqual(album1.title, "My Album [Disk $1]$2]")
        XCTAssertEqual(album1.subtitle, "ASubtitle$BSubtitle")
        XCTAssertEqual(album1.artist, "D$1 Artist$2 Artist")
        XCTAssertEqual(album1.supportingArtists, "Yo yo Ma\nEmanual Ax\nHeinz Holliger")
        XCTAssertEqual(album1.composer, "D$1 Composer$2 Composer")
        XCTAssertEqual(album1.conductor, "Conductor2")
        XCTAssertEqual(album1.orchestra, "Orchestra1")
        XCTAssertEqual(album1.lyricist, "Lyricist$1$2")
        XCTAssertEqual(album1.genre, "Clas$sical$ical")
        XCTAssertNil(album1.publisher)
        XCTAssertEqual(album1.copyright, "Copyright")
        XCTAssertEqual(album1.recordingYear, 1992)
        XCTAssertEqual(album1.duration, duration1 + duration2)
        XCTAssertEqual(album1.frontArtRef(), AlbumArtRef(type: .front, format: .png))
        XCTAssertEqual(album1.backArtRef(), AlbumArtRef(type: .back, format: .png))
        XCTAssertEqual(album1.albumArt.pageCount, 2)
        XCTAssertEqual(album1.pageArtRef(1)?.type, .page)
        XCTAssertEqual(album1.pageArtRef(1)?.seq, 1)
        XCTAssertEqual(album1.pageArtRef(1)?.format, .png)
        XCTAssertEqual(album1.pageArtRef(1)?.name, "Page1")
        XCTAssertEqual(album1.pageArtRef(2)?.type, .page)
        XCTAssertEqual(album1.pageArtRef(2)?.seq, 2)
        XCTAssertEqual(album1.pageArtRef(2)?.format, .png)
        XCTAssertEqual(album1.pageArtRef(2)?.name, "Page2")


    }

    func testAlbumSplit() throws {
        
        var album1 = createAlbum(1)
        let album = album1
        let album2 = createAlbum(2)

        album1.merge(album2)
        
        let albums = album1.split()
        
        
        XCTAssertEqual(albums.count, 2)
        
        let album1a = albums[0]
        let album2a = albums[1]

        XCTAssertEqual(album1a.title, album.title)
        XCTAssertEqual(album1a.subtitle, album.subtitle)
        XCTAssertEqual(album1a.artist, album.artist)
        XCTAssertEqual(album1a.supportingArtists, album1.supportingArtists)
        XCTAssertEqual(album1a.composer, album.composer)
        XCTAssertEqual(album1a.conductor, album1.conductor)
        XCTAssertEqual(album1a.orchestra, album.orchestra)
        XCTAssertEqual(album1a.lyricist, album.lyricist)
        XCTAssertEqual(album1a.genre, album.genre)
        XCTAssertNil(album1a.publisher)
        XCTAssertEqual(album1a.copyright, album1.copyright)
        XCTAssertEqual(album1a.recordingYear, album1.recordingYear)
        XCTAssertEqual(album1a.duration, album.duration)
        XCTAssertEqual(album1a.frontArtRef(), album.frontArtRef())
        XCTAssertEqual(album1a.backArtRef(), album.backArtRef())
        XCTAssertEqual(album1a.albumArt.pageCount, album1.albumArt.pageCount)
        XCTAssertEqual(album1a.pageArtRef(1)?.type, album1.pageArtRef(1)?.type)
        XCTAssertEqual(album1a.pageArtRef(1)?.seq, album1.pageArtRef(1)?.seq)
        XCTAssertEqual(album1a.pageArtRef(1)?.format, album1.pageArtRef(1)?.format)
        XCTAssertEqual(album1a.pageArtRef(1)?.name, album1.pageArtRef(1)?.name)
        XCTAssertEqual(album1a.contents.count, album.contents.count)

        XCTAssertEqual(album2a.title, album2.title)
        XCTAssertEqual(album2a.subtitle, album2.subtitle)
        XCTAssertEqual(album2a.artist, album2.artist)
        XCTAssertEqual(album2a.supportingArtists, album1.supportingArtists)
        XCTAssertEqual(album2a.composer, album2.composer)
        XCTAssertEqual(album2a.conductor, album2.conductor)
        XCTAssertEqual(album2a.orchestra, album1.orchestra)
        XCTAssertEqual(album2a.lyricist, album2.lyricist)
        XCTAssertEqual(album2a.genre, album2.genre)
        XCTAssertNil(album2a.publisher)
        XCTAssertEqual(album2a.copyright, album2.copyright)
        XCTAssertEqual(album2a.recordingYear, album2.recordingYear)
        XCTAssertEqual(album2a.duration, album2.duration)
        XCTAssertEqual(album2a.frontArtRef(), album1.frontArtRef())
        XCTAssertEqual(album2a.backArtRef(), album1.backArtRef())
        XCTAssertEqual(album2a.albumArt.pageCount, album1.albumArt.pageCount)
        XCTAssertEqual(album2a.pageArtRef(1)?.type, album1.pageArtRef(1)?.type)
        XCTAssertEqual(album2a.pageArtRef(1)?.seq, album1.pageArtRef(1)?.seq)
        XCTAssertEqual(album2a.pageArtRef(1)?.format, album1.pageArtRef(1)?.format)
        XCTAssertEqual(album2a.pageArtRef(1)?.name, album1.pageArtRef(1)?.name)
        XCTAssertEqual(album2a.contents.count, album2.contents.count)
    }
    
    static var allTests = [
        ("testAlbumMerge", testAlbumMerge),
        ("testAlbumMerge2", testAlbumMerge2),
        ("testAlbumMerge3", testAlbumMerge3),
        ("testAlbumMerge4", testAlbumMerge4),
        ("testAlbumMerge5", testAlbumMerge5),
        ("testAlbumSplit", testAlbumSplit),
    ]
}
