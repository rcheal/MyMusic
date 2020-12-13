//
//  MusicMetadataSortTests.swift
//  
//
//  Created by Robert Cheal on 11/1/20.
//

import XCTest
@testable import MusicMetadata


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
        var composition = Composition(track: 1, title: "Test Composition")
        composition.addSingle(Single(track: 5, title: "Track 5", filename: "five.mp3"))
        composition.addSingle(Single(track: 3, title: "Track 3", filename: "three.mp3"))
        composition.addSingle(Single(track: 4, title: "Track 4", filename: "four.mp3"))
        composition.addSingle(Single(track: 2, title: "Track 2", filename: "two.mp3"))
        
        composition.sortContents()
        
        var index = 0
        for single in composition.contents {
            switch index {
            case 0:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 2)
                XCTAssertEqual(single.title, "Track 2")
                XCTAssertEqual(single.audiofileRef, "two.mp3")
            case 1:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 3)
                XCTAssertEqual(single.title, "Track 3")
                XCTAssertEqual(single.audiofileRef, "three.mp3")
            case 2:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 4)
                XCTAssertEqual(single.title, "Track 4")
                XCTAssertEqual(single.audiofileRef, "four.mp3")
            case 3:
                XCTAssertNil(single.disk)
                XCTAssertEqual(single.track, 5)
                XCTAssertEqual(single.title, "Track 5")
                XCTAssertEqual(single.audiofileRef, "five.mp3")
            default:
                XCTFail("Unexpected contents: \(index)")
            }
            index += 1
        }

    }
    
    func testSortCompositionContents2() throws {
        var composition = Composition(track: 1, title: "Test Composition", disk: 1)
        composition.addSingle(Single(track: 5, title: "Track 5", filename: "five.mp3", disk: 1))
        composition.addSingle(Single(track: 3, title: "Track 3", filename: "three.mp3", disk: 1))
        composition.addSingle(Single(track: 4, title: "Track 4", filename: "four.mp3", disk: 2))
        composition.addSingle(Single(track: 2, title: "Track 2", filename: "two.mp3", disk: 2))
        
        composition.sortContents()
        
        var index = 0
        for single in composition.contents {
            switch index {
            case 0:
                XCTAssertEqual(single.disk, 1)
                XCTAssertEqual(single.track, 3)
                XCTAssertEqual(single.title, "Track 3")
                XCTAssertEqual(single.audiofileRef, "three.mp3")
            case 1:
                XCTAssertEqual(single.disk, 1)
                XCTAssertEqual(single.track, 5)
                XCTAssertEqual(single.title, "Track 5")
                XCTAssertEqual(single.audiofileRef, "five.mp3")
            case 2:
                XCTAssertEqual(single.disk, 2)
                XCTAssertEqual(single.track, 2)
                XCTAssertEqual(single.title, "Track 2")
                XCTAssertEqual(single.audiofileRef, "two.mp3")
            case 3:
                XCTAssertEqual(single.disk, 2)
                XCTAssertEqual(single.track, 4)
                XCTAssertEqual(single.title, "Track 4")
                XCTAssertEqual(single.audiofileRef, "four.mp3")
            default:
                XCTFail("Unexpected contents: \(index)")
            }
            index += 1
        }

    }
    
    func testSortAlbumContents() throws {
        var album = Album(title: "Test Album")
        
        var composition2 = Composition(track: 2, title: "Composition 2", disk: 2)
        composition2.addSingle(Single(track: 4, title: "Movement 3", filename: "fourb.mp3", disk: 2))
        composition2.addSingle(Single(track: 2, title: "Movement 1", filename: "twob.mp3", disk: 2))
        composition2.addSingle(Single(track: 3, title: "Movement 2", filename: "threeb.mp3", disk: 2))
        album.addComposition(composition2)
        var composition = Composition(track: 2, title: "Composition 1")
        composition.addSingle(Single(track: 4, title: "Movement 3", filename: "four.mp3", disk: 1))
        composition.addSingle(Single(track: 2, title: "Movement 1", filename: "two.mp3", disk: 1))
        composition.addSingle(Single(track: 3, title: "Movement 2", filename: "three.mp3", disk: 1))
        album.addContent(AlbumContent(composition: composition))
        album.addSingle(Single(track: 1, title: "Single 2", filename: "oneb.mp3", disk: 2))
        album.addSingle(Single(track: 1, title: "Single 1", filename: "one.mp3", disk: 1))

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
                    XCTAssertEqual(single.title, "Single 1")
                    XCTAssertEqual(single.audiofileRef, "one.mp3")
                } else {
                    XCTFail("Expecting single content - \(index)")
                }
            case 1:
                XCTAssertNil(content.disk)
                XCTAssertEqual(content.track, 2)
                if let composition = content.composition {
                    XCTAssertEqual(composition.title, "Composition 1")
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(single.disk, 1)
                            XCTAssertEqual(single.track, 2)
                            XCTAssertEqual(single.title, "Movement 1")
                            XCTAssertEqual(single.audiofileRef, "two.mp3")
                        case 1:
                            XCTAssertEqual(single.disk, 1)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement 2")
                            XCTAssertEqual(single.audiofileRef, "three.mp3")
                        case 2:
                            XCTAssertEqual(single.disk, 1)
                            XCTAssertEqual(single.track, 4)
                            XCTAssertEqual(single.title, "Movement 3")
                            XCTAssertEqual(single.audiofileRef, "four.mp3")
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
                    XCTAssertEqual(single.title, "Single 2")
                    XCTAssertEqual(single.audiofileRef, "oneb.mp3")
                } else {
                    XCTFail("Expecting single content - \(index)")
                }
            case 3:
                XCTAssertEqual(content.disk, 2)
                XCTAssertEqual(content.track, 2)
                if let composition = content.composition {
                    XCTAssertEqual(composition.title, "Composition 2")
                    var cIndex = 0
                    for single in composition.contents {
                        switch cIndex {
                        case 0:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 2)
                            XCTAssertEqual(single.title, "Movement 1")
                            XCTAssertEqual(single.audiofileRef, "twob.mp3")
                        case 1:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 3)
                            XCTAssertEqual(single.title, "Movement 2")
                            XCTAssertEqual(single.audiofileRef, "threeb.mp3")
                        case 2:
                            XCTAssertEqual(single.disk, 2)
                            XCTAssertEqual(single.track, 4)
                            XCTAssertEqual(single.title, "Movement 3")
                            XCTAssertEqual(single.audiofileRef, "fourb.mp3")
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
