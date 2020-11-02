//
//  MusicMetadataUpdateTests.swift
//  
//
//  Created by Robert Cheal on 11/1/20.
//

import XCTest
@testable import MusicMetadata


@available(OSX 11.0, *)
final class MusicMetadataUpdateTests: XCTestCase {
    
    func testUpdate1() throws {
        var single = Single(track: 1, title: "The Girl from Ipanema", filename: "girl_from_ipanema.flac")
        single.artist = "Stan Getz"
        single.composer = "Antonio Carlos Jobim"
        single.duration = 320
        
        var album = Album(title: "The Girl from Ipanema")
        album.artist = "Stan Getz"
        album.composer = "Stan Getz"
        album.addContent(AlbumContent(track: 2, single: single))    // Purposely wrong track to verify the update() will correct it...
        
        album.update()
        single = album.contents[0].single!
        
        XCTAssertEqual(single.albumId, album.id)
        XCTAssertNil(single.compositionId)
        XCTAssertEqual(single.sortTitle, "girl from ipanema")
        XCTAssertEqual(single.sortArtist, "getz, stan")
        XCTAssertEqual(single.sortComposer, "jobim, antonio carlos")
        
        XCTAssertEqual(album.sortTitle, "girl from ipanema")
        XCTAssertEqual(album.sortArtist, "getz, stan")
        XCTAssertEqual(album.sortComposer, "getz, stan")
        XCTAssertEqual(album.contents[0].track, 1)
        XCTAssertEqual(album.duration, 320)
        
    }
    
    func testUpdate2() throws {
        var single1 = Single(track: 1, title: "Allegro non troppo", filename: "allegro_non_troppo.flac")
        single1.duration = 1126
        var single2 = Single(track: 2, title: "Allegro appassionato", filename: "allegro_appassionato.flac")
        single2.duration = 572
        var single3 = Single(track: 3, title: "Andante", filename: "andante.flac")
        single3.duration = 788
        var single4 = Single(track: 4, title: "Allegretto graziioso", filename: "allegro_appassionato.flac")
        single4.duration = 569
        
        var composition = Composition(track: 1, title: "Piano Concerto No. 2 in B flat, Op. 83")
        // Added in random order to test sortContents()
        composition.addContent(single4)
        composition.addContent(single2)
        composition.addContent(single1)
        composition.addContent(single3)
        
        var album = Album(title: "Brahms: Piano Concerto No. 2 in B flat, Op. 83")
        album.artist = "Vladimir Ashkenazy"
        album.composer = "Johannes Brahms (1833-1897)"
        album.conductor = "Haitnik"
        album.orchestra = "Wiener Philharmoniker"
        album.genre = "Classical"
        album.recordingYear = 1984
        album.addContent(AlbumContent(track: 7, composition: composition))
        
        album.sortContents()
        album.update()

        XCTAssertEqual(album.sortTitle, "brahms: piano concerto no. 2 in b flat, op. 83")
        XCTAssertEqual(album.sortArtist, "ashkenazy, vladimir")
        XCTAssertEqual(album.sortComposer, "brahms, johannes")
        XCTAssertEqual(album.duration, 3055)
        let content = album.contents[0]
        XCTAssertEqual(content.track, 1)
        composition = content.composition!
        XCTAssertEqual(composition.sortTitle, "piano concerto no. 2 in b flat, op. 83")
        XCTAssertEqual(composition.sortArtist, "ashkenazy, vladimir")
        XCTAssertEqual(composition.sortComposer, "brahms, johannes")
        XCTAssertEqual(composition.duration, 3055)
        
        XCTAssertEqual(composition.contents.count, 4)
        single1 = composition.contents[0]
        XCTAssertEqual(single1.sortTitle, "allegro non troppo")
        XCTAssertEqual(single1.sortArtist, "ashkenazy, vladimir")
        XCTAssertEqual(single1.sortComposer, "brahms, johannes")

        single2 = composition.contents[1]
        XCTAssertEqual(single2.sortTitle, "allegro appassionato")
        XCTAssertEqual(single2.sortArtist, "ashkenazy, vladimir")
        XCTAssertEqual(single2.sortComposer, "brahms, johannes")
        
        single3 = composition.contents[2]
        XCTAssertEqual(single3.sortTitle, "andante")
        XCTAssertEqual(single3.sortArtist, "ashkenazy, vladimir")
        XCTAssertEqual(single3.sortComposer, "brahms, johannes")
        
        single4 = composition.contents[3]
        XCTAssertEqual(single4.sortTitle, "allegretto graziioso")
        XCTAssertEqual(single4.sortArtist, "ashkenazy, vladimir")
        XCTAssertEqual(single4.sortComposer, "brahms, johannes")

        
    }

    static var allTests = [
        ("testUpdate1", testUpdate1),
        ("testUpdate2", testUpdate2)
    ]
}
