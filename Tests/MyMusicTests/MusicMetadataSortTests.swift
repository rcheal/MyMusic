//
//  MusicMetadataSortTests.swift
//  
//
//  Created by Robert Cheal on 11/1/20.
//

import XCTest
@testable import MyMusic


@available(OSX 11.0, *)
final class MusicMetadataSortTests: XCTestCase {
    
    func assertSortTitle(_ title: String, _ refSortTitle: String) {
        let sortTitle = Album.sortedTitle(title)
        XCTAssertEqual(sortTitle, refSortTitle)
    }
    
    func assertSortNilPerson(_ person: String?) {
        let sortPerson = Album.sortedPerson(person)
        XCTAssertNil(sortPerson)
    }
    
    func assertSortPerson(_ person: String, _ refSortPerson: String) {
        let sortPerson = Album.sortedPerson(person)
        XCTAssertEqual(sortPerson, refSortPerson)
    }

    func testSortTitle() throws {
        assertSortTitle("Deja Vu","Deja Vu")
        
        assertSortTitle("The Sorcerer's Apprentice", "Sorcerer's Apprentice")
        
        assertSortTitle("A Night in Tunisia", "Night in Tunisia")
        
        assertSortTitle("The Girl from Ipanema", "Girl from Ipanema")
        
        assertSortTitle("An Apple a Day", "Apple a Day")
        
    }
    
    func testSortPerson() throws {
        assertSortPerson("The Beatles", "Beatles")
        
        assertSortPerson("Ludwig Van Beethoven (1848-1921)", "Beethoven, Ludwig Van")
        
        assertSortPerson("The Rolling Stones,", "Rolling Stones,")
        
        assertSortPerson("John \"Dizzy\" Gillespie", "Gillespie, John \"Dizzy\"")
        
        assertSortPerson("Bach, Johann Sebastion", "Bach, Johann Sebastion")
        
        assertSortNilPerson(nil)
        
    }
    
    func testSortCompositionContents() throws {
        var composition = Composition(title: "Test Composition", track: 1)
        composition.addMovement(Movement(title: "Track 5", filename: "five.mp3", track: 5))
        composition.addMovement(Movement(title: "Track 3", filename: "three.mp3", track: 3))
        composition.addMovement(Movement(title: "Track 4", filename: "four.mp3", track: 4))
        composition.addMovement(Movement(title: "Track 2", filename: "two.mp3", track: 2))
        
        composition.sortContents()
        
        var index = 0
        for movement in composition.movements {
            switch index {
            case 0:
                XCTAssertNil(movement.disk)
                XCTAssertEqual(movement.track, 2)
                XCTAssertEqual(movement.title, "Track 2")
                XCTAssertEqual(movement.filename, "two.mp3")
            case 1:
                XCTAssertNil(movement.disk)
                XCTAssertEqual(movement.track, 3)
                XCTAssertEqual(movement.title, "Track 3")
                XCTAssertEqual(movement.filename, "three.mp3")
            case 2:
                XCTAssertNil(movement.disk)
                XCTAssertEqual(movement.track, 4)
                XCTAssertEqual(movement.title, "Track 4")
                XCTAssertEqual(movement.filename, "four.mp3")
            case 3:
                XCTAssertNil(movement.disk)
                XCTAssertEqual(movement.track, 5)
                XCTAssertEqual(movement.title, "Track 5")
                XCTAssertEqual(movement.filename, "five.mp3")
            default:
                XCTFail("Unexpected contents: \(index)")
            }
            index += 1
        }

    }
    
    func testSortCompositionContents2() throws {
        var composition = Composition(title: "Test Composition", track: 1, disk: 1)
        composition.addMovement(Movement(title: "Track 5", filename: "five.mp3", track: 5, disk: 1))
        composition.addMovement(Movement(title: "Track 3", filename: "three.mp3", track: 3, disk: 1))
        composition.addMovement(Movement(title: "Track 4", filename: "four.mp3", track: 4, disk: 2))
        composition.addMovement(Movement(title: "Track 2", filename: "two.mp3", track: 2, disk: 2))
        
        composition.sortContents()
        
        var index = 0
        for movement in composition.movements {
            switch index {
            case 0:
                XCTAssertEqual(movement.disk, 1)
                XCTAssertEqual(movement.track, 3)
                XCTAssertEqual(movement.title, "Track 3")
                XCTAssertEqual(movement.filename, "three.mp3")
            case 1:
                XCTAssertEqual(movement.disk, 1)
                XCTAssertEqual(movement.track, 5)
                XCTAssertEqual(movement.title, "Track 5")
                XCTAssertEqual(movement.filename, "five.mp3")
            case 2:
                XCTAssertEqual(movement.disk, 2)
                XCTAssertEqual(movement.track, 2)
                XCTAssertEqual(movement.title, "Track 2")
                XCTAssertEqual(movement.filename, "two.mp3")
            case 3:
                XCTAssertEqual(movement.disk, 2)
                XCTAssertEqual(movement.track, 4)
                XCTAssertEqual(movement.title, "Track 4")
                XCTAssertEqual(movement.filename, "four.mp3")
            default:
                XCTFail("Unexpected contents: \(index)")
            }
            index += 1
        }

    }
    
    func testSortAlbumContents() throws {
        var album = Album(title: "Test Album")
        
        var composition2 = Composition(title: "Composition 2", track: 2, disk: 2)
        composition2.addMovement(Movement(title: "Movement 3", filename: "fourb.mp3", track: 4, disk: 2))
        composition2.addMovement(Movement(title: "Movement 1", filename: "twob.mp3", track: 2, disk: 2))
        composition2.addMovement(Movement(title: "Movement 2", filename: "threeb.mp3", track: 3, disk: 2))
        album.addComposition(composition2)
        var composition = Composition(title: "Composition 1", track: 2)
        composition.addMovement(Movement(title: "Movement 3", filename: "four.mp3", track: 4, disk: 1))
        composition.addMovement(Movement(title: "Movement 1", filename: "two.mp3", track: 2, disk: 1))
        composition.addMovement(Movement(title: "Movement 2", filename: "three.mp3", track: 3, disk: 1))
        album.addContent(AlbumContent(composition: composition))
        album.addSingle(Single(title: "Single 2", filename: "oneb.mp3", track: 1, disk: 2))
        album.addSingle(Single(title: "Single 1", filename: "one.mp3", track: 1, disk: 1))

        album.sortContents()

        var index = 0
        for content in album.contents {
            switch index {
            case 0:
                XCTAssertEqual(content.disk, 1)
                XCTAssertEqual(content.track, 1)
                if let single = content.single {
                    XCTAssertEqual(single.disk, 1)
                    XCTAssertEqual(single.track, 1)
                    XCTAssertEqual(single.albumId, album.id)
                    XCTAssertEqual(single.title, "Single 1")
                    XCTAssertEqual(single.filename, "one.mp3")
                } else {
                    XCTFail("Expecting single content - \(index)")
                }
            case 1:
                XCTAssertEqual(content.disk, 1)
                XCTAssertEqual(content.track, 2)
                if let composition = content.composition {
                    XCTAssertEqual(composition.title, "Composition 1")
                    XCTAssertEqual(composition.startDisk, 1)
                    XCTAssertEqual(composition.startTrack, 2)
                    XCTAssertEqual(composition.albumId, album.id)
                    var cIndex = 0
                    for movement in composition.movements {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(movement.disk, 1)
                            XCTAssertEqual(movement.track, 2)
                            XCTAssertEqual(movement.albumId, album.id)
                            XCTAssertEqual(movement.compositionId, composition.id)
                            XCTAssertEqual(movement.title, "Movement 1")
                            XCTAssertEqual(movement.filename, "two.mp3")
                        case 1:
                            XCTAssertEqual(movement.disk, 1)
                            XCTAssertEqual(movement.track, 3)
                            XCTAssertEqual(movement.albumId, album.id)
                            XCTAssertEqual(movement.compositionId, composition.id)
                            XCTAssertEqual(movement.title, "Movement 2")
                            XCTAssertEqual(movement.filename, "three.mp3")
                        case 2:
                            XCTAssertEqual(movement.disk, 1)
                            XCTAssertEqual(movement.track, 4)
                            XCTAssertEqual(movement.albumId, album.id)
                            XCTAssertEqual(movement.compositionId, composition.id)
                            XCTAssertEqual(movement.title, "Movement 3")
                            XCTAssertEqual(movement.filename, "four.mp3")
                        default:
                            XCTFail("Extra content in composition - \(composition.title), \(index)/\(cIndex)")
                        }
                        cIndex += 1
                    }
                } else {
                    XCTFail("Expecting composition content - \(index)")
                }
            case 2:
                XCTAssertEqual(content.disk, 2)
                XCTAssertEqual(content.track, 1)
                if let single = content.single {
                    XCTAssertEqual(single.disk, 2)
                    XCTAssertEqual(single.track, 1)
                    XCTAssertEqual(single.albumId, album.id)
                    XCTAssertEqual(single.title, "Single 2")
                    XCTAssertEqual(single.filename, "oneb.mp3")
                } else {
                    XCTFail("Expecting single content - \(index)")
                }
            case 3:
                XCTAssertEqual(content.disk, 2)
                XCTAssertEqual(content.track, 2)
                if let composition = content.composition {
                    XCTAssertEqual(composition.title, "Composition 2")
                    XCTAssertEqual(composition.startDisk, 2)
                    XCTAssertEqual(composition.startTrack, 2)
                    XCTAssertEqual(composition.albumId, album.id)
                    var cIndex = 0
                    for movement in composition.movements {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(movement.disk, 2)
                            XCTAssertEqual(movement.track, 2)
                            XCTAssertEqual(movement.albumId, album.id)
                            XCTAssertEqual(movement.compositionId, composition.id)
                            XCTAssertEqual(movement.title, "Movement 1")
                            XCTAssertEqual(movement.filename, "twob.mp3")
                        case 1:
                            XCTAssertEqual(movement.disk, 2)
                            XCTAssertEqual(movement.track, 3)
                            XCTAssertEqual(movement.albumId, album.id)
                            XCTAssertEqual(movement.compositionId, composition.id)
                            XCTAssertEqual(movement.title, "Movement 2")
                            XCTAssertEqual(movement.filename, "threeb.mp3")
                        case 2:
                            XCTAssertEqual(movement.disk, 2)
                            XCTAssertEqual(movement.track, 4)
                            XCTAssertEqual(movement.albumId, album.id)
                            XCTAssertEqual(movement.compositionId, composition.id)
                            XCTAssertEqual(movement.title, "Movement 3")
                            XCTAssertEqual(movement.filename, "fourb.mp3")
                        default:
                            XCTFail("Extra content in composition - \(composition.title), \(index)/\(cIndex)")
                        }
                        cIndex += 1
                    }
                } else {
                    XCTFail("Expecting composition content - \(index)")
                }
            default:
                XCTFail("Extra content in album - \(index)")
            }
            index += 1
        }
    }
    
    static var allTests = [
        ("testSortTitle", testSortTitle),
        ("testSortPerson", testSortPerson),
        ("testSortCompositionContents", testSortCompositionContents),
        ("testSortCompositionContents2", testSortCompositionContents2),
        ("testSortAlbumContents", testSortAlbumContents),
    ]
}
