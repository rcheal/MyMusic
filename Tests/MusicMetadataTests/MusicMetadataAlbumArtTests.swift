//
//  MusicMetadataAlbumArtTests.swift
//  
//
//  Created by Robert Cheal on 12/7/20.
//

import XCTest
@testable import MusicMetadata


@available(OSX 11.0, *)
final class MusicMetadataAlbumArtTests: XCTestCase {

    func testAlbumArtRef() throws {
        
        let ref1 = AlbumArtRef(type: .front, format: .png)
        XCTAssertEqual(ref1.filename, "front.png")

        let ref2 = AlbumArtRef(type: .back, format: .jpg)
        XCTAssertEqual(ref2.filename, "back.jpg")
        
        let ref3 = AlbumArtRef(type: .page, format: .png)
        XCTAssertEqual(ref3.filename, "page0.png")
        
    }
    
    func testValidAddArt1() throws {
        
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        albumArt.addArt(AlbumArtRef(type: .back, format: .jpg))
        albumArt.addArt(AlbumArtRef(type: .page, format: .jpg))
        albumArt.addArt(AlbumArtRef(type: .front, format: .png))
        
        XCTAssertEqual(albumArt.count, 4)
        XCTAssertEqual(albumArt.pageCount, 2)
        
        let front = albumArt.frontArtRef()
        XCTAssertEqual(front?.filename, "front.png")
        
        let back = albumArt.backArtRef()
        XCTAssertEqual(back?.filename, "back.jpg")
        
        let page1 = albumArt.pageArtRef(1)
        XCTAssertEqual(page1?.filename, "page1.png")
        
        let page2 = albumArt.pageArtRef(2)
        XCTAssertEqual(page2?.filename, "page2.jpg")

    }

    func testValidAddArt2() throws {
        
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        albumArt.addArt(AlbumArtRef(type: .front, format: .jpg))
        albumArt.addArt(AlbumArtRef(type: .page, format: .jpg))
        albumArt.addArt(AlbumArtRef(type: .back, format: .png))
        
        XCTAssertEqual(albumArt.count, 4)
        XCTAssertEqual(albumArt.pageCount, 2)
        
        let front = albumArt.frontArtRef()
        XCTAssertEqual(front?.filename, "front.jpg")
        
        let back = albumArt.backArtRef()
        XCTAssertEqual(back?.filename, "back.png")
        
        let page1 = albumArt.pageArtRef(1)
        XCTAssertEqual(page1?.filename, "page1.png")
        
        let page2 = albumArt.pageArtRef(2)
        XCTAssertEqual(page2?.filename, "page2.jpg")

    }
    
    func testInvalidAddArt() throws {
        
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .front, format: .png))
        albumArt.addArt(AlbumArtRef(type: .back, format: .png))

        // Invalid adds
        albumArt.addArt(AlbumArtRef(type: .front, format: .jpg))
        albumArt.addArt(AlbumArtRef(type: .back, format: .jpg))
        
        XCTAssertEqual(albumArt.count, 2)
        XCTAssertEqual(albumArt.pageCount, 0)
        
        let front = albumArt.frontArtRef()
        XCTAssertEqual(front?.filename, "front.png")
        let back = albumArt.backArtRef()
        XCTAssertEqual(back?.filename, "back.png")
        
    }
    
    func testInvalidPageSeq() throws {
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .front, format: .png))
        albumArt.addArt(AlbumArtRef(type: .back, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        
        let page0 = albumArt.pageArtRef(0)
        let page3 = albumArt.pageArtRef(3)
        
        XCTAssertNil(page0)
        XCTAssertNil(page3)
    }
    
    func testRemoveAll() throws {
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .front, format: .png))
        albumArt.addArt(AlbumArtRef(type: .back, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        
        albumArt.removeAll()
        
        XCTAssertEqual(albumArt.count, 0)
        XCTAssertEqual(albumArt.pageCount, 0)
        
        let front = albumArt.frontArtRef()
        let back = albumArt.backArtRef()
        let page1 = albumArt.pageArtRef(1)
        let page2 = albumArt.pageArtRef(2)
        
        XCTAssertNil(front)
        XCTAssertNil(back)
        XCTAssertNil(page1)
        XCTAssertNil(page2)

    }

    func testRemoveBack() throws {
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .front, format: .png))
        albumArt.addArt(AlbumArtRef(type: .back, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        
        albumArt.removeBack()
        
        XCTAssertEqual(albumArt.count, 3)
        XCTAssertEqual(albumArt.pageCount, 2)
        
        let front = albumArt.frontArtRef()
        let back = albumArt.backArtRef()
        let page1 = albumArt.pageArtRef(1)
        let page2 = albumArt.pageArtRef(2)
        
        XCTAssertEqual(front?.filename, "front.png")
        XCTAssertNil(back)
        XCTAssertEqual(page1?.filename, "page1.png")
        XCTAssertEqual(page2?.filename, "page2.png")

    }

    func testRemoveFront() throws {
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .front, format: .png))
        albumArt.addArt(AlbumArtRef(type: .back, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        

        albumArt.removeFront()
            
        
        XCTAssertEqual(albumArt.count, 3)
        XCTAssertEqual(albumArt.pageCount, 2)
        
        let front = albumArt.frontArtRef()
        let back = albumArt.backArtRef()
        let page1 = albumArt.pageArtRef(1)
        let page2 = albumArt.pageArtRef(2)
        
        XCTAssertNil(front)
        XCTAssertEqual(back?.filename, "back.png")
        XCTAssertEqual(page1?.filename, "page1.png")
        XCTAssertEqual(page2?.filename, "page2.png")

    }

    func testRemovePages() throws {
        var albumArt = AlbumArtwork()
        
        albumArt.addArt(AlbumArtRef(type: .front, format: .png))
        albumArt.addArt(AlbumArtRef(type: .back, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        albumArt.addArt(AlbumArtRef(type: .page, format: .png))
        
        albumArt.removePages()
        
        XCTAssertEqual(albumArt.count, 2)
        XCTAssertEqual(albumArt.pageCount, 0)
        
        let front = albumArt.frontArtRef()
        let back = albumArt.backArtRef()
        let page1 = albumArt.pageArtRef(1)
        let page2 = albumArt.pageArtRef(2)
        
        XCTAssertEqual(front?.filename, "front.png")
        XCTAssertEqual(back?.filename, "back.png")
        XCTAssertNil(page1)
        XCTAssertNil(page2)

    }

    func testAlbumRemoveAllArt() throws {
        var album = Album(title: "Test Album")
        
        album.addArt(AlbumArtRef(type: .front, format: .png))
        album.addArt(AlbumArtRef(type: .back, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        
        album.removeAllArt()
        
        XCTAssertEqual(album.albumArt.count, 0)
        XCTAssertEqual(album.albumArt.pageCount, 0)
        
        let front = album.frontArtRef()
        let back = album.backArtRef()
        let page1 = album.pageArtRef(1)
        let page2 = album.pageArtRef(2)
        
        XCTAssertNil(front)
        XCTAssertNil(back)
        XCTAssertNil(page1)
        XCTAssertNil(page2)

    }
    
    func testAlbumRemoveBack() throws {
        var album = Album(title: "Test Album")
        album.addArt(AlbumArtRef(type: .front, format: .png))
        album.addArt(AlbumArtRef(type: .back, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        

        
        album.removeBackArt()
        
        XCTAssertEqual(album.albumArt.count, 3)
        XCTAssertEqual(album.albumArt.pageCount, 2)
        
        let front = album.frontArtRef()
        let back = album.backArtRef()
        let page1 = album.pageArtRef(1)
        let page2 = album.pageArtRef(2)
        
        XCTAssertEqual(front?.filename, "front.png")
        XCTAssertNil(back)
        XCTAssertEqual(page1?.filename, "page1.png")
        XCTAssertEqual(page2?.filename, "page2.png")

    }

    func testAlbumRemoveFront() throws {
        var album = Album(title: "Test Album")
        
        album.addArt(AlbumArtRef(type: .front, format: .png))
        album.addArt(AlbumArtRef(type: .back, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        

        album.removeFrontArt()
            
        
        XCTAssertEqual(album.albumArt.count, 3)
        XCTAssertEqual(album.albumArt.pageCount, 2)
        
        let front = album.frontArtRef()
        let back = album.backArtRef()
        let page1 = album.pageArtRef(1)
        let page2 = album.pageArtRef(2)
        
        XCTAssertNil(front)
        XCTAssertEqual(back?.filename, "back.png")
        XCTAssertEqual(page1?.filename, "page1.png")
        XCTAssertEqual(page2?.filename, "page2.png")

    }

    func testAlbumRemovePages() throws {
        var album = Album(title: "Test Album")
        
        album.addArt(AlbumArtRef(type: .front, format: .png))
        album.addArt(AlbumArtRef(type: .back, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        album.addArt(AlbumArtRef(type: .page, format: .png))
        
        album.removePagesArt()
        
        XCTAssertEqual(album.albumArt.count, 2)
        XCTAssertEqual(album.albumArt.pageCount, 0)
        
        let front = album.frontArtRef()
        let back = album.backArtRef()
        let page1 = album.pageArtRef(1)
        let page2 = album.pageArtRef(2)
        
        XCTAssertEqual(front?.filename, "front.png")
        XCTAssertEqual(back?.filename, "back.png")
        XCTAssertNil(page1)
        XCTAssertNil(page2)

    }

    static var allTests = [
        ("testAlbumArtRef", testAlbumArtRef),
        ("testValidAddArt1", testValidAddArt1),
        ("testValidAddArt2", testValidAddArt2),
        ("testInvalidAddArt", testInvalidAddArt),
        ("testInbalidPageSeq", testInvalidPageSeq),
        ("testRemoveAll", testRemoveAll),
        ("testRemoveFront", testRemoveFront),
        ("testRemoveBack", testRemoveBack),
        ("testRemovePages", testRemovePages),
        ("testAlbumRemoveAllArt", testAlbumRemoveAllArt),
        ("testAlbumRemoveBack", testAlbumRemoveBack),
        ("testAlbumRemoveFront", testAlbumRemoveFront),
        ("testAlbumRemovePages", testAlbumRemovePages),
    ]
}
