//
//  MusicMetadataContentTests.swift
//  
//
//  Created by Robert Cheal on 12/9/20.
//

import XCTest
@testable import MusicMetadata


@available(OSX 11.0, *)
final class MusicMetadataContentTests: XCTestCase {

    func createMixedAlbum() -> Album {
        var album = Album(title: "Test Album")
        let single1 = Single(track: 1, title: "Song1", filename: "song1.mp3")
        let single2 = Single(track: 2, title: "Song2", filename: "song2.mp3")
        let single3 = Single(track: 6, title: "Song3", filename: "song3.mp3")
        let single4 = Single(track: 1, title: "Song4", filename: "song4.mp3", disk: 2)
        let single5 = Single(track: 5, title: "Song5", filename: "song5.mp3", disk: 2)
        let single6 = Single(track: 6, title: "Song6", filename: "song6.mp3", disk: 2)

        var composition1 = Composition(track: 3, title: "Composition1")
        var composition2 = Composition(track: 2, title: "Composition2", disk: 2)
        
        let single11 = Single(track: 3, title: "Movement1", filename: "file1.mp3")
        let single12 = Single(track: 4, title: "Movement2", filename: "file2.mp3")
        let single13 = Single(track: 5, title: "Movement3", filename: "file3.mp3")
        composition1.addSingle(single11)
        composition1.addSingle(single12)
        composition1.addSingle(single13)
                
        let single14 = Single(track: 2, title: "Movement1", filename: "file4.mp3", disk: 2)
        let single15 = Single(track: 3, title: "Movement2", filename: "file5.mp3", disk: 2)
        let single16 = Single(track: 4, title: "Movement3", filename: "file6.mp3", disk: 2)
        
        composition2.addSingle(single14)
        composition2.addSingle(single15)
        composition2.addSingle(single16)
        
        album.addSingle(single1)
        album.addSingle(single2)
        album.addComposition(composition1)
        album.addSingle(single3)
        album.addSingle(single4)
        album.addComposition(composition2)
        album.addSingle(single5)
        album.addSingle(single6)

        return album
    }
    
    func createSinglesAlbum() -> Album {
        var album = Album(title: "Singles Album")
        
        var single1 = Single(track: 1, title: "Song1", filename: "song1.mp3")
        var single2 = Single(track: 2, title: "Song2", filename: "song2.mp3")
        var single3 = Single(track: 3, title: "Song3", filename: "song3.mp3")
        var single4 = Single(track: 1, title: "Song4", filename: "song4.mp3", disk: 2)
        var single5 = Single(track: 2, title: "Song5", filename: "song5.mp3", disk: 2)
        var single6 = Single(track: 3, title: "Song6", filename: "song6.mp3", disk: 2)
        
        single1.duration = 240
        single2.duration = 240
        single3.duration = 240
        single4.duration = 240
        single5.duration = 240
        single6.duration = 240

        album.addSingle(single1)
        album.addSingle(single2)
        album.addSingle(single3)
        album.addSingle(single4)
        album.addSingle(single5)
        album.addSingle(single6)
        
        return album
    }
    
    func createCompositionsAlbum() -> Album {
        var album = Album(title: "Compositions Album")
        var composition1 = Composition(track: 1, title: "Composition1")
        var composition2 = Composition(track: 1, title: "Composition2", disk: 2)
        
        var single1 = Single(track: 1, title: "Movement1", filename: "file1.mp3")
        var single2 = Single(track: 2, title: "Movement2", filename: "file2.mp3")
        var single3 = Single(track: 3, title: "Movement3", filename: "file3.mp3")
        single1.duration = 240
        single2.duration = 240
        single3.duration = 240
        composition1.addSingle(single1)
        composition1.addSingle(single2)
        composition1.addSingle(single3)
        
        album.addComposition(composition1)
        
        var single4 = Single(track: 1, title: "Movement1", filename: "file4.mp3", disk: 2)
        var single5 = Single(track: 2, title: "Movement2", filename: "file5.mp3", disk: 2)
        var single6 = Single(track: 3, title: "Movement3", filename: "file6.mp3", disk: 2)
        single4.duration = 240
        single5.duration = 240
        single6.duration = 240

        composition2.addSingle(single4)
        composition2.addSingle(single5)
        composition2.addSingle(single6)
        
        album.addComposition(composition2)

        return album
    }
    
    func createComposition() -> Composition {
        var composition = Composition(track: 1, title: "Composition")
        
        let single1 = Single(track: 1, title: "Movement1", filename: "file1.mp3")
        let single2 = Single(track: 2, title: "Movement2", filename: "file2.mp3")
        let single3 = Single(track: 3, title: "Movement3", filename: "file3.mp3")
        composition.addSingle(single1)
        composition.addSingle(single2)
        composition.addSingle(single3)

        return composition
    }

    // MARK:  Album add content tests
    func testAlbumAddSingles() throws {
        let album = createSinglesAlbum()

        XCTAssertEqual(album.duration, 1440)
        var index = 0
        for content in album.contents {
            if let single = content.single {
                switch index {
                case 0:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 1)
                    XCTAssertEqual(single.title, "Song1")
                    XCTAssertEqual(single.audiofileRef, "song1.mp3")
                    XCTAssertEqual(single.duration, 240)
                case 1:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 2)
                    XCTAssertEqual(single.title, "Song2")
                    XCTAssertEqual(single.audiofileRef, "song2.mp3")
                    XCTAssertEqual(single.duration, 240)
                case 2:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 3)
                    XCTAssertEqual(single.title, "Song3")
                    XCTAssertEqual(single.audiofileRef, "song3.mp3")
                    XCTAssertEqual(single.duration, 240)
                case 3:
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 1)
                    XCTAssertEqual(single.title, "Song4")
                    XCTAssertEqual(single.audiofileRef, "song4.mp3")
                    XCTAssertEqual(single.duration, 240)
                case 4:
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 2)
                    XCTAssertEqual(single.title, "Song5")
                    XCTAssertEqual(single.audiofileRef, "song5.mp3")
                    XCTAssertEqual(single.duration, 240)
                case 5:
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 3)
                    XCTAssertEqual(single.title, "Song6")
                    XCTAssertEqual(single.audiofileRef, "song6.mp3")
                    XCTAssertEqual(single.duration, 240)
                default:
                    XCTFail("Extra contents, index = \(index)")
                }
            } else {
                XCTFail("Unexpected content type; expected Single, index = \(index)")
            }
            index += 1
        }
    }
    
    func testAlbumAddCompositions() {
        let album = createCompositionsAlbum()
        
        XCTAssertEqual(album.duration, 1440)
        var index = 0
        for content in album.contents {
            if let composition = content.composition {
                switch index {
                case 0:
                    XCTAssertNil(composition.startDisk)
                    XCTAssertEqual(composition.startTrack, 1)
                    XCTAssertEqual(composition.title, "Composition1")
                    XCTAssertEqual(composition.duration, 720)
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertNil(single.disk)
                            XCTAssertEqual(single.track, 1)
                            XCTAssertEqual(single.title, "Movement1")
                            XCTAssertEqual(single.audiofileRef, "file1.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 1:
                            XCTAssertNil(single.disk)
                            XCTAssertEqual(single.track, 2)
                            XCTAssertEqual(single.title, "Movement2")
                            XCTAssertEqual(single.audiofileRef, "file2.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 2:
                            XCTAssertNil(single.disk)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement3")
                            XCTAssertEqual(single.audiofileRef, "file3.mp3")
                            XCTAssertEqual(single.duration, 240)
                        default:
                            XCTFail("Extra contents in composition \(composition.title), index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }
                case 1:
                    XCTAssertEqual(composition.startDisk, 2)
                    XCTAssertEqual(composition.startTrack, 1)
                    XCTAssertEqual(composition.title, "Composition2")
                    XCTAssertEqual(composition.duration, 720)
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 1)
                            XCTAssertEqual(single.title, "Movement1")
                            XCTAssertEqual(single.audiofileRef, "file4.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 1:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 2)
                            XCTAssertEqual(single.title, "Movement2")
                            XCTAssertEqual(single.audiofileRef, "file5.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 2:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement3")
                            XCTAssertEqual(single.audiofileRef, "file6.mp3")
                            XCTAssertEqual(single.duration, 240)
                        default:
                            XCTFail("Extra contents in composition \(composition.title), index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }
                default:
                    XCTFail("Extra contents, index = \(index)")
                }
            } else {
                XCTFail("Unexpected content type; expected Single, index = \(index)")
            }
            index += 1
        }

    }

    // MARK: Album remove content tests
    func testAlbumRemoveAllContents() throws {
        var album = createMixedAlbum()
        
        album.removeAllContents()
        
        XCTAssertEqual(album.contents.count, 0)
    }
    
    func testAlbumRemoveAllSingles() throws {
        var album = createSinglesAlbum()
        
        album.removeAllSingles()
        
        XCTAssertEqual(album.contents.count, 0)
    }
    
    func testAlbumRemoveAllSingles2() throws {
        var album = createMixedAlbum()
        
        album.removeAllSingles()
        
        // Only compositions should remain
        XCTAssertEqual(album.contents.count, 2)
        
        for content in album.contents {
            XCTAssertNotNil(content.composition)
        }
    }
    
    func testAlbumRemoveSingles() throws {
        var album = createSinglesAlbum()
        
        album.removeAllSingles() { (single) -> Bool in
            single.disk != nil
        }
        
        var index = 0
        for content in album.contents {
            if let single = content.single {
                switch index {
                case 0:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 1)
                    XCTAssertEqual(single.title, "Song1")
                    XCTAssertEqual(single.audiofileRef, "song1.mp3")
                case 1:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 2)
                    XCTAssertEqual(single.title, "Song2")
                    XCTAssertEqual(single.audiofileRef, "song2.mp3")
                case 2:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 3)
                    XCTAssertEqual(single.title, "Song3")
                    XCTAssertEqual(single.audiofileRef, "song3.mp3")
                default:
                    XCTFail("Extra contents, index = \(index)")
                }
            } else {
                XCTFail("Unexpected content type; expected Single, index = \(index)")
            }
            index += 1
        }
    }
    
    func testAlbumRemoveSingles2() throws {
        var album = createMixedAlbum()
        
        album.removeAllSingles() { (single) -> Bool in
            single.disk != nil
        }
        
        var singlesCount = 0
        var compositionCount = 0
        
        for content in album.contents {
            if let _ = content.single {
                singlesCount += 1
            } else if let _ = content.composition {
                compositionCount += 1
            }
        }
        XCTAssertEqual(singlesCount, 3)
        XCTAssertEqual(compositionCount, 2)
    }
    
    func testAlbumRemoveAllCompositions() {
        var album = createCompositionsAlbum()
        
        album.removeAllCompositions()
        
        XCTAssertEqual(album.contents.count, 0)
        
    }
    
    func testAlbumRemoveAllCompositions2() {
        var album = createMixedAlbum()
        
        album.removeAllCompositions()
        
        // Only singles should remain
        XCTAssertEqual(album.contents.count, 6)
        for content in album.contents {
            XCTAssertNotNil(content.single)
        }
    }
    
    func testAlbumRemoveCompositions() {
        var album = createMixedAlbum()
        
        album.removeAllCompositions() { (composition) -> Bool in
            composition.title == "Composition1"
        }
    }

    func testAlbumRemoveCompositions2() {
        var album = createMixedAlbum()
        
        album.removeAllCompositions() { (composition) -> Bool in
            composition.title == "Composition2"
        }
        
        var singlesCount = 0
        var compositionCount = 0
        
        for content in album.contents {
            if let _ = content.single {
                singlesCount += 1
            } else if let _ = content.composition {
                compositionCount += 1
            }
        }
        XCTAssertEqual(singlesCount, 6)
        XCTAssertEqual(compositionCount, 1)
    }
    
    // MARK: Album replace content tests
    func testAlbumReplaceSingle() throws {
        var album = createSinglesAlbum()
        
        var single = Single(track: 4, title: "Song7", filename: "song7.mp3", disk: 2)
        single.duration = 300
        let replacedSingle = album.contents[1].single!
        single.id = replacedSingle.id

        album.replaceSingle(single)

        XCTAssertEqual(album.duration, 1500)
        var index = 0
        for content in album.contents {
            if let single = content.single {
                switch index {
                case 0:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 1)
                    XCTAssertEqual(single.title, "Song1")
                    XCTAssertEqual(single.audiofileRef, "song1.mp3")
                case 1:
                    XCTAssertNil(single.disk)
                    XCTAssertEqual(single.track, 3)
                    XCTAssertEqual(single.title, "Song3")
                    XCTAssertEqual(single.audiofileRef, "song3.mp3")
                case 2:
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 1)
                    XCTAssertEqual(single.title, "Song4")
                    XCTAssertEqual(single.audiofileRef, "song4.mp3")
                case 3:
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 2)
                    XCTAssertEqual(single.title, "Song5")
                    XCTAssertEqual(single.audiofileRef, "song5.mp3")
                case 4:
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 3)
                    XCTAssertEqual(single.title, "Song6")
                    XCTAssertEqual(single.audiofileRef, "song6.mp3")
                case 5:
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 4)
                    XCTAssertEqual(single.title, "Song7")
                    XCTAssertEqual(single.audiofileRef, "song7.mp3")
                    XCTAssertEqual(single.duration, 300)
                default:
                    XCTFail("Extra contents, index = \(index)")
                }
            } else {
                XCTFail("Unexpected content type; expected Single, index = \(index)")
            }
            index += 1
        }
    }
    
    func testAlbumReplaceSingle2() throws {
        var album = createCompositionsAlbum()
        
        let composition = album.contents[0].composition!
        let replacedSingle = composition.contents[1]
        
        var single = Single(track: 4, title: "Movement7", filename: "file7.mp3", disk: 1)
        single.duration = 300
        single.id = replacedSingle.id

        album.replaceSingle(single: single, compositionId: composition.id)
        album.updateDuration()
        
        XCTAssertEqual(album.duration, 1500)

        var index = 0
        for content in album.contents {
            if let composition = content.composition {
                switch index {
                case 0:
                    XCTAssertNil(composition.startDisk)
                    XCTAssertEqual(composition.startTrack, 1)
                    XCTAssertEqual(composition.title, "Composition1")
                    XCTAssertEqual(composition.duration, 780)
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertNil(single.disk)
                            XCTAssertEqual(single.track, 1)
                            XCTAssertEqual(single.title, "Movement1")
                            XCTAssertEqual(single.audiofileRef, "file1.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 2:
                            XCTAssertEqual(single.disk, 1)
                            XCTAssertEqual(single.track, 4)
                            XCTAssertEqual(single.title, "Movement7")
                            XCTAssertEqual(single.audiofileRef, "file7.mp3")
                            XCTAssertEqual(single.duration, 300)
                        case 1:
                            XCTAssertNil(single.disk)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement3")
                            XCTAssertEqual(single.audiofileRef, "file3.mp3")
                            XCTAssertEqual(single.duration, 240)
                        default:
                            XCTFail("Extra contents in composition \(composition.title), index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }
                case 1:
                    XCTAssertEqual(composition.startDisk, 2)
                    XCTAssertEqual(composition.startTrack, 1)
                    XCTAssertEqual(composition.title, "Composition2")
                    XCTAssertEqual(composition.duration, 720)
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 1)
                            XCTAssertEqual(single.title, "Movement1")
                            XCTAssertEqual(single.audiofileRef, "file4.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 1:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 2)
                            XCTAssertEqual(single.title, "Movement2")
                            XCTAssertEqual(single.audiofileRef, "file5.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 2:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement3")
                            XCTAssertEqual(single.audiofileRef, "file6.mp3")
                            XCTAssertEqual(single.duration, 240)
                        default:
                            XCTFail("Extra contents in composition \(composition.title), index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }
                default:
                    XCTFail("Extra contents, index = \(index)")
                }
            } else {
                XCTFail("Unexpected content type; expected Single, index = \(index)")
            }
            index += 1
        }
    }
    
    func testAlbumReplaceComposition() throws {
        var album = createCompositionsAlbum()
                
        var composition = Composition(track: 1, title: "New Composition", disk: 3)
        
        var movement1 = Single(track: 1, title: "Movement1", filename: "file10.mp3", disk: 3)
        movement1.duration = 210
        var movement2 = Single(track: 2, title: "Movement2", filename: "file11.mp3", disk: 3)
        movement2.duration = 220
        var movement3 = Single(track: 3, title: "Movement3", filename: "file12.mp3", disk: 3)
        movement3.duration = 230
        var movement4 = Single(track: 4, title: "Movement4", filename: "file13.mp3", disk: 3)
        movement4.duration = 300
        composition.addSingle(movement1)
        composition.addSingle(movement2)
        composition.addSingle(movement3)
        composition.addSingle(movement4)
        let replacedComposition = album.contents[0].composition!
        composition.id = replacedComposition.id
        
        album.replaceComposition(composition)
        
        XCTAssertEqual(album.duration, 1680)
        var index = 0
        for content in album.contents {
            if let composition = content.composition {
                switch index {
                case 1:
                    XCTAssertEqual(composition.startDisk, 3)
                    XCTAssertEqual(composition.startTrack, 1)
                    XCTAssertEqual(composition.title, "New Composition")
                    XCTAssertEqual(composition.duration, 960)
                    XCTAssertEqual(composition.contents.count, 4)
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(single.disk, 3)
                            XCTAssertEqual(single.track, 1)
                            XCTAssertEqual(single.title, "Movement1")
                            XCTAssertEqual(single.audiofileRef, "file10.mp3")
                            XCTAssertEqual(single.duration, 210)
                        case 1:
                            XCTAssertEqual(single.disk, 3)
                            XCTAssertEqual(single.track, 2)
                            XCTAssertEqual(single.title, "Movement2")
                            XCTAssertEqual(single.audiofileRef, "file11.mp3")
                            XCTAssertEqual(single.duration, 220)
                        case 2:
                            XCTAssertEqual(single.disk, 3)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement3")
                            XCTAssertEqual(single.audiofileRef, "file12.mp3")
                            XCTAssertEqual(single.duration, 230)
                        case 3:
                            XCTAssertEqual(single.disk, 3)
                            XCTAssertEqual(single.track, 4)
                            XCTAssertEqual(single.title, "Movement4")
                            XCTAssertEqual(single.audiofileRef, "file13.mp3")
                            XCTAssertEqual(single.duration, 300)
                        default:
                            XCTFail("Extra contents in composition \(composition.title), index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }
                case 0:
                    XCTAssertEqual(composition.startDisk, 2)
                    XCTAssertEqual(composition.startTrack, 1)
                    XCTAssertEqual(composition.title, "Composition2")
                    XCTAssertEqual(composition.duration, 720)
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 1)
                            XCTAssertEqual(single.title, "Movement1")
                            XCTAssertEqual(single.audiofileRef, "file4.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 1:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 2)
                            XCTAssertEqual(single.title, "Movement2")
                            XCTAssertEqual(single.audiofileRef, "file5.mp3")
                            XCTAssertEqual(single.duration, 240)
                        case 2:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement3")
                            XCTAssertEqual(single.audiofileRef, "file6.mp3")
                            XCTAssertEqual(single.duration, 240)
                        default:
                            XCTFail("Extra contents in composition \(composition.title), index = \(index)/\(cIndex)")
                        }
                        
                        cIndex += 1
                    }
                default:
                    XCTFail("Extra contents, index = \(index)")
                }
            } else {
                XCTFail("Unexpected content type; expected Single, index = \(index)")
            }
            index += 1
        }


    }
    
    // MARK: Composition add content test
    func testCompositionAdd() throws {
        let composition = createComposition()
        
        XCTAssertNil(composition.startDisk)
        XCTAssertEqual(composition.startTrack, 1)
        XCTAssertEqual(composition.title, "Composition")
        var index = 0
        for single in composition.contents {
            switch index {
            case 0:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 1)
                XCTAssertEqual(single.title, "Movement1")
                XCTAssertEqual(single.audiofileRef, "file1.mp3")
            case 1:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 2)
                XCTAssertEqual(single.title, "Movement2")
                XCTAssertEqual(single.audiofileRef, "file2.mp3")
            case 2:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 3)
                XCTAssertEqual(single.title, "Movement3")
                XCTAssertEqual(single.audiofileRef, "file3.mp3")
            default:
                XCTFail("Extra contents in composition \(composition.title), index = \(index)")
            }
            
            index += 1
        }
    }
    
    // MARK: Composition remove content tests
    func testCompositionRemoveAll() throws {
        var composition = createComposition()
        
        composition.removeAllContents()
        
        XCTAssertEqual(composition.contents.count, 0)
    }
    
    func testCompositionRemove() throws {
        var composition = createComposition()
        
        composition.removeContents() { (single) -> Bool in
            single.title == "Movement2"
        }
        
        XCTAssertEqual(composition.contents.count, 2)
        
        var index = 0
        for single in composition.contents {
            switch index {
            case 0:
                XCTAssertEqual(single.track, 1)
            case 1:
                XCTAssertEqual(single.track, 3)
            default:
                XCTFail("Unexpected contents, index = \(index), name = \(single.title)")
            }
            index += 1
        }
    }
    
    func testCompositionRemove2() throws {
        var composition = createComposition()
        
        composition.removeContents() { (single) -> Bool in
            single.title == "Movement1"
        }
        
        XCTAssertEqual(composition.contents.count, 2)
        
        var index = 0
        for single in composition.contents {
            switch index {
            case 0:
                XCTAssertEqual(single.track, 2)
            case 1:
                XCTAssertEqual(single.track, 3)
            default:
                XCTFail("Unexpected contents, index = \(index), name = \(single.title)")
            }
            index += 1
        }
    }
    
    func testCompositionRemove3() throws {
        var composition = createComposition()
        
        composition.removeContents() { (single) -> Bool in
            single.title != "Movement1"
        }
        
        XCTAssertEqual(composition.contents.count, 1)
        
        var index = 0
        for single in composition.contents {
            switch index {
            case 0:
                XCTAssertEqual(single.track, 1)
            default:
                XCTFail("Unexpected contents, index = \(index), name = \(single.title)")
            }
            index += 1
        }
    }
    
    // MARK: Composition replace content tests
    func testCommpositionReplace() throws {
        var composition = createComposition()
        
        var single = Single(track: 5, title: "Movement5", filename: "file5.mp3")
        let replacedSingle = composition.contents[1]
        single.id = replacedSingle.id
        
        composition.replaceSingle(single)
        
        var index = 0
        for single in composition.contents {
            switch index {
            case 0:
                XCTAssertEqual(single.track, 1)
            case 1:
                XCTAssertEqual(single.track, 3)
            case 2:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 5)
                XCTAssertEqual(single.title, "Movement5")
                XCTAssertEqual(single.audiofileRef, "file5.mp3")
            default:
                XCTFail("Unexpected contents, index = \(index), name = \(single.title)")
            }
            index += 1
        }


    }
    
    
    static var allTests = [
        ("testAlbumAddSingles", testAlbumAddSingles),
        ("testAlbumAddCompositions", testAlbumAddCompositions),
        ("testAlbumRemoveAllContents", testAlbumRemoveAllContents),
        ("testAlbumRemoveAllSingles", testAlbumRemoveAllSingles),
        ("testAlbumRemoveAllSingles2", testAlbumRemoveAllSingles2),
        ("testAlbumRemoveSingles", testAlbumRemoveSingles),
        ("testAlbumRemoveSingles2", testAlbumRemoveSingles2),
        ("testAlbumRemoveAllCompositions", testAlbumRemoveAllCompositions),
        ("testAlbumRemoveAllCompositions2", testAlbumRemoveAllCompositions2),
        ("testAlbumRemoveCompositions", testAlbumRemoveCompositions),
        ("testAlbumRemoveCompositions2", testAlbumRemoveCompositions2),
        ("testAlbumReplaceSingle", testAlbumReplaceSingle),
        ("testAlbumReplaceSingle2", testAlbumReplaceSingle2),
        ("testAlbumReplaceComposition", testAlbumReplaceComposition),
        ("testCompositionAdd", testCompositionAdd),
        ("testCompositionRemoveAll", testCompositionRemoveAll),
        ("testCompositionRemove", testCompositionRemove),
        ("testCompositionRemove2", testCompositionRemove2),
        ("testCompositionRemove3", testCompositionRemove3),
        ("testCompositionReplace", testCommpositionReplace),
    ]

}
