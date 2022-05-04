import XCTest
import Combine
@testable import MyMusicAPI
@testable import MusicMetadata

let defaultServerURL = "http://127.0.0.1:8888"

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

final class MyMusicAPITests: XCTestCase {
    
    var api: MyMusicAPI!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        api = MyMusicAPI.shared
        api.serverURL = defaultServerURL
    }
    
    override func tearDown() {
        subscriptions = []
    }
    
    func getAlbumURL(title: String, composer: String) -> URL {
        let fileRootURL = try! Resource(relativePath: "music").url
        api.fileRootURL = fileRootURL
        return fileRootURL.appendingPathComponent(composer)
            .appendingPathComponent(title)
    }
    
    func getAlbum(title: String, composer: String) -> Album {
        let jsonFileURL = getAlbumURL(title: title, composer: composer)
            .appendingPathComponent("album.json")
        
        let json = FileManager.default.contents(atPath: jsonFileURL.path)!
        
        return try! JSONDecoder().decode(Album.self, from: json)

    }
    
    func createAlbum(title: String, composer: String) async throws -> Album {
    
        let album = getAlbum(title: title, composer: composer)

        let _ = try await api.post(album: album)

        return album
    }
    
    func deleteAlbum(_ id: String) async throws {

        let _ = try await api.delete(albumId: id)
        
    }
    
    func getSingleURL(genre: String, artist: String) -> URL {
        let fileRootURL = try! Resource(relativePath: "music").url
        api.fileRootURL = fileRootURL
        return fileRootURL.appendingPathComponent("singles")
            .appendingPathComponent(genre)
            .appendingPathComponent(artist)
    }
    
    func getSingle(genre: String, artist: String, jsonFilename: String? = nil) -> Single {
        let filename = jsonFilename ?? "single.json"
        let jsonFileURL = getSingleURL(genre: genre, artist: artist)
            .appendingPathComponent(filename)
        
        let json = FileManager.default.contents(atPath: jsonFileURL.path)!
        
        return try! JSONDecoder().decode(Single.self, from: json)

    }
    
    func createSingle(genre: String, artist: String, jsonFilename: String? = nil) async throws -> Single {
        let filename = jsonFilename ?? "single.json"

        let single = getSingle(genre: genre, artist: artist, jsonFilename: filename)

        let _ = try await api.post(single: single)

        return single
    }
    
//    func createSingleFile(single: Single, filename: String) throws {
//
//        let publisher = try api.postSingleFile(single, filename: filename)
//        let expectation = self.expectation(description: #function)
//
//        publisher
//            .sink(
//                receiveCompletion: { _ in expectation.fulfill() },
//                receiveValue: { _ in })
//            .store(in: &subscriptions)
//
//        waitForExpectations(timeout: 2, handler: nil)
//    }
//
    func deleteSingle(_ id: String) async throws {

        let _ = try await api.delete(singleId: id)
    }
    
    // MARK: *** Server ***
    
    func testGetServerInfo() async throws {
        // Given
        let expectedVersion = "1.0.0"
        let expectedApiVersions = "v1"
        let expectedName = "Robert’s Mac Studio"
        let expectedAddress = "127.0.0.1:8888"

        do {
            let status = try await api.getServerInfo()
            XCTAssertEqual(status.version, expectedVersion)
            XCTAssertEqual(status.apiVersions, expectedApiVersions)
            XCTAssertEqual(status.name, expectedName)
            XCTAssertEqual(status.address, expectedAddress)
            XCTAssertEqual(status.albumCount, 0)
            XCTAssertEqual(status.singleCount, 0)
            XCTAssertEqual(status.playlistCount, 0)
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with API error - \(apiError)")
            }
            XCTFail("Failed with error - \(error.localizedDescription)")
        }

    }
    
    // MARK: *** Album ***
    
    func testGetAlbums() async throws {
        // Given
        let composer = "Mahler, Gustav (1860-1911)"


        let album1 = try await createAlbum(title: "Symphony No. 10 - Adagio", composer: composer)
        let album2 = try await createAlbum(title: "Symphony No. 1 'Titan'", composer: composer)
        let album3 = try await createAlbum(title: "Symphony No. 8", composer: composer)
        let album4 = try await createAlbum(title: "Symphony No.5 in C# minor", composer: composer)
        
        let fields = "title,artist,composer,genre,recordingYear,frontart,directory"
        let offset = 1
        let limit = 2

        do {
            let apiAlbums = try await api.getAlbums(fields: fields, offset: offset, limit: limit)
            let albums = apiAlbums.albums.map { AlbumSummary ($0) }
            XCTAssertEqual(albums.count, 2)
            for album in albums {
                switch album.id {
                case album2.id:
                    XCTAssertEqual(album.title, album2.title)
                    XCTAssertEqual(album.artist, album2.artist)
                    XCTAssertEqual(album.composer, album2.composer)
                    XCTAssertEqual(album.genre, album2.genre)
                    XCTAssertEqual(album.frontArtFilename, album2.frontArtRef()?.filename)
                    XCTAssertEqual(album.directory, album2.directory)
                case album3.id:
                    XCTAssertEqual(album.title, album3.title)
                    XCTAssertEqual(album.artist, album3.artist)
                    XCTAssertEqual(album.composer, album3.composer)
                    XCTAssertEqual(album.genre, album3.genre)
                    XCTAssertEqual(album.frontArtFilename, album3.frontArtRef()?.filename)
                    XCTAssertEqual(album.directory, album3.directory)
                default:
                    XCTFail("Unexpected album: \(album.title)")
                }
            }
        } catch {
            XCTFail("Unexpected failure: \(error.localizedDescription)")
        }

        try await deleteAlbum(album1.id)
        try await deleteAlbum(album2.id)
        try await deleteAlbum(album3.id)
        try await deleteAlbum(album4.id)

    }
    
    func testGetAlbum() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try await createAlbum(title: title, composer: composer)

        do {
            let album = try await api.get(albumId: testAlbum.id)
            XCTAssertEqual(album.title, "Symphony No. 10 - Adagio")
            XCTAssertEqual(album.artist, "Bernstein, Wiener Philharmoniker")
            XCTAssertEqual(album.composer, "Mahler, Gustav (1860-1911)")
            XCTAssertNil(album.conductor)
            XCTAssertEqual(album.duration, 1564)
        } catch APIError.notFound {
            XCTFail("Album not found")
        } catch {
            XCTFail("Unexpected failure: \(error.localizedDescription)")
        }

        try await deleteAlbum(testAlbum.id)

    }

    func testGetAlbumNotFound() async throws {
        // Given
        let id = "54738953-4079-4BF7-A188-E3B6A245866C"
        do {
            // When
            let _ = try await api.get(albumId: id)
            // Then
            XCTFail("Album found")
        } catch APIError.notFound {
            // Success
        } catch {
            XCTFail("Unexpected error - \(error.localizedDescription)")
        }
    }
    
    func testGetAlbumBadPort() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try await createAlbum(title: title, composer: composer)

        api.serverURL = "http://127.0.0.1:8280"

        do {
            // When
            let _ = try await api.get(albumId: testAlbum.id)
            // Then
            XCTFail("Unexpected Success")
        } catch {
            if let apiError = error as? APIError {
                switch apiError {
                case .networkError(let error):
                    XCTAssertEqual(error.errorCode, -1004)
                default:
                    XCTFail("Unexpected error: \(apiError)")
                }
            }
        }

        api.serverURL = defaultServerURL

        try await deleteAlbum(testAlbum.id)
    }
    
    func testGetAlbumFile() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try await createAlbum(title: title, composer: composer)
        let albumURL = getAlbumURL(title: title, composer: composer)
    
        let filename = testAlbum.frontArtRef()?.filename ?? "front"
        var fileContents: Data = Data()

        let expectedContents: Data = FileManager.default.contents(atPath: albumURL.appendingPathComponent(filename).path) ?? Data()

        do {
            // When
            fileContents = try await api.getFile(albumId: testAlbum.id, filename: filename)
            // Then
            XCTAssertEqual(fileContents, expectedContents)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }

        try await deleteAlbum(testAlbum.id)
    }
    
    func testPostAlbum() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        
        let album = getAlbum(title: title, composer: composer)
        
        do {
            // When
            let transaction = try await api.post(album: album)
            // Then
            XCTAssertEqual(transaction.entity, "album")
            XCTAssertEqual(transaction.method, "POST")
            XCTAssertEqual(transaction.id, album.id)
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            }
            XCTFail("Unexpected failure \(error.localizedDescription)")
        }

        try await deleteAlbum(album.id)
    }
    
    func testPostAlbumFile() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let filename = "test.txt"
        
        let album = try await createAlbum(title: title, composer: composer)

        do {
            // When
            try await api.postFile(album: album, filename: filename)
            // Then
            //  Success
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            }
            XCTFail("Unexpected failure \(error.localizedDescription)")
        }

        try await deleteAlbum(album.id)
    }

    func testPutAlbum() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        
        let testAlbum = try await createAlbum(title: title, composer: composer)

        var album = testAlbum
        album.title = "Symphony No. 10 - Altered"
        album.artist = "Leonard Bernstein"

        do {
            // When
            let transaction = try await api.put(album: album)
            // Then
            XCTAssertEqual(transaction.entity, "album")
            XCTAssertEqual(transaction.method, "PUT")
            XCTAssertEqual(transaction.id, testAlbum.id)
        }

        try await deleteAlbum(testAlbum.id)
    }
    
    func testPutAlbumFile() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let filename = "front.jpg"

        let album = try await createAlbum(title: title, composer: composer)

        do {
            try await api.putFile(album: album, filename: filename)
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            }
            XCTFail("Unexpected failure \(error.localizedDescription)")
        }

        try await deleteAlbum(album.id)

    }
    
    func testDeleteAlbum() async throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try await createAlbum(title: title, composer: composer)

        do {
            // When
            let transaction = try await api.delete(albumId: testAlbum.id)
            // Then
            XCTAssertEqual(transaction.entity, "album")
            XCTAssertEqual(transaction.method, "DELETE")
            XCTAssertEqual(transaction.id, testAlbum.id)
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            }
            XCTFail("Unexpected failure \(error.localizedDescription)")
        }
    }
    
    func testDeleteAlbumFile() async throws {
        // Given
        let composer = "Mahler, Gustav (1860-1911)"
        let title = "Symphony No. 10 - Adagio"
        let filename = "front.jpg"
        
        let album = try await createAlbum(title: title, composer: composer)

        do {
            try await api.deleteFile(albumId: album.id, filename: filename)
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            }
            XCTFail("Unexpected failure \(error.localizedDescription)")
        }
    
        try await deleteAlbum(album.id)

    }
    
    // MARK: *** Single ***
    
    func testGetSingles() async throws {
        // Given

        let single1 = try await createSingle(genre: "Alternative", artist: "Amos, Tori")
        let single2 = try await createSingle(genre: "Jazz", artist: "Bud Powell Trio")
        let single3 = try await createSingle(genre: "Jazz", artist: "Coleman Hawkins")
        let single4 = try await createSingle(genre: "Kids", artist: "Sheb Woolly")
        
        let fields = "title,artist,composer,genre,recordingYear"
        let offset = 1
        let limit = 2

        do {
            // When
            let apiSingles = try await api.getSingles(fields: fields, offset: offset, limit: limit)
            let singles = apiSingles.singles.map { SingleSummary ($0) }
            // Then
            XCTAssertEqual(singles.count, 2)
            for single in singles {
                switch single.id {
                case single2.id:
                    XCTAssertEqual(single.title, single2.title)
                    XCTAssertEqual(single.artist, single2.artist)
                    XCTAssertEqual(single.composer, single2.composer)
                    XCTAssertEqual(single.genre, single2.genre)
                    XCTAssertEqual(single.recordingYear, single2.recordingYear)
                case single3.id:
                    XCTAssertEqual(single.title, single3.title)
                    XCTAssertEqual(single.artist, single3.artist)
                    XCTAssertEqual(single.composer, single3.composer)
                    XCTAssertEqual(single.genre, single3.genre)
                    XCTAssertEqual(single.recordingYear, single3.recordingYear)
                default:
                    XCTFail("Unexpected single: \(single.title)/\(single.id)")

                }
            }
        } catch {
            XCTFail("Unexpected Failure: \(error.localizedDescription)")
        }

        // Cleanup
        try await deleteSingle(single1.id)
        try await deleteSingle(single2.id)
        try await deleteSingle(single3.id)
        try await deleteSingle(single4.id)

    }
    
    func testGetSingle() async throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let testSingle = try await createSingle(genre: genre, artist: artist)

        do {
            // When
            let single = try await api.get(singleId: testSingle.id)
            // Then
            XCTAssertEqual(single.title, "Get Happy")
            XCTAssertEqual(single.artist, "Bud Powell Trio")
            XCTAssertEqual(single.composer, "Harold Arlen/Ted Koehler")
            XCTAssertEqual(single.genre, "Jazz")
            XCTAssertNil(single.conductor)
            XCTAssertEqual(single.recordingYear, 2000)
            XCTAssertEqual(single.duration, 173)
            XCTAssertEqual(single.filename, "14 Get Happy.mp3")
            XCTAssertEqual(single.directory, "singles/Jazz/Bud Powell Trio")
        } catch APIError.notFound {
            XCTFail("Single not found")
        } catch {
            XCTFail("Unexpected failure: \(error.localizedDescription)")
        }

        // Cleanup
        try await deleteSingle(testSingle.id)

    }

    func testGetSingleNotFound() async throws {
        // Given
        let id = "2AF8F474-5B5B-4183-860A-BF96F50F6F9F"

        do {
            // When
            let _ = try await api.get(singleId: id)
            // Then
            XCTFail("Single found")
        } catch APIError.notFound {
            // Success
        } catch {
            XCTFail("Unexpected error - \(error.localizedDescription)")
        }
    }
  
    func testGetSingleBadPort() async throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let testSingle = try await createSingle(genre: genre, artist: artist)

        api.serverURL = "http://127.0.0.1:8280"

        do {
            // When
            let _ = try await api.get(singleId: testSingle.id)
            // Then
            XCTFail("Unexpected Success")
        } catch {
            if let apiError = error as? APIError {
                switch apiError {
                case .networkError(let error):
                    XCTAssertEqual(error.errorCode, -1004)
                default:
                    XCTFail("Unexpected error: \(apiError)")
                }
            }
        }

        api.serverURL = defaultServerURL

        try await deleteSingle(testSingle.id)
    }
    
    func testGetSingleFile() async throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let testSingle = try await createSingle(genre: genre, artist: artist)
        let singleURL  = getSingleURL(genre: genre, artist: artist)
        
        let filename = testSingle.filename
        
        var fileContents: Data = Data()
        let expectedContents: Data = FileManager.default.contents(atPath: singleURL.appendingPathComponent(filename).path) ?? Data()

        do {
            // When
            fileContents = try await api.getFile(singleId: testSingle.id, filename: filename)
            // Then
            XCTAssertEqual(fileContents, expectedContents)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }

        try await deleteSingle(testSingle.id)
    }
    
    func testPostSingle() async throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        
        let single = getSingle(genre: genre, artist: artist)

        do {
            // When
            let transaction = try await api.post(single: single)
            // Then
            XCTAssertEqual(transaction.entity, "single")
            XCTAssertEqual(transaction.method, "POST")
            XCTAssertEqual(transaction.id, single.id)
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            }
            XCTFail("Unexpected failure \(error.localizedDescription)")
        }

        try await deleteSingle(single.id)
    }
    
    func testPostSingleFile() async throws {
        // Given
        let genre = "Rock"
        let artist = "Roy Orbison"
        let filename = "test.txt"
        
        let single = try await createSingle(genre: genre, artist: artist, jsonFilename: "01 Crying.json")

        do {
            // When
            try await api.postFile(single: single, filename: filename)
            // Then
            //  Success
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            } else {
                XCTFail("Unexpected failure \(error.localizedDescription)")
            }
        }

        try await api.deleteFile(singleId: single.id, filename: filename)
        try await deleteSingle(single.id)
        
    }
    
    func testPutSingle() async throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        
        let testSingle = try await createSingle(genre: genre, artist: artist)

        var single = testSingle
        single.title = "Move"
        single.artist = "Stan Getz"

        do {
            // When
            let transaction = try await api.put(single: single)
            // Then
            XCTAssertEqual(transaction.entity, "single")
            XCTAssertEqual(transaction.method, "PUT")
            XCTAssertEqual(transaction.id, testSingle.id)

        }

        try await deleteSingle(testSingle.id)
    }
    
    func testPutSingleFile() async throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let filename =  "14 Get Happy.mp3"
        
        let single = try await createSingle(genre: genre, artist: artist)

        do {
            // When
            try await api.putFile(single: single, filename: filename)
            // Then
            //  Success
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            } else {
                XCTFail("Unexpected failure \(error.localizedDescription)")
            }
        }

        try await api.deleteFile(singleId: single.id, filename: filename)
        try await deleteSingle(single.id)
    }
    
    func testDeleteSingle() async throws {
        // Given
        let genre = "Rock"
        let artist = "Roy Orbison"
        
        let testSingle1 = try await createSingle(genre: genre, artist: artist, jsonFilename: "01 Crying.json")
        let testSingle2 = try await createSingle(genre: genre, artist: artist, jsonFilename: "01 Roy Orbison - Pretty Woman.json")
        let testSingle3 = try await createSingle(genre: genre, artist: artist, jsonFilename: "05 It's Over.json")
        let testSingle4 = try await createSingle(genre: genre, artist: artist, jsonFilename: "Blue Bayou.json")

        do {
            // When
            let transaction = try await api.delete(singleId: testSingle3.id)
            // Then
            XCTAssertEqual(transaction.entity, "single")
            XCTAssertEqual(transaction.method, "DELETE")
            XCTAssertEqual(transaction.id, testSingle3.id)
            let apiSingles = try await api.getSingles(fields: "title", offset: nil, limit: nil)
            let titles =  apiSingles.singles.map { $0.title }
            XCTAssertEqual(titles.count, 3)
            if titles.contains(testSingle3.title) {
                XCTFail("Single not deleted \(testSingle3.title)")
            }
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            }
            XCTFail("Unexpected failure \(error.localizedDescription)")
        }

        try await deleteSingle(testSingle1.id)
        try await deleteSingle(testSingle2.id)
        try? await deleteSingle(testSingle3.id)
        try await deleteSingle(testSingle4.id)
    }
    
    func testDeleteSingleFile() async throws {
        // Given
        let genre = "Rock"
        let artist = "Roy Orbison"
        let filename = "01 Crying.mp3"
        
        let single = try await createSingle(genre: genre, artist: artist, jsonFilename: "01 Crying.json")
        
        do {
            // When
            try await api.deleteFile(singleId: single.id, filename: filename)
            // Then
            //  Success
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            } else {
                XCTFail("Unexpected failure \(error.localizedDescription)")
            }
        }
        do {
            try await api.deleteFile(singleId: single.id, filename: filename)
            XCTFail("Double delete did not fail")
        } catch APIError.notFound {
            // Success
        } catch {
            if let apiError = error as? APIError {
                XCTFail("Failed with error - \(apiError)")
            } else {
                XCTFail("Unexpected failure \(error.localizedDescription)")
            }
        }

        try await deleteSingle(single.id)
    }
    
    // MARK: *** Playlist ***
    
    
    static var allTests = [
        ("testGetServerInfo", testGetServerInfo),
        ("testGetAlbums", testGetAlbums),
        ("testGetAlbum", testGetAlbum),
        ("testGetAlbumNotFound", testGetAlbumNotFound),
        ("testGetAlbumBadPort", testGetAlbumBadPort),
        ("testGetAlbumFile", testGetAlbumFile),
        ("testPostAlbum", testPostAlbum),
        ("testPostAlbumFile", testPostAlbumFile),
        ("testPutAlbum", testPutAlbum),
        ("testPutAlbumFile", testPutAlbumFile),
        ("testDeleteAlbum", testDeleteAlbum),
        ("testDeleteAlbumFile", testDeleteAlbumFile),
        ("testGetSingles", testGetSingles),
        ("testGetSingle", testGetSingle),
        ("testGetSingleNotFound", testGetSingleNotFound),
    ]
}
