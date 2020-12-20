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
    
    func testAlbumUpdate1() throws {
        var single = Single(track: 1, title: "The Girl from Ipanema", filename: "girl_from_ipanema.flac")
        single.artist = "Stan Getz"
        single.composer = "Antonio Carlos Jobim"
        single.duration = 320
        
        var album = Album(title: "The Girl from Ipanema")
        album.artist = "Stan Getz"
        album.composer = "Stan Getz"
        album.addSingle(single)
        
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
    
    func testAlbumUpdate2() throws {
        var movement1 = Movement(track: 1, title: "Allegro non troppo", filename: "allegro_non_troppo.flac")
        movement1.duration = 1126
        var movement2 = Movement(track: 2, title: "Allegro appassionato", filename: "allegro_appassionato.flac")
        movement2.duration = 572
        var movement3 = Movement(track: 3, title: "Andante", filename: "andante.flac")
        movement3.duration = 788
        var movement4 = Movement(track: 4, title: "Allegretto graziioso", filename: "allegro_appassionato.flac")
        movement4.duration = 569
        
        var composition = Composition(track: 1, title: "Piano Concerto No. 2 in B flat, Op. 83")
        // Added in random order to test sortContents()
        composition.addMovement(movement4)
        composition.addMovement(movement2)
        composition.addMovement(movement1)
        composition.addMovement(movement3)
        
        var album = Album(title: "Brahms: Piano Concerto No. 2 in B flat, Op. 83")
        album.artist = "Vladimir Ashkenazy"
        album.composer = "Johannes Brahms (1833-1897)"
        album.conductor = "Haitnik"
        album.orchestra = "Wiener Philharmoniker"
        album.genre = "Classical"
        album.recordingYear = 1984
        album.addComposition(composition)
        
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
        
        XCTAssertEqual(composition.movements.count, 4)
        movement1 = composition.movements[0]
        XCTAssertEqual(movement1.track, 1)
        XCTAssertEqual(movement1.title, "Allegro non troppo")

        movement2 = composition.movements[1]
        XCTAssertEqual(movement2.track, 2)
        XCTAssertEqual(movement2.title, "Allegro appassionato")
        
        movement3 = composition.movements[2]
        XCTAssertEqual(movement3.track, 3)
        XCTAssertEqual(movement3.title, "Andante")
        
        movement4 = composition.movements[3]
        XCTAssertEqual(movement4.track, 4)
        XCTAssertEqual(movement4.title, "Allegretto graziioso")

        
    }
    
    func testCompositionUpdate() throws {
        var movement1 = Movement(track: 1, title: "Allegro non troppo", filename: "allegro_non_troppo.flac")
        movement1.duration = 1126
        var movement2 = Movement(track: 2, title: "Allegro appassionato", filename: "allegro_appassionato.flac")
        movement2.duration = 572
        var movement3 = Movement(track: 3, title: "Andante", filename: "andante.flac")
        movement3.duration = 788
        var movement4 = Movement(track: 4, title: "Allegretto graziioso", filename: "allegro_appassionato.flac")
        movement4.duration = 569
        
        var composition = Composition(track: 1, title: "Piano Concerto No. 2 in B flat, Op. 83")
        composition.artist = "Vladimir Ashkenazy"
        composition.composer = "Johannes Brahms (1833-1897)"
        composition.conductor = "Haitnik"
        composition.orchestra = "Wiener Philharmoniker"
        composition.genre = "Classical"
        composition.recordingYear = 1984
        // Added in random order to test sortContents()
        composition.addMovement(movement4)
        composition.addMovement(movement2)
        composition.addMovement(movement1)
        composition.addMovement(movement3)
        
        composition.sortContents()
        composition.update()
        
        XCTAssertEqual(composition.sortTitle, "piano concerto no. 2 in b flat, op. 83")
        XCTAssertEqual(composition.sortArtist, "ashkenazy, vladimir")
        XCTAssertEqual(composition.sortComposer, "brahms, johannes")
        XCTAssertEqual(composition.duration, 3055)
        
        XCTAssertEqual(composition.movements.count, 4)
        movement1 = composition.movements[0]
        XCTAssertEqual(movement1.track, 1)
        XCTAssertEqual(movement1.title, "Allegro non troppo")

        movement2 = composition.movements[1]
        XCTAssertEqual(movement2.track, 2)
        XCTAssertEqual(movement2.title, "Allegro appassionato")
        
        movement3 = composition.movements[2]
        XCTAssertEqual(movement3.track, 3)
        XCTAssertEqual(movement3.title, "Andante")
        
        movement4 = composition.movements[3]
        XCTAssertEqual(movement4.track, 4)
        XCTAssertEqual(movement4.title, "Allegretto graziioso")


    }

    func testSingleUpdate() throws {
        
        var single = Single(track: 1, title: "The Girl from Ipanema", filename: "girl_from_ipanema.flac")
        single.artist = "Stan Getz"
        single.composer = "Antonio Carlos Jobim"

        single.update()
        
        XCTAssertNil(single.albumId)
        XCTAssertNil(single.compositionId)
        XCTAssertEqual(single.sortTitle, "girl from ipanema")
        XCTAssertEqual(single.sortArtist, "getz, stan")
        XCTAssertEqual(single.sortComposer, "jobim, antonio carlos")
     }
    
    static var allTests = [
        ("testAlbumUpdate1", testAlbumUpdate1),
        ("testAlbumUpdate2", testAlbumUpdate2),
        ("testCompositionUpdate", testCompositionUpdate),
        ("testSingleUpdate", testSingleUpdate),
    ]
}
