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
        album.directory = "Title/Artist"
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
        var composition = Composition(title: "Composition 1", track: 1, disk: 1)
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

        let movement = createMovement(track: 1, title: "Component 1", filename: "Component1.flac")

        composition.addMovement(movement)
        
        return composition
    }
    
    func createMovement(track: Int, title: String, filename: String) -> Movement {
        var movement = Movement(title: title, filename: filename, track: track)
        movement.disk = 1
        movement.subtitle = "SubTitle"
        movement.duration = 1800

        return movement
    }
    
    func createSingle(track: Int, title: String, filename: String) -> Single {
        var single = Single(title: title, filename: filename, track: track)
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
    
    func createPlaylist(_ title: String) -> Playlist {
        let content = [
            PlaylistItem(AlbumSummary(UUID().uuidString, title: "White Album"), items: [
                PlaylistItem(SingleSummary(UUID().uuidString, title: "Back in the U.S.S.R.")),
                PlaylistItem(SingleSummary(UUID().uuidString, title: "Dear Prudence")),
                PlaylistItem(SingleSummary(UUID().uuidString, title: "Glass Onion")),
                PlaylistItem(SingleSummary(UUID().uuidString, title: "Ob-La-Di, Ob-La-Da")),
                PlaylistItem(SingleSummary(UUID().uuidString, title: "Wild Honey Pie"))
            ]),
            PlaylistItem(CompositionSummary(UUID().uuidString, title: "Beethoven Symphony No. 6"), items: [
                PlaylistItem(Movement(title: "Allegro ma non troppo", filename: "", track: 1)),
                PlaylistItem(Movement(title: "Andante molto mosso", filename: "", track: 2)),
                PlaylistItem(Movement(title: "Allegro", filename: "", track: 3)),
                PlaylistItem(Movement(title: "Allegro", filename: "", track: 4)),
                PlaylistItem(Movement(title: "Allegretto", filename: "", track: 5))
            ])
        ]

        var playlist = Playlist(title)
        playlist.items = content
        playlist.shared = true

        playlist.user = "bob"
        return playlist
    }

    func testSingleFields() throws {
        var single = createSingle(track: 1, title: "Song1", filename: "song1.mp3")
        single.id = "A6B0C134-72A9-472D-A6BC-9501CD3847CA"
        single.track = 1
        single.disk = nil
        single.directory = "Diretory"
        let jsonData = single.json ?? Data()
        let json = String(bytes: jsonData, encoding: String.Encoding.utf8) ?? ""
        let jsonRef =
"""
{"composer":"Composer","publisher":"Publisher","title":"Song1","supportingArtists":"Artist1;Artist2;Artist3","lyricist":"Lyricist","orchestra":"Orchestra","directory":"Diretory","duration":1800,"encodedBy":"EncodedBy","sortTitle":"SortTitle","sortArtist":"SortArtist","encoderSettings":"EncoderSettings","track":1,"id":"A6B0C134-72A9-472D-A6BC-9501CD3847CA","filename":"song1.mp3","conductor":"Conductor","subtitle":"SubTitle","artist":"Artist","sortComposer":"SortComposer","genre":"Genre","recordingYear":2020,"copyright":"Copyright"}
"""
        
        XCTAssertEqual(json, jsonRef)
        
        let single2 = Single.decodeFrom(json: jsonData)
        XCTAssertNotNil(single2)
        if let single2 = single2 {
            XCTAssertNil(single.disk)
            XCTAssertEqual(single.track,1)
            XCTAssertEqual(single.title, single2.title)
            XCTAssertEqual(single.subtitle, single2.subtitle)
            XCTAssertEqual(single.artist, single2.artist)
            XCTAssertEqual(single.composer, single2.composer)
            XCTAssertEqual(single.conductor, single2.conductor)
            XCTAssertEqual(single.orchestra, single2.orchestra)
            XCTAssertEqual(single.sortTitle, single2.sortTitle)
            XCTAssertEqual(single.sortArtist, single2.sortArtist)
            XCTAssertEqual(single.sortComposer, single2.sortComposer)
            XCTAssertEqual(single.supportingArtists, single2.supportingArtists)
            XCTAssertEqual(single.lyricist, single2.lyricist)
            XCTAssertEqual(single.genre, single2.genre)
            XCTAssertEqual(single.publisher, single2.publisher)
            XCTAssertEqual(single.copyright, single2.copyright)
            XCTAssertEqual(single.encodedBy, single2.encodedBy)
            XCTAssertEqual(single.encoderSettings, single2.encoderSettings)
            XCTAssertEqual(single.recordingYear, single2.recordingYear)
            XCTAssertEqual(single.duration, single2.duration)
            XCTAssertEqual(single.directory, single2.directory)
        }
    }
    
    func testAlbumFields() throws {
        let album = createAlbum(withContents: false, withArt: false)

        let jsonData = album.json ?? Data()
        let json = String(bytes: jsonData, encoding: String.Encoding.utf8) ?? ""
        let jsonRef =
"""
{"composer":"The Composer","publisher":"Publisher","title":"The Title","supportingArtists":"Artist1;Artist2;Artist3","lyricist":"Lyricist","orchestra":"Orchestra","directory":"Title\\/Artist","duration":1800,"encodedBy":"EncodedBy","sortTitle":"Title","sortArtist":"Artist","contents":[],"encoderSettings":"EncoderSettings","id":"1DFC13CC-BE33-4CED-96D9-CDC3508C6522","conductor":"Conductor","subtitle":"Subtitle","artist":"The Artist","sortComposer":"Composer","genre":"Genre","recordingYear":2020,"copyright":"Copyright"}
"""
                
        XCTAssertEqual(json, jsonRef)
        
        let album2 = Album.decodeFrom(json: jsonData)
        XCTAssertEqual(album.title, album2?.title)
        XCTAssertEqual(album.sortTitle, album2?.sortTitle)
        XCTAssertEqual(album.subtitle, album2?.subtitle)
        XCTAssertEqual(album.artist, album2?.artist)
        XCTAssertEqual(album.sortArtist, album2?.sortArtist)
        XCTAssertEqual(album.supportingArtists, album2?.supportingArtists)
        XCTAssertEqual(album.composer, album2?.composer)
        XCTAssertEqual(album.sortComposer, album2?.sortComposer)
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
    
    func testPlaylistFields() throws {
        let playlist = createPlaylist("60's rock")

        let jsonData = playlist.jsonp ?? Data()

        let playlist2 = Playlist.decodeFrom(json: jsonData)
        XCTAssertEqual(playlist.id, playlist2?.id)
        XCTAssertEqual(playlist.title, playlist2?.title)
        XCTAssertEqual(playlist.user, playlist2?.user)
        XCTAssertEqual(playlist.shared, playlist2?.shared)
        XCTAssertEqual(playlist.autoRepeat, playlist2?.autoRepeat)
        XCTAssertEqual(playlist.shuffle, playlist2?.shuffle)
        XCTAssertEqual(playlist.count, playlist2?.count)
        XCTAssertEqual(playlist.trackCount, playlist2?.trackCount)
        let items = playlist.items
        let items2 = playlist.items
        XCTAssertEqual(playlist.count, 2)
        XCTAssertEqual(playlist.trackCount, 10)
        for index in items.indices {
            let pl1 = items[index]
            let pl2 = items2[index]
            XCTAssertEqual(pl1.id, pl2.id)
            XCTAssertEqual(pl1.playlistType, pl2.playlistType)
            XCTAssertEqual(pl1.title, pl2.title)
            XCTAssertEqual(pl1.count, pl2.count)
            if let i1 = pl1.items,
               let i2 = pl2.items {
                XCTAssertEqual(pl1.count, 5)
                for idx in i1.indices {
                    let p1 = i1[idx]
                    let p2 = i2[idx]
                    XCTAssertEqual(p1.id, p2.id)
                    XCTAssertEqual(p1.playlistType, p2.playlistType)
                }

            }
        }
    }
    
    func testFields() throws {
        let album = createAlbum()

        let jsonData = album.jsonp ?? Data()

        let album2 = Album.decodeFrom(json: jsonData)
        XCTAssertEqual(album.title, album2?.title)
        XCTAssertEqual(album.sortTitle, album2?.sortTitle)
        XCTAssertEqual(album.subtitle, album2?.subtitle)
        XCTAssertEqual(album.artist, album2?.artist)
        XCTAssertEqual(album.sortArtist, album2?.sortArtist)
        XCTAssertEqual(album.supportingArtists, album2?.supportingArtists)
        XCTAssertEqual(album.composer, album2?.composer)
        XCTAssertEqual(album.sortComposer, album2?.sortComposer)
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

        let movementA = compositionA?.movements[0]
        let movementA2 = compositionA2?.movements[0]
        XCTAssertEqual(movementA?.title, movementA2?.title)
        XCTAssertEqual(movementA?.subtitle, movementA2?.subtitle)
        XCTAssertEqual(movementA?.duration, movementA2?.duration)
        XCTAssertEqual(movementA?.filename, movementA2?.filename)

        let contentA = album.contents[1]
        let contentA2 = album2?.contents[1]
        XCTAssertEqual(contentA.disk, contentA2?.disk)
        XCTAssertEqual(contentA.track, contentA2?.track)

        let singleA = contentA.single
        let singleA2 = contentA2?.single
        XCTAssertEqual(singleA?.title, singleA2?.title)
        XCTAssertEqual(singleA?.sortTitle, singleA2?.sortTitle)
        XCTAssertEqual(singleA?.subtitle, singleA2?.subtitle)
        XCTAssertEqual(singleA?.artist, singleA2?.artist)
        XCTAssertEqual(singleA?.sortArtist, singleA2?.sortArtist)
        XCTAssertEqual(singleA?.supportingArtists, singleA2?.supportingArtists)
        XCTAssertEqual(singleA?.composer, singleA2?.composer)
        XCTAssertEqual(singleA?.sortComposer, singleA2?.sortComposer)
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
        XCTAssertEqual(singleA?.filename, singleA2?.filename)
    }

    func testAlbumSummary() throws {
        var album = createAlbum(withContents: false, withArt: false)
        album.update()
        
        let albumSummary = AlbumSummary(album)
        
        XCTAssertEqual(albumSummary.id, album.id)
        XCTAssertEqual(albumSummary.title, album.title)
        XCTAssertEqual(albumSummary.sortTitle, album.sortTitle?.lowercased())
        XCTAssertEqual(albumSummary.artist, album.artist)
        XCTAssertEqual(albumSummary.sortArtist, album.sortArtist?.lowercased())
        XCTAssertEqual(albumSummary.composer, album.composer)
        XCTAssertEqual(albumSummary.sortComposer, album.sortComposer?.lowercased())
        XCTAssertEqual(albumSummary.genre, album.genre)
        XCTAssertEqual(albumSummary.recordingYear, album.recordingYear)
        XCTAssertEqual(albumSummary.frontArtFilename,album.frontArtRef()?.filename)
    }
    
    func testAlbumSummaryUpdate() throws {
        let album = createAlbum(withContents: false, withArt: false)
        
        var albumSummary = AlbumSummary(album)
        albumSummary.title = "A New Title"
        albumSummary.artist = "The Beatles"
        albumSummary.composer = "Ludwig van Beethoven (1789-1823)"
        albumSummary.update()
        
        XCTAssertEqual(albumSummary.sortTitle, "new title")
        XCTAssertEqual(albumSummary.sortArtist, "beatles")
        XCTAssertEqual(albumSummary.sortComposer, "beethoven, ludwig van")

    }
    
    func testCompositionSummary() throws {
        var album = createAlbum()
        album.update()
        
        let composition = album.contents[0].composition!
        
        let compositionSummary = CompositionSummary(composition)
        
        XCTAssertEqual(compositionSummary.id, composition.id)
        XCTAssertEqual(compositionSummary.albumId, album.id)
        XCTAssertEqual(compositionSummary.title, composition.title)
        XCTAssertEqual(compositionSummary.sortTitle, composition.sortTitle)
        XCTAssertEqual(compositionSummary.artist, composition.artist)
        XCTAssertEqual(compositionSummary.sortArtist, composition.sortArtist)
        XCTAssertEqual(compositionSummary.composer, composition.composer)
        XCTAssertEqual(compositionSummary.sortComposer, composition.sortComposer)
        XCTAssertEqual(compositionSummary.genre, composition.genre)
        
    }
    
    func testCompositionSummaryUpdate() throws {
        let composition = createComposition()
        
        var compositionSummary = CompositionSummary(composition)
        compositionSummary.title = "A New Title"
        compositionSummary.artist = "The Doors"
        compositionSummary.composer = "Ludwig van Beethoven(1020-3829)"
        compositionSummary.update()
        
        XCTAssertEqual(compositionSummary.sortTitle, "new title")
        XCTAssertEqual(compositionSummary.sortArtist, "doors")
        XCTAssertEqual(compositionSummary.sortComposer, "beethoven, ludwig van")
        
    }
    
    func testSingleSummary() throws {
        var album = createAlbum()
        album.update()
        
        let single = album.contents[1].single!
        
        let singleListItem = SingleSummary(single)
        
        XCTAssertEqual(singleListItem.id, single.id)
        XCTAssertEqual(singleListItem.albumId, album.id)
        XCTAssertEqual(singleListItem.title, single.title)
        XCTAssertEqual(singleListItem.sortTitle, single.sortTitle)
        XCTAssertEqual(singleListItem.artist, single.artist)
        XCTAssertEqual(singleListItem.sortArtist, single.sortArtist)
        XCTAssertEqual(singleListItem.composer, single.composer)
        XCTAssertEqual(singleListItem.sortComposer, single.sortComposer)
        XCTAssertEqual(singleListItem.genre, single.genre)

    }
    
    func testSingleSummaryUpdate() throws {
        let single = createSingle(track: 1, title: "An apple a day", filename: "apple.flac")
        
        var singleListItem = SingleSummary(single)
        singleListItem.title = "an apricot a week"
        singleListItem.artist = "The Strawberry AlarmClock"
        singleListItem.composer = "John Lennon"
        singleListItem.update()
        
        XCTAssertEqual(singleListItem.sortTitle, "apricot a week")
        XCTAssertEqual(singleListItem.sortArtist, "alarmclock, strawberry")
        XCTAssertEqual(singleListItem.sortComposer, "lennon, john")
    }
    
    func testPlaylistSummary() throws {
        let playlist = createPlaylist("The Good Stuff")

        let playlistSummary = PlaylistSummary(playlist)

        XCTAssertEqual(playlistSummary.id, playlist.id)
        XCTAssertEqual(playlistSummary.title, playlist.title)

    }
    
    static var allTests = [
        ("testAlbumFields", testAlbumFields),
        ("testSingleFields", testSingleFields),
        ("testPlaylistFields", testPlaylistFields),
        ("testFields", testFields),
        ("testAlbumSummary", testAlbumSummary),
        ("testAlbumSummaryUpdate", testAlbumSummaryUpdate),
        ("testCompositionSummary", testCompositionSummary),
        ("testCompositionSummaryUpdate", testCompositionSummaryUpdate),
        ("testSingleSummary", testSingleSummary),
        ("testSingleSummaryUpdate", testSingleSummaryUpdate),
        ("testPlaylistSummary", testPlaylistSummary),
    ]
}
