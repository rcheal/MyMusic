import XCTest
import Combine
@testable import MyMusicAPI
@testable import MusicMetadata

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
        api.serverURL = "http://127.0.0.1:8888"
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
    
    func createAlbum(title: String, composer: String) throws -> Album {
    
        let album = getAlbum(title: title, composer: composer)
        
        let publisher = try api.postAlbum(album)
        let expectation = self.expectation(description: #function)

        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        if apiError != .conflict {
                            XCTFail("Album post failed with error \(apiError)")
                        }
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 4, handler: nil)
        return album
    }
    
    func deleteAlbum(_ id: String) throws {
        let publisher = try api.deleteAlbum(id)
        let expectation = self.expectation(description: #function)

        publisher
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
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
    
    func createSingle(genre: String, artist: String, jsonFilename: String? = nil) throws -> Single {
        let filename = jsonFilename ?? "single.json"
        let single = getSingle(genre: genre, artist: artist, jsonFilename: filename)
        
        let publisher = try api.postSingle(single)
        let expectation = self.expectation(description: #function)

        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        if apiError != .conflict {
                            XCTFail("Single post failed with error \(apiError)")
                        }
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 4, handler: nil)
        return single
    }
    
    func createSingleFile(single: Single, filename: String) throws {
        
        let publisher = try api.postSingleFile(single, filename: filename)
        let expectation = self.expectation(description: #function)
        
        publisher
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func deleteSingle(_ id: String) throws {
        let publisher = try api.deleteSingle(id)
        let expectation = self.expectation(description: #function)

        publisher
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func deleteSingleFile(_ id: String, filename: String) throws {
        let publisher = try api.deleteSingleFile(id, filename: filename)
        let expectation = self.expectation(description: #function)
        
        publisher
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    // MARK: *** Server ***
    
    func testGetServerInfo() throws {
        // Given
        let publisher = try api.getServerInfo()
        let expectedVersion = "1.0.0"
        let expectedApiVersions = "v1"
        let expectedName = "Robert’s iMac"
        let expectedAddress = "127.0.0.1:8888"
        let expectation = self.expectation(description: #function)
        var serverStatus: APIServerStatus?
        
        // When

        publisher
            .sink(receiveCompletion: { _ in expectation.fulfill() },
                  receiveValue: { serverStatus = $0 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNotNil(serverStatus)
        if let status = serverStatus {
            XCTAssertEqual(status.version, expectedVersion)
            XCTAssertEqual(status.apiVersions, expectedApiVersions)
            XCTAssertEqual(status.name, expectedName)
            XCTAssertEqual(status.address, expectedAddress)
        }
        
    }
    
    // MARK: *** Album ***
    
    func testGetAlbums() throws {
        // Given
        let composer = "Mahler, Gustav (1860-1911)"
        
        let album1 = try! createAlbum(title: "Symphony No. 10 - Adagio", composer: composer)
        let album2 = try! createAlbum(title: "Symphony No. 1 'Titan'", composer: composer)
        let album3 = try! createAlbum(title: "Symphony No. 8", composer: composer)
        let album4 = try! createAlbum(title: "Symphony No.5 in C# minor", composer: composer)
        
        let fields = "title,artist,composer,genre,recordingYear,frontart,directory"
        let offset = 1
        let limit = 2
        let publisher = try api.getAlbums(fields: fields, offset: offset, limit: limit)
        let expectation = self.expectation(description: #function)
        
        var albums: [AlbumSummary]?
        
        // When
        
        publisher
            .map { albums in
                albums.albums.map {
                    AlbumSummary($0)
                }
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Unexpected failure: \(error)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    albums = $0
                })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNotNil(albums)
        if let albums = albums {
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
        }
        
        try! deleteAlbum(album1.id)
        try! deleteAlbum(album2.id)
        try! deleteAlbum(album3.id)
        try! deleteAlbum(album4.id)

    }
    
    func testGetAlbum() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try! createAlbum(title: title, composer: composer)

        let publisher = try api.getAlbum(testAlbum.id)
        let expectation = self.expectation(description: #function)
        
        var album: Album?
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Unexpected failure: \(error)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    album = $0
                })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNotNil(album)
        if let album = album {
            XCTAssertEqual(album.title, "Symphony No. 10 - Adagio")
            XCTAssertEqual(album.artist, "Bernstein, Wiener Philharmoniker")
            XCTAssertEqual(album.composer, "Mahler, Gustav (1860-1911)")
            XCTAssertNil(album.conductor)
            XCTAssertEqual(album.duration, 1564)
        }
        
    }

    func testGetAlbumNotFound() throws {
        // Given
        let id = "54738953-4079-4BF7-A188-E3B6A245866C"
        let publisher = try api.getAlbum(id)
        let expectation = self.expectation(description: #function)
        let expectedError = APIError.notFound
        
        var apiError: APIError = APIError.unknown
        var album: Album?
        
        // When
        
        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    apiError = error
                default:
                    break
                    
                }
                expectation.fulfill()
                
            },
                  receiveValue: { album = $0 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNil(album)
        XCTAssertEqual(apiError, expectedError)
        
    }
    
    func testGetAlbumBadPort() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try! createAlbum(title: title, composer: composer)

        api.serverURL = "http://127.0.0.1:8280"
        let publisher = try api.getAlbum(testAlbum.id)
        let expectation = self.expectation(description: #function)
        
        var apiError: APIError = APIError.unknown
        var album: Album?
        
        // When
        
        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    apiError = error
                default:
                    break
                    
                }
                expectation.fulfill()
                
            },
                  receiveValue: { album = $0 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNil(album)
        switch apiError {
        case .networkError(let error):
            XCTAssertEqual(error.errorCode, -1004)
        default:
            XCTFail("Unexpected error: \(apiError)")
        }
    }
    
    func testGetAlbumFile() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try! createAlbum(title: title, composer: composer)
        let albumURL = getAlbumURL(title: title, composer: composer)
    
        let filename = testAlbum.frontArtRef()?.filename ?? "front"
        
        var fileContents: Data = Data()
        let expectedContents: Data = FileManager.default.contents(atPath: albumURL.appendingPathComponent(filename).path) ?? Data()
        
        let publisher = try api.getAlbumFile(testAlbum.id, filename: filename)
        let expectation = self.expectation(description: #function)
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { data in
                    fileContents = data
                })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // Then
        XCTAssertEqual(fileContents, expectedContents)

    }
    
    func testPostAlbum() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        
        let album = getAlbum(title: title, composer: composer)
        
        try! deleteAlbum(album.id)
        
        let expectedFileCount = 6
        var fileCount = 0
        
        let publisher = try api.postAlbum(album)
        let expectation = self.expectation(description: #function)

        // When
            
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Album post failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        
        XCTAssertEqual(fileCount, expectedFileCount)
        
        try deleteAlbum(album.id)
    }
    
    func testPostAlbumFile() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        
        let album = getAlbum(title: title, composer: composer)
    
        let expectedFileCount = 1
        var fileCount = 0
        
        let publisher = try api.postAlbumFile(album, filename: "test.txt")
        let expectation = self.expectation(description: #function)

        // When
    
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Album post failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
        // Then
        
        XCTAssertEqual(fileCount, expectedFileCount)

    }

    func testPutAlbum() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        
        let testAlbum = try! createAlbum(title: title, composer: composer)

        var album = testAlbum
        album.title = "Symphony No. 10 - Altered"
        album.artist = "Leonard Bernstein"
        
        let expectedFileCount = 1
        var fileCount = 0
        
        let publisher = try api.putAlbum(album)
        let expectation = self.expectation(description: #function)

        // When
            
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Album put failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        
        XCTAssertEqual(fileCount, expectedFileCount)
        
        try! deleteAlbum(album.id)
    }
    
    func testPutAlbumFile() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let filename = "front.jpg"

        let expectedFileCount = 1
        var fileCount = 0
        
        let album = try createAlbum(title: title, composer: composer)
        
        let publisher = try api.putAlbumFile(album, filename: filename)
        let expectation = self.expectation(description: #function)

        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Album put file failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertEqual(fileCount, expectedFileCount)
        
        try deleteAlbum(album.id)

    }
    
    func testDeleteAlbum() throws {
        // Given
        let title = "Symphony No. 10 - Adagio"
        let composer = "Mahler, Gustav (1860-1911)"
        let testAlbum = try! createAlbum(title: title, composer: composer)
    
        let publisher = try api.deleteAlbum(testAlbum.id)
        let expectation = self.expectation(description: #function)

        // When
            
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Album delete failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDeleteAlbumFile() throws {
        // Given
        let composer = "Mahler, Gustav (1860-1911)"
        let title = "Symphony No. 10 - Adagio"
        let filename = "front.jpg"
        
        let album = try! createAlbum(title: title, composer: composer)
    
        var fileCount = 0
        
        let publisher = try api.deleteAlbumFile(album.id, filename: filename)
        let expectation = self.expectation(description: #function)

        // When
    
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Album put failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertEqual(fileCount, 1)
        
        try deleteAlbum(album.id)

    }
    
    // MARK: *** Single ***
    
    func testGetSingles() throws {
        // Given
        try! deleteSingle(getSingle(genre: "Alternative", artist: "Amos, Tori").id)
        try! deleteSingle(getSingle(genre: "Jazz", artist: "Bud Powell Trio").id)
        try! deleteSingle(getSingle(genre: "Jazz", artist: "Coleman Hawkins").id)
        try! deleteSingle(getSingle(genre: "Kids", artist: "Sheb Woolly").id)

        let single1 = try! createSingle(genre: "Alternative", artist: "Amos, Tori")
        let single2 = try! createSingle(genre: "Jazz", artist: "Bud Powell Trio")
        let single3 = try! createSingle(genre: "Jazz", artist: "Coleman Hawkins")
        let single4 = try! createSingle(genre: "Kids", artist: "Sheb Woolly")
        
        let fields = "title,artist,composer,genre,recordingYear"
        let offset = 1
        let limit = 2
        let publisher = try api.getSingles(fields: fields, offset: offset, limit: limit)
        let expectation = self.expectation(description: #function)
        
        var singles: [SingleSummary]?
        
        // When
        
        publisher
            .map { singles in
                singles.singles.map {
                    SingleSummary($0)
                }
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Unexpected failure: \(error)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    singles = $0
                })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNotNil(singles)
        if let singles = singles {
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
        }
        
        try! deleteSingle(single1.id)
        try! deleteSingle(single2.id)
        try! deleteSingle(single3.id)
        try! deleteSingle(single4.id)

    }
    
    func testGetSingle() throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let testSingle = try! createSingle(genre: genre, artist: artist)
        
        let publisher = try api.getSingle(testSingle.id)
        let expectation = self.expectation(description: #function)
        
        var single: Single?
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Unexpected failure: \(error)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    single = $0
                })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNotNil(single)
        if let single = single {
            XCTAssertEqual(single.title, "Get Happy")
            XCTAssertEqual(single.artist, "Bud Powell Trio")
            XCTAssertEqual(single.composer, "Harold Arlen/Ted Koehler")
            XCTAssertEqual(single.genre, "Jazz")
            XCTAssertNil(single.conductor)
            XCTAssertEqual(single.recordingYear, 2000)
            XCTAssertEqual(single.duration, 173)
            XCTAssertEqual(single.filename, "14 Get Happy.mp3")
            XCTAssertEqual(single.directory, "singles/Jazz/Bud Powell Trio")

        }
        
        try deleteSingle(testSingle.id)

    }

    func testGetSingleNotFound() throws {
        // Given
        let id = "2AF8F474-5B5B-4183-860A-BF96F50F6F9F"
        let publisher = try api.getSingle(id)
        let expectation = self.expectation(description: #function)
        let expectedError = APIError.notFound
        
        var apiError: APIError = APIError.unknown
        var single: Single?
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        apiError = error
                    default:
                        break
                        
                    }
                    expectation.fulfill()
                    
                },
                receiveValue: { single = $0 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNil(single)
        XCTAssertEqual(apiError, expectedError)
        
    }
  
    func testGetSingleBadPort() throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let testSingle = try! createSingle(genre: genre, artist: artist)

        api.serverURL = "http://127.0.0.1:8280"
        let publisher = try api.getSingle(testSingle.id)
        let expectation = self.expectation(description: #function)
        
        var apiError: APIError = APIError.unknown
        var single: Single?
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        apiError = error
                    default:
                        break
                        
                    }
                    expectation.fulfill()
                    
                },
                receiveValue: { single = $0 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertNil(single)
        switch apiError {
        case .networkError(let error):
            XCTAssertEqual(error.errorCode, -1004)
        default:
            XCTFail("Unexpected error \(apiError)")
        }
        
        try deleteSingle(testSingle.id)
    }
    
    func testGetSingleFile() throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let testSingle = try! createSingle(genre: genre, artist: artist)
        let singleURL  = getSingleURL(genre: genre, artist: artist)
        
        let filename = testSingle.filename
        
        var fileContents: Data = Data()
        let expectedContents: Data = FileManager.default.contents(atPath: singleURL.appendingPathComponent(filename).path) ?? Data()
        
        let publisher = try api.getSingleFile(testSingle.id, filename: filename)
        let expectation = self.expectation(description: #function)
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { data in
                    fileContents = data
                })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertEqual(fileContents, expectedContents)
        
        try deleteSingle(testSingle.id)
    }
    
    func testPostSingle() throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        
        let single = getSingle(genre: genre, artist: artist)
        
        try! deleteSingle(single.id)
        
        let expectedFileCount = 1
        var fileCount = 0
        
        let publisher = try api.postSingle(single)
        let expectation = self.expectation(description: #function)
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Single post failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1})
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertEqual(fileCount, expectedFileCount)
        
        try deleteSingle(single.id)
        
    }
    
    func testPostSingleFile() throws {
        // Given
        let genre = "Rock"
        let artist = "Roy Orbison"
        let filename = "test.txt"
        
        let single = try! createSingle(genre: genre, artist: artist, jsonFilename: "01 Crying.json")
        
        let expectedFileCount = 1
        var fileCount = 0
        
        let publisher = try api.postSingleFile(single, filename: filename)
        let expectation = self.expectation(description: #function)
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Single file post failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        
        XCTAssertEqual(fileCount, expectedFileCount)
        
        try! deleteSingleFile(single.id, filename: filename)
        try! deleteSingle(single.id)
        
    }
    
    func testPutSingle() throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        
        let testSingle = try! createSingle(genre: genre, artist: artist)

        var single = testSingle
        single.title = "Move"
        single.artist = "Stan Getz"
        
        let expectedFileCount = 1
        var fileCount = 0
        
        let publisher = try api.putSingle(single)
        let expectation = self.expectation(description: #function)
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Single put failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        
        XCTAssertEqual(fileCount, expectedFileCount)
        
        try! deleteSingle(single.id)
    }
    
    func testPutSingleFile() throws {
        // Given
        let genre = "Jazz"
        let artist = "Bud Powell Trio"
        let filename =  "14 Get Happy.mp3"
        
        let expectedFileCount = 1
        var fileCount = 0
        
        let single = try createSingle(genre: genre, artist: artist)
        
        let publisher = try api.putSingleFile(single, filename: filename)
        let expectation = self.expectation(description: #function)
        
        // When

        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Single put file failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)

        // Then
        XCTAssertEqual(fileCount, expectedFileCount)
        
        try deleteSingle(single.id)
    }
    
    func testDeleteSingle() throws {
        // Given
        let genre = "Rock"
        let artist = "Roy Orbison"
        
        let testSingle1 = try! createSingle(genre: genre, artist: artist, jsonFilename: "01 Crying.json")
        let testSingle2 = try! createSingle(genre: genre, artist: artist, jsonFilename: "01 Roy Orbison - Pretty Woman.json")
        let testSingle3 = try! createSingle(genre: genre, artist: artist, jsonFilename: "05 It's Over.json")
        let testSingle4 = try! createSingle(genre: genre, artist: artist, jsonFilename: "Blue Bayou.json")
        
        let publisher = try api.deleteSingle(testSingle3.id)
        let expectation = self.expectation(description: #function)
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Single delete failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        
        let exp = self.expectation(description: #function + ": THEN")
        
        try api.getSingles(fields: "title")
            .map {
                $0.singles.map { $0.title }
            }
            .sink(
                receiveCompletion: { _ in exp.fulfill() },
                receiveValue: { titles in
                    XCTAssertEqual(titles.count, 3)
                    if titles.contains(testSingle3.title) {
                        XCTFail("Single not deleted \(testSingle3.title)")
                    }
                })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        try! deleteSingle(testSingle1.id)
        try! deleteSingle(testSingle2.id)
        try! deleteSingle(testSingle3.id)
        try! deleteSingle(testSingle4.id)
    }
    
    func testDeleteSingleFile() throws {
        // Given
        let genre = "Rock"
        let artist = "Roy Orbison"
        let filename = "test.txt"
        
        let single = try! createSingle(genre: genre, artist: artist, jsonFilename: "01 Crying.json")
        
        try! createSingleFile(single: single, filename: filename)
        
        var fileCount = 0
        
        let publisher = try api.deleteSingleFile(single.id, filename: filename)
        let expectation = self.expectation(description: #function)
        
        // When
        
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        XCTFail("Single file delete failed with error \(apiError)")
                    case .finished:
                        break
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in  fileCount += 1 })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertEqual(fileCount, 1)
        
        try deleteSingle(single.id)
    }
    
    // MARK: *** Playlist ***
    
    
    static var allTests = [
        ("testGetServerInfo", testGetServerInfo),
        ("testGetAlbums", testGetAlbums),
        ("testGetAlbum", testGetAlbum),
        ("testGetAlbumNotFound", testGetAlbumNotFound),
        ("testGetAlbumBadPort", testGetAlbumBadPort),
        ("testGetSingles", testGetSingles),
        ("testGetSingle", testGetSingle),
        ("testGetSingleNotFound", testGetSingleNotFound),
    ]
}
