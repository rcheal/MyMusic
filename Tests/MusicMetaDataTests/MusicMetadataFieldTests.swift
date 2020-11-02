//
//  MusicMetadataFieldTests.swift
//
//
//  Created by Robert Cheal on 11/1/20.
//

import XCTest
@testable import MusicMetadata


@available(OSX 11.0, *)
final class MusicMetadataFieldTests: XCTestCase {

    func testFields1() throws {
        var album = Album(title: "Test Album")
        album.id = "1DFC13CC-BE33-4CED-96D9-CDC3508C6522"
        album.sortTitle = "Sort Title"
        album.subtitle = "Subtitle"
        album.artist = "Artist"
        album.sortArtist = "SortArtist"
        album.supportingArtists = "Artist1;Artist2;Artist3"
        album.composer = "Composer"
        album.sortComposer = "SortComposer"
        album.conductor = "Conductor"
        album.orchestra = "Orchestra"
        album.lyricist = "Lyricist"
        album.genre = "Genre"
        album.publisher = "Publisher"
        album.copyright = "Copyright"
        album.encodedBy = "EncodedBy"
        album.encoderSettings = "EncoderSettings"
        album.recordingYear = 2020
        album.duration = 1800
        album.frontCoverArtRef = "front.png"
        album.backCoverArtRef = "back.png"
        
        let jsonData = album.json ?? Data()
        let json = String(bytes: jsonData, encoding: String.Encoding.utf8) ?? ""
        let jsonRef =
"""
{"id":"1DFC13CC-BE33-4CED-96D9-CDC3508C6522","composer":"Composer","encodedBy":"EncodedBy","subtitle":"Subtitle","contents":[],"supportingArtists":"Artist1;Artist2;Artist3","lyricist":"Lyricist","encoderSettings":"EncoderSettings","orchestra":"Orchestra","title":"Test Album","publisher":"Publisher","recordingYear":2020,"backCoverArtRef":"back.png","conductor":"Conductor","duration":1800,"frontCoverArtRef":"front.png","artist":"Artist","genre":"Genre","copyright":"Copyright"}
"""
        
        XCTAssertEqual(json, jsonRef)
        
        let album2 = Album.decodeFrom(json: jsonData)
        XCTAssertEqual(album.title, album2?.title)
        XCTAssertNil(album2?.sortTitle)
        XCTAssertEqual(album.subtitle, album2?.subtitle)
        XCTAssertEqual(album.artist, album2?.artist)
        XCTAssertNil(album2?.sortArtist)
        XCTAssertEqual(album.supportingArtists, album2?.supportingArtists)
        XCTAssertEqual(album.composer, album2?.composer)
        XCTAssertNil(album2?.sortComposer)
        XCTAssertEqual(album.conductor, album2?.conductor)
        XCTAssertEqual(album.orchestra, album2?.orchestra)
        XCTAssertEqual(album.lyricist, album2?.lyricist)
        XCTAssertEqual(album.genre, album2?.genre)
        XCTAssertEqual(album.publisher, album2?.publisher)
        XCTAssertEqual(album.copyright, album2?.copyright)
        XCTAssertEqual(album.encodedBy, album2?.encodedBy)
        XCTAssertEqual(album.encoderSettings, album2?.encoderSettings)
        XCTAssertEqual(album.recordingYear, album2?.recordingYear)
        XCTAssertEqual(album.duration, album2?.duration)
        XCTAssertEqual(album.frontCoverArtRef, album2?.frontCoverArtRef)
        XCTAssertEqual(album.backCoverArtRef, album2?.backCoverArtRef)
        
        
    }
    
    func testFields2() throws {
        var album = Album(title: "Test Album")
        album.id = "1DFC13CC-BE33-4CED-96D9-CDC3508C6522"
        album.sortTitle = "Sort Title"
        album.subtitle = "Subtitle"
        album.artist = "Artist"
        album.sortArtist = "SortArtist"
        album.supportingArtists = "Artist1\nArtist2\nArtist3"
        album.composer = "Composer"
        album.sortComposer = "SortComposer"
        album.conductor = "Conductor"
        album.orchestra = "Orchestra"
        album.lyricist = "Lyricist"
        album.genre = "Genre"
        album.publisher = "Publisher"
        album.copyright = "Copyright"
        album.encodedBy = "EncodedBy"
        album.encoderSettings = "EncoderSettings"
        album.recordingYear = 2020
        album.duration = 1800
        album.frontCoverArtRef = "front.png"
        album.backCoverArtRef = "back.png"
        
        var composition = Composition(track: 1, title: "Composition 1", disk: 1)
//        composition.id = ""
        composition.sortTitle = "SortTitle"
        composition.subtitle = "SubTitle"
        composition.artist = "Artist"
        composition.sortArtist = "SortArtist"
        composition.supportingArtists = "Artist1;Artist2;Artist3"
        composition.composer = "Composer"
        composition.sortComposer = "SortComposer"
        composition.conductor = "Conductor"
        composition.orchestra = "Orchestra"
        composition.lyricist = "Lyricist"
        composition.genre = "Genre"
        composition.publisher = "Publisher"
        composition.copyright = "Copyright"
        composition.encodedBy = "EncodedBy"
        composition.encoderSettings = "EncoderSettings"
        composition.recordingYear = 2020
        composition.duration = 1800

        var component = Single(track: 1, title: "Component 1", filename: "Component1.flac")
//        component.id = ""
        component.disk = 1
        component.sortTitle = "SortTitle"
        component.subtitle = "SubTitle"
        component.artist = "Artist"
        component.sortArtist = "SortArtist"
        component.supportingArtists = "Artist1;Artist2;Artist3"
        component.composer = "Composer"
        component.sortComposer = "SortComposer"
        component.conductor = "Conductor"
        component.orchestra = "Orchestra"
        component.lyricist = "Lyricist"
        component.genre = "Genre"
        component.publisher = "Publisher"
        component.copyright = "Copyright"
        component.encodedBy = "EncodedBy"
        component.encoderSettings = "EncoderSettings"
        component.recordingYear = 2020
        component.duration = 1800

        composition.addContent(component)
        album.addContent(AlbumContent(track: 1, composition: composition, disk: 1))
        
        var single = Single(track: 2, title: "Single 1", filename: "Single1.flac")
//        single.id = ""
        single.disk = 1
        single.sortTitle = "SortTitle"
        single.subtitle = "SubTitle"
        single.artist = "Artist"
        single.sortArtist = "SortArtist"
        single.supportingArtists = "Artist1;Artist2;Artist3"
        single.composer = "Composer"
        single.sortComposer = "SortComposer"
        single.conductor = "Conductor"
        single.orchestra = "Orchestra"
        single.lyricist = "Lyricist"
        single.genre = "Genre"
        single.publisher = "Publisher"
        single.copyright = "Copyright"
        single.encodedBy = "EncodedBy"
        single.encoderSettings = "EncoderSettings"
        single.recordingYear = 2020
        single.duration = 1800

        album.addContent(AlbumContent(track: 2, single: single, disk: 1))

        let jsonData = album.jsonp ?? Data()
//        let json = String(bytes: jsonData, encoding: String.Encoding.utf8) ?? ""
//        print(json)

        let album2 = Album.decodeFrom(json: jsonData)
        XCTAssertEqual(album.title, album2?.title)
        XCTAssertNil(album2?.sortTitle)
        XCTAssertEqual(album.subtitle, album2?.subtitle)
        XCTAssertEqual(album.artist, album2?.artist)
        XCTAssertNil(album2?.sortArtist)
        XCTAssertEqual(album.supportingArtists, album2?.supportingArtists)
        XCTAssertEqual(album.composer, album2?.composer)
        XCTAssertNil(album2?.sortComposer)
        XCTAssertEqual(album.conductor, album2?.conductor)
        XCTAssertEqual(album.orchestra, album2?.orchestra)
        XCTAssertEqual(album.lyricist, album2?.lyricist)
        XCTAssertEqual(album.genre, album2?.genre)
        XCTAssertEqual(album.publisher, album2?.publisher)
        XCTAssertEqual(album.copyright, album2?.copyright)
        XCTAssertEqual(album.encodedBy, album2?.encodedBy)
        XCTAssertEqual(album.encoderSettings, album2?.encoderSettings)
        XCTAssertEqual(album.recordingYear, album2?.recordingYear)
        XCTAssertEqual(album.duration, album2?.duration)
        XCTAssertEqual(album.frontCoverArtRef, album2?.frontCoverArtRef)
        XCTAssertEqual(album.backCoverArtRef, album2?.backCoverArtRef)
        
        let content = album.contents[0]
        let content2 = album2?.contents[0]
        XCTAssertEqual(content.disk, content2?.disk)
        XCTAssertEqual(content.track, content2?.track)

        let compositionA = content.composition
        let compositionA2 = content2?.composition
        XCTAssertEqual(compositionA?.title, compositionA2?.title)
        XCTAssertNil(compositionA2?.sortTitle)
        XCTAssertEqual(compositionA?.subtitle, compositionA2?.subtitle)
        XCTAssertEqual(compositionA?.artist, compositionA2?.artist)
        XCTAssertNil(compositionA2?.sortArtist)
        XCTAssertEqual(compositionA?.supportingArtists, compositionA2?.supportingArtists)
        XCTAssertEqual(compositionA?.composer, compositionA2?.composer)
        XCTAssertNil(compositionA2?.sortComposer)
        XCTAssertEqual(compositionA?.conductor, compositionA2?.conductor)
        XCTAssertEqual(compositionA?.orchestra, compositionA2?.orchestra)
        XCTAssertEqual(compositionA?.lyricist, compositionA2?.lyricist)
        XCTAssertEqual(compositionA?.genre, compositionA2?.genre)
        XCTAssertEqual(compositionA?.publisher, compositionA2?.publisher)
        XCTAssertEqual(compositionA?.copyright, compositionA2?.copyright)
        XCTAssertEqual(compositionA?.encodedBy, compositionA2?.encodedBy)
        XCTAssertEqual(compositionA?.encoderSettings, compositionA2?.encoderSettings)
        XCTAssertEqual(compositionA?.recordingYear, compositionA2?.recordingYear)
        XCTAssertEqual(compositionA?.duration, compositionA2?.duration)

        let componentA = compositionA?.contents[0]
        let componentA2 = compositionA2?.contents[0]
        XCTAssertEqual(componentA?.title, componentA2?.title)
        XCTAssertNil(componentA2?.sortTitle)
        XCTAssertEqual(componentA?.subtitle, componentA2?.subtitle)
        XCTAssertEqual(componentA?.artist, componentA2?.artist)
        XCTAssertNil(componentA2?.sortArtist)
        XCTAssertEqual(componentA?.supportingArtists, componentA2?.supportingArtists)
        XCTAssertEqual(componentA?.composer, componentA2?.composer)
        XCTAssertNil(componentA2?.sortComposer)
        XCTAssertEqual(componentA?.conductor, componentA2?.conductor)
        XCTAssertEqual(componentA?.orchestra, componentA2?.orchestra)
        XCTAssertEqual(componentA?.lyricist, componentA2?.lyricist)
        XCTAssertEqual(componentA?.genre, componentA2?.genre)
        XCTAssertEqual(componentA?.publisher, componentA2?.publisher)
        XCTAssertEqual(componentA?.copyright, componentA2?.copyright)
        XCTAssertEqual(componentA?.encodedBy, componentA2?.encodedBy)
        XCTAssertEqual(componentA?.encoderSettings, componentA2?.encoderSettings)
        XCTAssertEqual(componentA?.recordingYear, componentA2?.recordingYear)
        XCTAssertEqual(componentA?.duration, componentA2?.duration)
        XCTAssertEqual(componentA?.audiofileRef, componentA2?.audiofileRef)

        let contentA = album.contents[1]
        let contentA2 = album2?.contents[1]
        XCTAssertEqual(contentA.disk, contentA2?.disk)
        XCTAssertEqual(contentA.track, contentA2?.track)

        let singleA = contentA.single
        let singleA2 = contentA2?.single
        XCTAssertEqual(singleA?.title, singleA2?.title)
        XCTAssertNil(singleA2?.sortTitle)
        XCTAssertEqual(singleA?.subtitle, singleA2?.subtitle)
        XCTAssertEqual(singleA?.artist, singleA2?.artist)
        XCTAssertNil(singleA2?.sortArtist)
        XCTAssertEqual(singleA?.supportingArtists, singleA2?.supportingArtists)
        XCTAssertEqual(singleA?.composer, singleA2?.composer)
        XCTAssertNil(singleA2?.sortComposer)
        XCTAssertEqual(singleA?.conductor, singleA2?.conductor)
        XCTAssertEqual(singleA?.orchestra, singleA2?.orchestra)
        XCTAssertEqual(singleA?.lyricist, singleA2?.lyricist)
        XCTAssertEqual(singleA?.genre, singleA2?.genre)
        XCTAssertEqual(singleA?.publisher, singleA2?.publisher)
        XCTAssertEqual(singleA?.copyright, singleA2?.copyright)
        XCTAssertEqual(singleA?.encodedBy, singleA2?.encodedBy)
        XCTAssertEqual(singleA?.encoderSettings, singleA2?.encoderSettings)
        XCTAssertEqual(singleA?.recordingYear, singleA2?.recordingYear)
        XCTAssertEqual(singleA?.duration, singleA2?.duration)
        XCTAssertEqual(singleA?.audiofileRef, singleA2?.audiofileRef)
    }

    static var allTests = [
        ("testFields1", testFields1),
        ("testFields2", testFields2)
    ]
}
