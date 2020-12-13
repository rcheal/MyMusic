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
    
    func createAlbum(withContents: Bool = true, withArt: Bool = true) -> Album {
        var album = Album(title: "The Title")
        album.id = "1DFC13CC-BE33-4CED-96D9-CDC3508C6522"
        album.sortTitle = "Title"
        album.subtitle = "Subtitle"
        album.artist = "The Artist"
        album.sortArtist = "Artist"
        album.supportingArtists = "Artist1;Artist2;Artist3"
        album.composer = "The Composer"
        album.sortComposer = "Composer"
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
        if withArt {
            album.addArt(AlbumArtRef(type: .front, format: .png))
            album.addArt(AlbumArtRef(type: .back, format: .png))
            album.addArt(AlbumArtRef(type: .page, format: .jpg))
            album.addArt(AlbumArtRef(type: .page, format: .jpg))
        }
        if withContents {
            let composition = createComposition()
            album.addComposition(composition)
            let single = createSingle(track: 2, title: "Single 1", filename: "Single1.flac")
            album.addSingle(single)
        }
        
        return album
    }
    
    func createComposition() -> Composition {
        var composition = Composition(track: 1, title: "Composition 1", disk: 1)
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

        let movement = createSingle(track: 1, title: "Component 1", filename: "Component1.flac")

        composition.addSingle(movement)
        
        return composition
    }
    
    func createSingle(track: Int, title: String, filename: String) -> Single {
        var single = Single(track: track, title: title, filename: filename)
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

        return single
    }

    func testAlbumFields1() throws {
        let album = createAlbum(withContents: false, withArt: false)

        let jsonData = album.json ?? Data()
        let json = String(bytes: jsonData, encoding: String.Encoding.utf8) ?? ""
        let jsonRef =
"""
{"id":"1DFC13CC-BE33-4CED-96D9-CDC3508C6522","composer":"The Composer","encodedBy":"EncodedBy","subtitle":"Subtitle","supportingArtists":"Artist1;Artist2;Artist3","lyricist":"Lyricist","encoderSettings":"EncoderSettings","orchestra":"Orchestra","title":"The Title","publisher":"Publisher","recordingYear":2020,"albumArt":{"items":[],"pageCount":0},"conductor":"Conductor","duration":1800,"contents":[],"artist":"The Artist","genre":"Genre","copyright":"Copyright"}
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
        XCTAssertEqual(album.frontArtRef(), album2?.frontArtRef())
        XCTAssertEqual(album.backArtRef(), album2?.backArtRef())
        XCTAssertEqual(album.pageArtRef(1), album2?.pageArtRef(1))
        XCTAssertEqual(album.pageArtRef(2), album2?.pageArtRef(2))
        XCTAssertNil(album.pageArtRef(3))
        XCTAssertNil(album.pageArtRef(4))
        XCTAssertNil(album.pageArtRef(5))
        XCTAssertNil(album.pageArtRef(6))
        XCTAssertNil(album.pageArtRef(7))
        XCTAssertNil(album.pageArtRef(8))
        XCTAssertNil(album.pageArtRef(9))

        
    }
    
    func testFields2() throws {
        let album = createAlbum()

        let jsonData = album.jsonp ?? Data()

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
        XCTAssertEqual(album.frontArtRef(), album2?.frontArtRef())
        XCTAssertEqual(album.backArtRef(), album2?.backArtRef())
        XCTAssertEqual(album.albumArt.pageCount, 2)
        XCTAssertEqual(album.pageArtRef(1), album2?.pageArtRef(1))
        XCTAssertEqual(album.pageArtRef(2), album2?.pageArtRef(2))

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

    func testAlbumListItem() throws {
        var album = createAlbum(withContents: false, withArt: false)
        album.update()
        
        let albumListItem = AlbumListItem(album)
        
        XCTAssertEqual(albumListItem.id, album.id)
        XCTAssertEqual(albumListItem.title, album.title)
        XCTAssertEqual(albumListItem.sortTitle, album.sortTitle)
        XCTAssertEqual(albumListItem.artist, album.artist)
        XCTAssertEqual(albumListItem.sortArtist, album.sortArtist)
        XCTAssertEqual(albumListItem.composer, album.composer)
        XCTAssertEqual(albumListItem.sortComposer, album.sortComposer)
        XCTAssertEqual(albumListItem.genre, album.genre)
        XCTAssertEqual(albumListItem.recordingYear, album.recordingYear)
        XCTAssertEqual(albumListItem.frontArtRef,album.frontArtRef())
    }
    
    func testAlbumListItemUpdate() throws {
        let album = createAlbum(withContents: false, withArt: false)
        
        var albumListItem = AlbumListItem(album)
        albumListItem.title = "A New Title"
        albumListItem.artist = "The Beatles"
        albumListItem.composer = "Ludwig van Beethoven (1789-1823)"
        albumListItem.update()
        
        XCTAssertEqual(albumListItem.sortTitle, "new title")
        XCTAssertEqual(albumListItem.sortArtist, "beatles")
        XCTAssertEqual(albumListItem.sortComposer, "beethoven, ludwig van")

    }
    
    func testCompositionListItem() throws {
        var album = createAlbum()
        album.update()
        
        let composition = album.contents[0].composition!
        
        let compositionListItem = CompositionListItem(composition)
        
        XCTAssertEqual(compositionListItem.id, composition.id)
        XCTAssertEqual(compositionListItem.albumId, album.id)
        XCTAssertEqual(compositionListItem.title, composition.title)
        XCTAssertEqual(compositionListItem.sortTitle, composition.sortTitle)
        XCTAssertEqual(compositionListItem.artist, composition.artist)
        XCTAssertEqual(compositionListItem.sortArtist, composition.sortArtist)
        XCTAssertEqual(compositionListItem.composer, composition.composer)
        XCTAssertEqual(compositionListItem.sortComposer, composition.sortComposer)
        
    }
    
    func testCompositionListItemUpdate() throws {
        let composition = createComposition()
        
        var compositionListItem = CompositionListItem(composition)
        compositionListItem.title = "A New Title"
        compositionListItem.artist = "The Doors"
        compositionListItem.composer = "Ludwig van Beethoven(1020-3829)"
        compositionListItem.update()
        
        XCTAssertEqual(compositionListItem.sortTitle, "new title")
        XCTAssertEqual(compositionListItem.sortArtist, "doors")
        XCTAssertEqual(compositionListItem.sortComposer, "beethoven, ludwig van")
        
    }
    
    func testSingleListItem() throws {
        var album = createAlbum()
        album.update()
        
        let single = album.contents[1].single!
        
        let singleListItem = SingleListItem(single)
        
        XCTAssertEqual(singleListItem.id, single.id)
        XCTAssertEqual(singleListItem.albumId, album.id)
        XCTAssertEqual(singleListItem.title, single.title)
        XCTAssertEqual(singleListItem.sortTitle, single.sortTitle)
        XCTAssertEqual(singleListItem.artist, single.artist)
        XCTAssertEqual(singleListItem.sortArtist, single.sortArtist)
        XCTAssertEqual(singleListItem.composer, single.composer)
        XCTAssertEqual(singleListItem.sortComposer, single.sortComposer)

    }
    
    func testSingleListItemUpdate() throws {
        let single = createSingle(track: 1, title: "An apple a day", filename: "apple.flac")
        
        var singleListItem = SingleListItem(single)
        singleListItem.title = "an apricot a week"
        singleListItem.artist = "The Strawberry AlarmClock"
        singleListItem.composer = "John Lennon"
        singleListItem.update()
        
        XCTAssertEqual(singleListItem.sortTitle, "apricot a week")
        XCTAssertEqual(singleListItem.sortArtist, "alarmclock, strawberry")
        XCTAssertEqual(singleListItem.sortComposer, "lennon, john")
    }
    
    static var allTests = [
        ("testAlbumFields1", testAlbumFields1),
        ("testFields2", testFields2)
    ]
}
