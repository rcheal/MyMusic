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
final class AudioFileExtractorTests: XCTestCase {
    func testExtractTags1() throws {
        let fname = "Schubert/Symphony_in_C_major_No__9/i_andante__allegro_ma_non_troppo.flac"
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
        
        XCTAssertTrue(result.0, result.1)
        
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
        let fname = "Schubert/Symphony_in_C_major_No__9/ii__andante_con_moto.flac"
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
        
        XCTAssertTrue(result.0, result.1)
        
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
        let fname = "Karrin Allyson/In Blue/01 Moanin'.mp3"
        let expectedAlbum = "In Blue"
        let expectedArtist = "Karrin Allyson"
        let expectedComposer = "Bobby Timmons/Jon Hendricks/Laura Caviani"
        let expectedGenre = "Jazz"
        let expectedYear = 2002
        let expectedTrack = 1
        let expectedTitle = "Moanin'"
        let expectedDuration = 362
 
        let file = try Resource(relativePath: fname)
        var extractor = ID3Extractor(file: fname, relativeTo: file.baseURL)
        
        XCTAssertEqual(extractor.relativeFilename, fname)
        
        let result = extractor.extractTags()
        
        XCTAssertTrue(result.0, result.1)
        
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
    static var allTests = [
        ("testExtractTags1", testExtractTags1),
        ("testExtractTags2", testExtractTags2),
        ("testExtractTags3", testExtractTags3),
    ]
}


@available(OSX 11.0, *)
final class MetadataExtractorTests: XCTestCase {
    func testMetadataExtractTags1() throws {
        let dname = "Schubert/Symphony_in_C_major_No__9"
        let expectedAlbum = "Symphony in C major No. 9"
        let expectedArtist = "Mackerras, Orchestra of the Age of Enlightenment"
        let expectedComposer = "Schubert, Franz (1797-1828)"
        let expectedGenre = "Classical"
        let expectedYear = 1987
        var expectedTitle: [Int: String] = [:]
        expectedTitle[1] = "I- Andante - Allegro ma non troppo"
        expectedTitle[2] = "II-  Andante con moto"
        expectedTitle[3] = "III- Scherzo (Allegro vivace) & Trio"
        expectedTitle[4] = "IV- Finale (Allegro vivace)"
        var expectedDuration: [Int: Int] = [:]
        expectedDuration[1] = 986
        expectedDuration[2] = 841
        expectedDuration[3] = 820
        expectedDuration[4] = 922
        var expectedFilename: [Int: String] = [:]
        expectedFilename[1] = "Schubert/Symphony_in_C_major_No__9/i_andante__allegro_ma_non_troppo.flac"
        expectedFilename[2] = "Schubert/Symphony_in_C_major_No__9/ii__andante_con_moto.flac"
        expectedFilename[3] = "Schubert/Symphony_in_C_major_No__9/iii_scherzo_allegro_vivace__trio.flac"
        expectedFilename[4] = "Schubert/Symphony_in_C_major_No__9/iv_finale_allegro_vivace.flac"
        
        let directory = try Resource(relativePath: dname)
        var metadataExtractor = MusicMetaData.MetadataExtractor(dir: dname, relativeTo: directory.baseURL)
        
        metadataExtractor.getAudioFiles()
    
        let album = metadataExtractor.getAlbum()
        
        XCTAssertNotNil(album, "Album is nil")
        if let album = album {
            XCTAssertEqual(album.title, expectedAlbum)
            XCTAssertEqual(album.artist ?? "nil", expectedArtist)
            XCTAssertEqual(album.composer ?? "nil", expectedComposer)
            XCTAssertEqual(album.genre ?? "nil", expectedGenre)
            XCTAssertEqual(album.recordingYear ?? 0, expectedYear)

            for child in album.contents {
                let track = child.track
                if (1...4).contains(track) {
                    XCTAssertEqual(child.single?.title, expectedTitle[track])
                    XCTAssertEqual(child.single?.duration, expectedDuration[track])
                    XCTAssertEqual(child.single?.audiofileRef, expectedFilename[track])
                }
                
            }

            let json = metadataExtractor.getJSON(from: album, pretty:  true)
            XCTAssertNotNil(json, "JSON is nil")
           
            if let json = json {
                let value = String(data: json, encoding: .utf8) ?? ""
                print(value)
            }
        }
            
            
    }
    
    func testMetadataExtractTags2() throws {
        let dname = "Karrin Allyson/In Blue"
        let expectedAlbum = "In Blue"
        let expectedArtist = "Karrin Allyson"
        let expectedComposer = "nil"
        let expectedGenre = "Jazz"
        let expectedYear = 2002
        var expectedTitle: [Int: String] = [:]
        expectedTitle[1] = "Moanin'"
        expectedTitle[2] = "Everybody's Cryin' Mercy"
        expectedTitle[3] = "Long as You're Livin'"
        expectedTitle[4] = "The Meaning of the Blues"
        expectedTitle[5] = "The Bluebird"
        expectedTitle[6] = "Hum Drum Blues"
        expectedTitle[7] = "How Long Has This Been Going On?"
        expectedTitle[8] = "West Coast Blues"
        expectedTitle[9] = "Evil Gal Blues"
        expectedTitle[10] = "Blue Motel Room"
        expectedTitle[11] = "Bye Bye Country Boy"
        expectedTitle[12] = "Love Me Like a Man"
        expectedTitle[13] = "Angel Eyes"
        var expectedDuration: [Int: Int] = [:]
        expectedDuration[1] = 362
        expectedDuration[2] = 237
        expectedDuration[3] = 275
        expectedDuration[4] = 455
        expectedDuration[5] = 271
        expectedDuration[6] = 340
        expectedDuration[7] = 341
        expectedDuration[8] = 302
        expectedDuration[9] = 253
        expectedDuration[10] = 363
        expectedDuration[11] = 251
        expectedDuration[12] = 260
        expectedDuration[13] = 289
        var expectedFilename: [Int: String] = [:]
        expectedFilename[1] = "Karrin Allyson/In Blue/01 Moanin'.mp3"
        expectedFilename[2] = "Karrin Allyson/In Blue/02 Everybody's Cryin' Mercy.mp3"
        expectedFilename[3] = "Karrin Allyson/In Blue/03 Long as You're Livin'.mp3"
        expectedFilename[4] = "Karrin Allyson/In Blue/04 The Meaning of the Blues.mp3"
        expectedFilename[5] = "Karrin Allyson/In Blue/05 The Bluebird.mp3"
        expectedFilename[6] = "Karrin Allyson/In Blue/06 Hum Drum Blues.mp3"
        expectedFilename[7] = "Karrin Allyson/In Blue/07 How Long Has This Been Going On_.mp3"
        expectedFilename[8] = "Karrin Allyson/In Blue/08 West Coast Blues.mp3"
        expectedFilename[9] = "Karrin Allyson/In Blue/09 Evil Gal Blues.mp3"
        expectedFilename[10] = "Karrin Allyson/In Blue/10 Blue Motel Room.mp3"
        expectedFilename[11] = "Karrin Allyson/In Blue/11 Bye Bye Country Boy.mp3"
        expectedFilename[12] = "Karrin Allyson/In Blue/12 Love Me Like a Man.mp3"
        expectedFilename[13] = "Karrin Allyson/In Blue/13 Angel Eyes.mp3"

        let directory = try Resource(relativePath: dname)
        var metadataExtractor = MusicMetaData.MetadataExtractor(dir: dname, relativeTo: directory.baseURL)
        
        metadataExtractor.getAudioFiles()
    
        let album = metadataExtractor.getAlbum()
        
        XCTAssertNotNil(album, "Album is nil")
        if let album = album {
            XCTAssertEqual(album.title, expectedAlbum)
            XCTAssertEqual(album.artist ?? "nil", expectedArtist)
            XCTAssertEqual(album.composer ?? "nil", expectedComposer)
            XCTAssertEqual(album.genre ?? "nil", expectedGenre)
            XCTAssertEqual(album.recordingYear ?? 0, expectedYear)

            for child in album.contents {
                let track = child.track
                if (1...13).contains(track) {
                    XCTAssertEqual(child.single?.title, expectedTitle[track])
                    XCTAssertEqual(child.single?.duration, expectedDuration[track], "track \(track)")
                    XCTAssertEqual(child.single?.audiofileRef, expectedFilename[track])
                }
                
            }

            let json = metadataExtractor.getJSON(from: album, pretty:  true)
            XCTAssertNotNil(json, "JSON is nil")
           
            if let json = json {
                let value = String(data: json, encoding: .utf8) ?? ""
                print(value)
            }
        }
            
            
    }
    
    func testMetadataExtractTags3() throws {
        let dname = "Mozart/Clarinet Concerto"
        let expectedAlbum = "Clarinet Concerto in A, K622"
        let expectedArtist = "Emma Johnson - English Chamber Orchestra"
        let expectedComposer = "Mozart, Wolfgang Amadeus (1756-1791)"
        let expectedGenre = "Classical"
        let expectedYear = 1985
        let expectedComposition = ["Clarinet Concerto in A, K622","Flute & Harp Concerto in C, K299"]
        let expectedStartTrack = [1,1]
        var expectedDuration: [Int: Int] = [:]
        expectedDuration[1] = 758
        expectedDuration[2] = 457
        expectedDuration[3] = 508
        expectedDuration[101] = 613
        expectedDuration[102] = 474
        expectedDuration[103] = 527
        var expectedTitle: [Int: String] = [:]
        expectedTitle[1] = "I. Allegro"
        expectedTitle[2] = "II. Adagio"
        expectedTitle[3] = "III. Rondo. Allegro"
        expectedTitle[101] = "I. Allegro"
        expectedTitle[102] = "II. Andantino"
        expectedTitle[103] = "III. Rondo. Allegro"

        var expectedFilename: [Int: String] = [:]
        expectedFilename[1] = "Mozart/Clarinet Concerto/first_movement__allegro__concerto_for_clarinet_and_orchestra_in_a_k622.flac"
        expectedFilename[2] = "Mozart/Clarinet Concerto/second_movement__adagio__concerto_for_clarinet_and_orchestra_in_a_k622.flac"
        expectedFilename[3] = "Mozart/Clarinet Concerto/third_movement__rondo_allegro__concerto_for_clarinet_and_orchestrain_a_k622.flac"
        expectedFilename[101] = "Mozart/Clarinet Concerto/first_movement__allegro__concerto_for_flute_harp_and_orchestra_in_c_k299.flac"
        expectedFilename[102] = "Mozart/Clarinet Concerto/second_movement__andantino__concerto_for_flute_harp_and_orchestra_in_c_k299.flac"
        expectedFilename[103] = "Mozart/Clarinet Concerto/third_movement__rondo_allegro__concerto_for_flute_harp_and_orchestra_in_c_k299.flac"

        let directory = try Resource(relativePath: dname)
        var metadataExtractor = MusicMetaData.MetadataExtractor(dir: dname, relativeTo: directory.baseURL)
        
        metadataExtractor.getAudioFiles()
    
        let album = metadataExtractor.getAlbum()
        XCTAssertNotNil(album, "Album is nil")
        
        if let album = album {
//            if let json = metadataExtractor.getJSON(from: album, pretty: true) {
//                metadataExtractor.printJSON(from: json)
//            }
        
            XCTAssertEqual(album.title, expectedAlbum)
            XCTAssertEqual(album.artist ?? "nil", expectedArtist)
            XCTAssertEqual(album.composer ?? "nil", expectedComposer)
            XCTAssertEqual(album.genre ?? "nil", expectedGenre)
            XCTAssertEqual(album.recordingYear ?? 0, expectedYear)


            for index in album.contents.indices {
                let child = album.contents[index]
                if let composition = child.composition {
                    XCTAssertEqual(composition.title, expectedComposition[index])
                    XCTAssertEqual(composition.startTrack, expectedStartTrack[index])
                    
                    for single in composition.contents {
                        let track = single.track
                        if (1...3).contains(track) {
                            XCTAssertEqual(single.title, expectedTitle[index*100+track])
                            XCTAssertEqual(single.duration, expectedDuration[index*100+track])
                            XCTAssertEqual(single.audiofileRef, expectedFilename[index*100+track])
                        } else {
                            XCTAssert(true, "Extra track - \(track)")
                        }
                    }
                } else if let single = child.single {
                    XCTAssert(false, "Unexpected single audiofile found: \(single.title)")
                }
            }

            let json = metadataExtractor.getJSON(from: album, pretty:  true)
            XCTAssertNotNil(json, "JSON is nil")
           
            if let json = json {
                let value = String(data: json, encoding: .utf8) ?? ""
                print(value)
            }
        }
            
            
    }
    
    static var allTests = [
        ("testMetadataExtractTags1", testMetadataExtractTags1),
        ("testMetadataExtractTags2", testMetadataExtractTags2),
        ("testMetadataExtractTags2", testMetadataExtractTags3),
    ]
}
