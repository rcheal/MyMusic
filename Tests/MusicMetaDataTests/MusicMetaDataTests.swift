import XCTest
@testable import MusicMetaData

struct Resource {
    let url: URL
    let baseURL: URL
    
    init(relativePath: String, sourceFile: StaticString = #file) throws {
        
        let testCaseURL = URL(fileURLWithPath: "\(sourceFile)", isDirectory: false)
        let testFolderURL = testCaseURL.deletingLastPathComponent()
        baseURL = testFolderURL.deletingLastPathComponent().appendingPathComponent("Resources", isDirectory: true)
        
        self.url = URL(fileURLWithPath: relativePath, relativeTo: baseURL)
    }
}

private func checkMetadataInt(type: MetadataType, item: MetadataItem?, value expectedValue: Int) {
    XCTAssertNotNil(item, "\(type) is nil")
    if let block = item, let v = block.contentsInt {
        XCTAssertEqual(v,expectedValue)
    } else {
        XCTAssert(false,"\(type) nil or not an int")
    }
}

private func checkMetadataString(type: MetadataType, item: MetadataItem?, value expectedValue: String) {
    XCTAssertNotNil(item, "\(type) is nil")
    if let block = item, let v = block.contentsString {
            XCTAssertEqual(v,expectedValue)
    } else {
        XCTAssert(false,"\(type) is nil or not a string")
    }
}

@available(OSX 11.0, *)
final class FlacExtractorTests: XCTestCase {
    func testExtractTags1() throws {
        let fname = "schubert_symphony_no_9/symphony_no9_in_c_d944_i_andante__allegro_ma_non_troppo.flac"
        let expectedAlbum = "Symphony in C major No. 9"
        let expectedArtist = "Mackerras, Orchestra of the Age of Enlightenment"
        let expectedComposer = "Schubert, Franz (1797-1828)"
        let expectedGenre = "Classical"
        let expectedYear = 1987
        let expectedTrack = 1
        let expectedTitle = "I- Andante - Allegro ma non troppo"
        let expectedDuration = 986

        let file = try Resource(relativePath: fname)
        var extractor = FlacExtractor(file: fname, relativeTo: file.baseURL)
        
        XCTAssertEqual(extractor.relativeFilename, fname)
        
        let result = extractor.extractTags()
        
        XCTAssertTrue(result.0)
        
        let albumBlock = extractor.getDataItem(.album)
        checkMetadataString(type: .album, item: albumBlock, value: expectedAlbum)
        
        let artistBlock = extractor.getDataItem(.artist)
        checkMetadataString(type: .artist, item: artistBlock, value: expectedArtist)
        
        let composerBlock = extractor.getDataItem(.composer)
        checkMetadataString(type: .composer, item: composerBlock, value: expectedComposer)
        
        let genreBlock = extractor.getDataItem(.genre)
        checkMetadataString(type: .genre, item: genreBlock, value: expectedGenre)
        
        let yearBlock = extractor.getDataItem(.recordingYear)
        checkMetadataInt(type: .recordingYear, item: yearBlock, value: expectedYear)
        
        let trackBlock = extractor.getDataItem(.track)
        checkMetadataInt(type: .track, item: trackBlock, value: expectedTrack)
        
        let titleBlock = extractor.getDataItem(.title)
        checkMetadataString(type: .title, item: titleBlock, value: expectedTitle)
        
        let durationBlock = extractor.getDataItem(.duration)
        checkMetadataInt(type: .duration, item: durationBlock, value: expectedDuration)
        
    }

    func testExtractTags2() throws {
        let fname = "schubert_symphony_no_9/symphony_no9_in_c_d944_ii__andante_con_moto.flac"
        let expectedAlbum = "Symphony in C major No. 9"
        let expectedArtist = "Mackerras, Orchestra of the Age of Enlightenment"
        let expectedComposer = "Schubert, Franz (1797-1828)"
        let expectedGenre = "Classical"
        let expectedYear = 1987
        let expectedTrack = 2
        let expectedTitle = "II-  Andante con moto"
        let expectedDuration = 841
 
        let file = try Resource(relativePath: fname)
        var extractor = FlacExtractor(file: fname, relativeTo: file.baseURL)
        
        XCTAssertEqual(extractor.relativeFilename, fname)
        
        let result = extractor.extractTags()
        
        XCTAssertTrue(result.0)
        
        let albumBlock = extractor.getDataItem(.album)
        checkMetadataString(type: .album, item: albumBlock, value: expectedAlbum)
        
        let artistBlock = extractor.getDataItem(.artist)
        checkMetadataString(type: .artist, item: artistBlock, value: expectedArtist)
        
        let composerBlock = extractor.getDataItem(.composer)
        checkMetadataString(type: .composer, item: composerBlock, value: expectedComposer)
        
        let genreBlock = extractor.getDataItem(.genre)
        checkMetadataString(type: .genre, item: genreBlock, value: expectedGenre)
        
        let yearBlock = extractor.getDataItem(.recordingYear)
        checkMetadataInt(type: .recordingYear, item: yearBlock, value: expectedYear)
        
        let trackBlock = extractor.getDataItem(.track)
        checkMetadataInt(type: .track, item: trackBlock, value: expectedTrack)
        
        let titleBlock = extractor.getDataItem(.title)
        checkMetadataString(type: .title, item: titleBlock, value: expectedTitle)
        
        let durationBlock = extractor.getDataItem(.duration)
        checkMetadataInt(type: .duration, item: durationBlock, value: expectedDuration)

    }

    func testExtractTags3() throws {
        let fname = "blue/01 Moanin'.mp3"
        let expectedAlbum = "In Blue"
        let expectedArtist = "Karrin Allyson"
        let expectedComposer = "Bobby Timmons/Jon Hendricks/Laura Caviani"
        let expectedGenre = "Jazz"
        let expectedYear = 2002
        let expectedTrack = 1
        let expectedTitle = ""
        let expectedDuration = 0
 
        let file = try Resource(relativePath: fname)
        var extractor = ID3Extractor(file: fname, relativeTo: file.baseURL)
        
        XCTAssertEqual(extractor.relativeFilename, fname)
        
        let result = extractor.extractTags()
        
        XCTAssertTrue(result.0)
        
        let albumBlock = extractor.getDataItem(.album)
        checkMetadataString(type: .album, item: albumBlock, value: expectedAlbum)
        
        let artistBlock = extractor.getDataItem(.artist)
        checkMetadataString(type: .artist, item: artistBlock, value: expectedArtist)
        
        let composerBlock = extractor.getDataItem(.composer)
        checkMetadataString(type: .composer, item: composerBlock, value: expectedComposer)
        
        let genreBlock = extractor.getDataItem(.genre)
        checkMetadataString(type: .genre, item: genreBlock, value: expectedGenre)
        
        let yearBlock = extractor.getDataItem(.recordingYear)
        checkMetadataInt(type: .recordingYear, item: yearBlock, value: expectedYear)
        
        let trackBlock = extractor.getDataItem(.track)
        checkMetadataInt(type: .track, item: trackBlock, value: expectedTrack)
        
        if let titleBlock = extractor.getDataItem(.title) {
            checkMetadataString(type: .title, item: titleBlock, value: expectedTitle)
        }
        
        if let durationBlock = extractor.getDataItem(.duration) {
            checkMetadataInt(type: .duration, item: durationBlock, value: expectedDuration)
        }

    }

}
final class MusicMetaDataTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(MusicMetaData().text, "Hello, World!")
      
        let file = try Resource(relativePath: "schubert_symphony_no_9/symphony_no9_in_c_d944_i_andante__allegro_ma_non_troppo.flac")
        
        let found = try file.url.checkPromisedItemIsReachable()
        
        XCTAssertTrue(found)
//        let s = try! String(contentsOf: url, encoding: .utf8)
        
//        XCTAssertTrue(exists, "\(url.absoluteString)")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
