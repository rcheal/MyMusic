//
//  MyMusicAPI.swift
//  
//
//  Created by Robert Cheal on 2/12/21.
//

import Foundation
import MusicMetadata
import Combine

public let serverEndpoint = "v1"
public let albumsEndpoint = "v1/albums"
public let singlesEndpoint = "v1/singles"
public let playlistsEndpoint = "v1/playlists"

public class MyMusicAPI {
    
    public var serverURL: String = ""
    public static var shared = MyMusicAPI()
    public var fileRootURL = URL(fileURLWithPath: "")
    
    private var subscriptions = Set<AnyCancellable>()
    
    public init() {
        
    
    }

    private func getAPIError(from response: URLResponse) -> APIError {
        guard let httpResponse = response as? HTTPURLResponse else {
            return APIError.unknown
        }
        return APIError(status: httpResponse.statusCode)
    }


    // MARK: - Combine Publisher creators
    
    private func apiGetListPublisher(_ endPoint: String, fields: String? = nil, offset: Int? = nil, limit: Int? = nil) -> AnyPublisher<Data, APIError> {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(endPoint)
            var queryItems: [(String,String)] = []
            if let fields = fields {
                queryItems.append(("fields",fields))
            }
            if let offset = offset {
                queryItems.append(("offset",String(offset)))
            }
            if let limit = limit {
                queryItems.append(("limit",String(limit)))
            }
            endpointURL.append(queryItems: queryItems)
            return apiGetPublisher(for: endpointURL)
        }
        return Fail<Data, APIError>(error: .badURL)
            .eraseToAnyPublisher()
    }
    
    private func apiGetPublisher(_ endPoint: String, id: String? = nil, filename: String? = nil) -> AnyPublisher<Data, APIError> {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(endPoint)
            if let id = id {
                endpointURL.appendPathComponent(id)
                if let filename = filename {
                    endpointURL.appendPathComponent(filename)
                }
            }
            return apiGetPublisher(for: endpointURL)
        }
        return Fail<Data, APIError>(error: .badURL)
            .eraseToAnyPublisher()
    }

    private func apiPostPublisher(_ endPoint: String, id: String, filename: String? = nil, data: Data) -> AnyPublisher<Void, APIError> {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(endPoint).appendingPathComponent(id)
            var contentType = "application/json"
            if let filename = filename {
                endpointURL.appendPathComponent(filename)
                contentType = "application/octet-stream"
            }
            return apiPublisher(for: endpointURL, method: "POST", contentType: contentType, body: data)
            
        }
        return Fail<Void, APIError>(error: .badURL)
            .eraseToAnyPublisher()
    }
    
    private func apiPutPublisher(_ endPoint: String, id: String, filename: String? = nil, data: Data) -> AnyPublisher<Void, APIError> {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(endPoint).appendingPathComponent(id)
            var contentType = "application/json"
            if let filename = filename {
                endpointURL.appendPathComponent(filename)
                contentType = "application/octet-stream"
            }
            return apiPublisher(for: endpointURL, method: "PUT", contentType: contentType, body: data)
            
        }
        return Fail<Void, APIError>(error: .badURL)
            .eraseToAnyPublisher()
    }
    
    private func apiDeletePublisher(_ endPoint: String, id: String, filename: String? = nil) -> AnyPublisher<Void, APIError> {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(endPoint).appendingPathComponent(id)
            if let filename = filename {
                endpointURL.appendPathComponent(filename)
            }
            return apiPublisher(for: endpointURL, method: "DELETE")
        }
        return Fail<Void, APIError>(error: .badURL)
            .eraseToAnyPublisher()
    }
    
    private func apiPublisher(for url: URL, method: String, contentType: String? = nil, body: Data? = nil) -> AnyPublisher<Void, APIError> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        if let body = body,
           let contentType = contentType {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                if httpResponse.statusCode == 404 {
                    throw APIError.notFound
                }
                if httpResponse.statusCode == 409 {
                    throw APIError.conflict
                }
                if (400..<500 ~= httpResponse.statusCode) {
                    throw APIError.clientError(statusCode: httpResponse.statusCode)
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                }
                if let urlerror = error as? URLError {
                    return APIError.networkError(from: urlerror)
                }
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    
    }
        
    private func apiGetPublisher(for url: URL) -> AnyPublisher<Data, APIError> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                if httpResponse.statusCode == 404 {
                    throw APIError.notFound
                }
                if (400..<500 ~= httpResponse.statusCode) {
                    throw APIError.clientError(statusCode: httpResponse.statusCode)
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                }
                if let urlerror = error as? URLError {
                    return APIError.networkError(from: urlerror)
                }
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Server

    /**
        GET /v1

     Returns a structure containing general server infomation

     - Returns: APIServerStatus
     */
    public func getServerInfo() async throws -> APIServerStatus {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(serverEndpoint)
            let request = URLRequest(url: endPoint)

            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let serverStatus = try JSONDecoder().decode(APIServerStatus.self, from: data)
                return serverStatus
            } catch {
                if let error = error as? APIError {
                    throw error
                }
                throw APIError.unknown
            }
        }
        throw APIError.badURL
    }

    // MARK: Server (Combine)

    public func getServerInfo() throws -> AnyPublisher<APIServerStatus, APIError> {
        return apiGetPublisher(serverEndpoint)
            .decode(type: APIServerStatus.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                }
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Albums

    /**
     GET /{albumsEndpoint}?fields&offset&limit

     HTTP call to return a list of album metadata.  Use fields to limit the metadata for each album and offset/limit to page through the results

     - Parameter fields: A comma separated list of fields to be include in the result.  nil for all fields
     - Parameter offset: Offset in list of all albums, to start the result
     - Parameter limit: Maximum number of albums to return

     - Returns: APIAlbums
     */
    public func getAlbums(fields: String? = nil, offset: Int? = nil, limit: Int? = nil) async throws -> APIAlbums {
        if let url = URL(string: serverURL) {
            var endPoint = url.appendingPathComponent(albumsEndpoint)
            var queryItems: [(String,String)] = []
            if let fields = fields {
                queryItems.append(("fields",fields))
            }
            if let offset = offset {
                queryItems.append(("offset",String(offset)))
            }
            if let limit = limit {
                queryItems.append(("limit",String(limit)))
            }
            if !queryItems.isEmpty {
                endPoint.append(queryItems: queryItems)
            }
            var request = URLRequest(url: endPoint)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            if let albums = try? JSONDecoder().decode(APIAlbums.self, from: data) {
                return albums
            }
            throw getAPIError(from: response)
        }
        throw APIError.badURL
    }

    /**
     HEAD /{albumsEndpoint}/:id

     HTTP HEAD call to determine if a specific album exists.

     - Parameter albumId: Unique id of specific album to check

     - Returns: true if album exists, false otherwise.
     */
    public func head(albumId: String) async throws -> Bool {
        if let endPoint = URL(string: albumsEndpoint)?.appendingPathComponent(albumId) {
            var request = URLRequest(url: endPoint)
            request.httpMethod = "HEAD"
            let (_, response) = try await URLSession.shared.data(for: request)
            let error = getAPIError(from: response)
            switch error {
            case .ok:
                return true
            case .notFound:
                return false
            default:
                throw error
            }
        }
        throw APIError.badURL
    }

    /**
     GET /{albumsEndpoint}/:id

     HTTP call to retrieve a specfic albums metadata.  Separate calls to getFile(:) must be made to retrieve audio files and cover artwork

     - Parameter albumId: Unique id of specific album to retrieve

     - Returns: Album
     */
    public func get(albumId: String) async throws -> Album {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            if let album = Album.decodeFrom(json: data) {
                return album
            }
            throw getAPIError(from: response)
        }
        throw APIError.badURL
    }

    /**
     POST album metadata and files to server

     POSTs album metadata and associated files to server.  Setting skipFiles to true will skip the associated files.

     POST /{albumsEndpoint}/:id

     If not skipFiles:

        POST /{albumsEndpoint}/:id/:filename

        ...    (repeat for each image and audio file in album)

     - Parameter album: Album metadata to post

     - Parameter skipFiles: Set to true to post metadata withoutj files

     - Returns: Transaction
     */
    public func post(album: Album, skipFiles: Bool = false) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let json = album.json {
                let (data, response) = try await URLSession.shared.upload(for: request, from: json)
                if let transaction = Transaction.decodeFrom(json: data) {
                    if !skipFiles,
                       let directory = album.directory {
                         let filenames =  album.getFilenames()
                         let localAlbumURL = fileRootURL.appendingPathComponent(directory)
                         for filename in filenames {
                             let localFileURL = localAlbumURL.appendingPathComponent(filename)
                             var fileRequest = URLRequest(url: endPoint.appendingPathComponent(filename))
                             fileRequest.httpMethod = "POST"
                             let (_, _) = try await URLSession.shared.upload(for: fileRequest, fromFile: localFileURL)
                         }
                    }
                    return transaction
                }
                throw getAPIError(from: response)
            }
            throw APIError.badRequest
        }
        throw APIError.badURL

    }

    /**
     PUT album metadata to server

     PUTs album metadata to server.  Setting skipFiles to false also PUT associated files to server.

     PUT /{albumsEndpoint}/:id

     If not skipFiles:

        PUT /{albumsEndpoint}/:id/:filename

        ...    (repeat for each image and audio file in album)

     - Parameter album: Album metadata to put

     - Parameter skipFiles: Set to false to include associated files

     - Returns: Transaction
     */
    public func put(album: Album, skipFiles: Bool = true) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let json = album.json {
                let (data, response) = try await URLSession.shared.upload(for: request, from: json)
                if let transaction = Transaction.decodeFrom(json: data) {
                    if !skipFiles,
                        let directory = album.directory {
                        let filenames =  album.getFilenames()
                        let localAlbumURL = fileRootURL.appendingPathComponent(directory)
                        for filename in filenames {
                            let localFileURL = localAlbumURL.appendingPathComponent(filename)
                            var fileRequest = URLRequest(url: endPoint.appendingPathComponent(filename))
                            fileRequest.httpMethod = "PUT"
                            let (_, _) = try await URLSession.shared.upload(for: fileRequest, fromFile: localFileURL)
                        }
                    }
                    return transaction
                }
                throw getAPIError(from: response)
            }
            throw APIError.badRequest
        }
        throw APIError.badURL
    }

    /**
     DELETE /{albumsEndpoint}/:id

     Deletes album and associated files from the server.

     - Parameter albumId: Unique id of the album to be deleted

     - Returns: Transaction
     */
    public func delete(albumId: String) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "DELETE"

            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(Transaction.self, from: data)
        }
        throw  APIError.badURL
    }

    // MARK: Albums (Combine)
    /**
     GET /{albumsEndpoint}?fields&offset&limit
     */
    public func getAlbums(fields: String? = nil, offset: Int? = nil, limit: Int? = nil) throws -> AnyPublisher<APIAlbums, APIError> {
        return apiGetListPublisher(albumsEndpoint, fields: fields, offset: offset, limit: limit)
            .decode(type: APIAlbums.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                }
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }

    /**
     GET /{albumsEndpoint}/:id
     */
//    @available(*, deprecated, message: "Use 'get(albumId:) async throws' instead")
    func getAlbum(_ id: String) throws -> AnyPublisher<Album, APIError> {
        return apiGetPublisher(albumsEndpoint, id: id)
            .decode(type: Album.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                }
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }

    /**
     POST /{albumsEndpoint}/:id
     POST /{albumsEndpoint}/:id/:filename
     ...    (repeat for each image and audio file in album)
     */
//    @available(*, deprecated, message: "Use 'post(album:) async throws -> Transsaction' instead")
    public func postAlbum(_ album: Album) throws -> AnyPublisher<Void, APIError> {
        let publisher = PassthroughSubject<AnyPublisher<Void, APIError>, APIError>()
        if let json = album.json,
           let directory = album.directory {
            let metaDataPostPublisher = apiPostPublisher(albumsEndpoint, id: album.id, data: json)

            metaDataPostPublisher
                .sink(
                    receiveCompletion: { [self] completion in
                        switch completion {
                        case .failure(let apiError):
                            publisher.send(completion: .failure(apiError))

                        case .finished:
                            let filenames =  album.getFilenames()
                            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
                            for filename in filenames {
                                let localFileURL = localAlbumURL.appendingPathComponent(filename)
                                if let data = FileManager.default.contents(atPath: localFileURL.path) {
                                    let fileDataPostPublisher = apiPostPublisher(albumsEndpoint, id: album.id, filename: filename, data: data)
                                    publisher.send(fileDataPostPublisher)
                                }
                            }
                            publisher.send(completion: .finished)


                        }

                    },
                    receiveValue: { _ in } )
                .store(in: &subscriptions)


            return publisher
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        throw APIError.unknown
    }

    /**
     PUT /{albumsEndpoint}/:id
     */
//    @available(*, deprecated, message: "Use 'put(album:skipFiles) async throws -> Transsaction' instead")
    public func putAlbum(_ album: Album, skipFiles: Bool = true) throws -> AnyPublisher<Void, APIError> {
        let publisher = PassthroughSubject<AnyPublisher<Void, APIError>, APIError>()
        if let json = album.json,
           let directory = album.directory {
            let metaDataPostPublisher = apiPutPublisher(albumsEndpoint, id: album.id, data: json)
            if skipFiles {
                return metaDataPostPublisher.eraseToAnyPublisher()
            }

            metaDataPostPublisher
                .sink(
                    receiveCompletion: { [self] completion in
                        switch completion {
                        case .failure(let apiError):
                            publisher.send(completion: .failure(apiError))

                        case .finished:
                            let filenames =  album.getFilenames()
                            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
                            for filename in filenames {
                                let localFileURL = localAlbumURL.appendingPathComponent(filename)
                                if let data = FileManager.default.contents(atPath: localFileURL.path) {
                                    let fileDataPostPublisher = apiPostPublisher(albumsEndpoint, id: album.id, filename: filename, data: data)
                                    publisher.send(fileDataPostPublisher)
                                }
                            }
                            publisher.send(completion: .finished)


                        }

                    },
                    receiveValue: { _ in } )
                .store(in: &subscriptions)


            return publisher
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        throw APIError.unknown
    }

    /**
     DELETE /{albumsEndpoint}/:id
     */
//    @available(*, deprecated, message: "Use 'delete(albumId:) async throws' instead")
    public func deleteAlbum(_ id: String) throws -> AnyPublisher<Void, APIError> {
        return apiDeletePublisher(albumsEndpoint, id: id)
            .eraseToAnyPublisher()
    }

    // MARK: - Album Files

    /**
     GET /{albumsEndpoint}/:id/:filename}

     Retrieve a single file contents from an album

     - Parameter albumId: Unique id of the associated album

     - Parameter filename: Filename of the file to retrieve

     - Returns: Contents of the file (Data)

     - Throws: APIError
     */
    public func getFile(albumId: String, filename: String) async throws -> Data {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId).appendingPathComponent(filename)

            let (data, _) = try await URLSession.shared.data(from: endpointURL)
            return data
        }
        throw APIError.badURL
    }

    /**
     POST /{albumsEndpoint}/:id/:filename}

     Post a single file contents related to the album.

     - Parameter albumId: Unique identifier of associated album

     - Parameter filename: Filename of the file to post

     - Parameter data: Content of file to post

     - Returns: No return value

     - Throws: APIError
     */
    public func postFile(albumId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")

            let (_, response) = try await URLSession.shared.upload(for: request, from: data)
            let apiError = getAPIError(from: response)
            if apiError == .ok {
                return
            }
            throw apiError
        }
        throw APIError.badURL
    }

    /**
     POST /{albumsEndpoint}/:id/:filename}

     Post a single file contents related to the album.  The file to post will be found on the local disk in the directory specified in the Album metadata

     - Parameter album: Previously retrieved (get(albumId:) metadata for the album

     - Parameter filename: Filename of the file to post

     - Returns: No return value

     - Throws: APIError

     - Deprecated:  Use 'postFile(albumId:filename:data) async throws' instead
     */
//    @available(*, deprecated, message: "Use 'postFile(albumId:filename:data) async throws' instead")
    public func postFile(album: Album, filename: String) async throws {
        if let directory = album.directory {
            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localAlbumURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = "POST"
                    request.setValue(contentType, forHTTPHeaderField: "Content-Type")

                    let (_, response) = try await URLSession.shared.upload(for: request, from: data)
                    let apiError = getAPIError(from: response)
                    if apiError == .ok {
                        return
                    }
                    throw apiError
                }
                throw APIError.badURL
            }
        }
        throw APIError.badRequest
    }

    /**
     PUT /{albumsEndpoint}/:id/:filename}

     Replace a single file contents related to the album.

     - Parameter albumId: Unique identifier of associated album

     - Parameter filename: Filename of the file to put

     - Parameter data: Content of file to put

     - Returns: No return value

     - Throws: APIError
     */
    public func putFile(albumId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "PUT"
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")

            let (_, response) = try await URLSession.shared.upload(for: request, from: data)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    throw getAPIError(from: response)
                }
                return
            }
            throw APIError.unknown
        }
        throw APIError.badURL

    }

//    @available(*, deprecated, message: "Use 'putFile(albumId:filename:data) async throws' instead")
    public func putFile(album: Album, filename: String) async throws {
        if let directory = album.directory {
            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localAlbumURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = "PUT"
                    request.setValue(contentType, forHTTPHeaderField: "Content-Type")

                    let (_, response) = try await URLSession.shared.upload(for: request, from: data)
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode != 200 {
                            throw getAPIError(from: response)
                        }
                        return
                    }
                    throw APIError.unknown
                }
                throw APIError.badURL
            }
        }
        throw APIError.clientError(statusCode: 400)

    }

    public func deleteFile(albumId: String, filename: String) async throws {
        if let url = URL(string: serverURL) {
            let endPointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId).appendingPathComponent(filename)
            var request = URLRequest(url: endPointURL)
            request.httpMethod = "DELETE"

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    throw getAPIError(from: response)
                }
                return
            }
            throw APIError.unknown
        }
        throw APIError.badURL
    }

    // MARK: Album Files (Combine)
    
    /**
     GET /{albumsEndpoint}/:id/:filename}
     */
//    @available(*, deprecated, message: "Use 'getFile(album:filename) async throws -> Data' instead")
    public func getAlbumFile(_ id: String, filename: String) throws -> AnyPublisher<Data, APIError> {
        return apiGetPublisher(albumsEndpoint, id: id, filename: filename)
    }

//    @available(*, deprecated, message: "Use 'postFile(albumId:filename:data) async throws' instead")
    public func postAlbumFile(_ album: Album, filename: String) throws -> AnyPublisher<Void, APIError> {
        if let directory = album.directory {
            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localAlbumURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                return apiPostPublisher(albumsEndpoint, id: album.id, filename: filename, data: data)
            }
        }
        throw APIError.unknown
    }

//    @available(*, deprecated, message: "Use 'putFile(albumId:filename:data) async throws' instead")
    public func putAlbumFile(_ album: Album, filename: String) throws -> AnyPublisher<Void, APIError> {
        if let directory = album.directory {
            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localAlbumURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                return apiPutPublisher(albumsEndpoint, id: album.id, filename: filename, data: data)
            }
        }
        throw APIError.unknown
    }

//    @available(*, deprecated, message: "Use 'deleteFile(albumId:filename) async throws' instead")
    public func deleteAlbumFile(_ id: String, filename: String) throws -> AnyPublisher<Void, APIError> {
        return apiDeletePublisher(albumsEndpoint, id: id, filename: filename)
    }

    // MARK: - Singles

    /**
     GET /{singlesEndpoint}?fields&offset&limit

     HTTP call to return a list of single metadata.  Use fields to limit the metadata for each single and offset/limit to page through the results

     - Parameter fields: A comma separated list of fields to be include in the result.  nil for all fields
     - Parameter offset: Offset in list of all singles, to start the result
     - Parameter limit: Maximum number of singles to return

     - Returns: APISingles
     */
    public func getSingles(fields: String? = nil, offset: Int? = nil, limit: Int? = nil) async throws -> APISingles {
        if let url = URL(string: serverURL) {
            var endPoint = url.appendingPathComponent(singlesEndpoint)
            var queryItems: [(String,String)] = []
            if let fields = fields {
                queryItems.append(("fields",fields))
            }
            if let offset = offset {
                queryItems.append(("offset",String(offset)))
            }
            if let limit = limit {
                queryItems.append(("limit",String(limit)))
            }
            if !queryItems.isEmpty {
                endPoint.append(queryItems: queryItems)
            }
            var request = URLRequest(url: endPoint)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            if let singles = try? JSONDecoder().decode(APISingles.self, from: data) {
                return singles
            }
            throw getAPIError(from: response)
        }
        throw APIError.badURL
    }

    /**
     HEAD /{singlesEndpoint}/:id

     HTTP HEAD call to determine if a specific single exits.

     - Parameter singleId: Unique id of specific single to check

     - Returns: true if single exists, false otherwise.
     */
    public func head(singleId: String) async throws -> Bool {
        if let endPoint = URL(string: singlesEndpoint)?.appendingPathComponent(singleId) {
            var request = URLRequest(url: endPoint)
            request.httpMethod = "HEAD"
            let (_, response) = try await URLSession.shared.data(for: request)
            let error = getAPIError(from: response)
            switch error {
            case .ok:
                return true
            case .notFound:
                return false
            default:
                throw error
            }
        }
        throw APIError.badURL
    }

    /**
     GET /{singlesEndpoint}/:id

     HTTP call to retrieve a specfic singles metadata.  A separate call to getFile(:) must be made to retrieve the associated audio file.

     - Parameter singleId: Unique id of specific single to retrieve

     - Returns: Single
     */
    public func get(singleId: String) async throws -> Single {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            if let single = Single.decodeFrom(json: data) {
                return single
            }
            throw getAPIError(from: response)
        }
        throw APIError.badURL
    }

    /**
     POST single metadata and audio file to server

     POSTs single metadata and associated audio file to server.  Setting skipFiles to true will skip the associated audio file.

     POST /(singlesEndpoint}/:id

     If not skipFiles:

        POST /{singlesEndpoint}/:id/:filename

     - Parameter single: Single metadata to post

     - Parameter skipFiles: Set to true to post metadata without files

     - Returns: Transaction
     */
    public func post(single: Single, skipFiles: Bool = false) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let json = single.json {
                let (data, response) = try await URLSession.shared.upload(for: request, from: json)
                if let transaction = Transaction.decodeFrom(json: data) {
                    if !skipFiles,
                       let directory = single.directory {
                        let filename =  single.filename
                        let localSingleURL = fileRootURL.appendingPathComponent(directory)
                        let localFileURL = localSingleURL.appendingPathComponent(filename)
                        var fileRequest = URLRequest(url: endPoint.appendingPathComponent(filename))
                        fileRequest.httpMethod = "POST"
                        let (_, _) = try await URLSession.shared.upload(for: fileRequest, fromFile: localFileURL)
                    }
                    return transaction
                }
                throw getAPIError(from: response)
            }
            throw APIError.badRequest
        }
        throw APIError.badURL

    }

    /**
     PUT single metadata to server

     PUTs single metadata to server.  Setting skipFiles to false also PUT associated audio file to server.

     PUT /{singlesEndpoint}/:id

     If not skipFiles:

        PUT /{singlesEndpoint}/:id/:filename

     - Parameter single: Single metadata to put

     - Parameter skipFiles: Set to false to include associated audio file

     - Returns: Transaction
     */
    public func put(single: Single, skipFiles: Bool = true) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let json = single.json {
                let (data, response) = try await URLSession.shared.upload(for: request, from: json)
                if let transaction = Transaction.decodeFrom(json: data) {
                    if !skipFiles, let directory = single.directory {
                        let filename =  single.filename
                        let localSingleURL = fileRootURL.appendingPathComponent(directory)
                            let localFileURL = localSingleURL.appendingPathComponent(filename)
                            var fileRequest = URLRequest(url: endPoint.appendingPathComponent(filename))
                            fileRequest.httpMethod = "PUT"
                            let (_, _) = try await URLSession.shared.upload(for: fileRequest, fromFile: localFileURL)
                    }
                    return transaction
                }
                throw getAPIError(from: response)
            }
            throw APIError.badRequest
        }
        throw APIError.badURL
    }

    /**
     DELETE /{singlesEndpoint}/:id

     Deletes single and associated audio file from the server.

     - Parameter singleId: Unique id of the single to be deleted

     - Returns: Transaction
     */
     public func delete(singleId: String) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "DELETE"

            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(Transaction.self, from: data)
        }
        throw  APIError.badURL
    }


    // MARK: Singles (Combine)
    
    /**
     GET /{singlesEndpoint}?fields&offset&limit
     */
//    @available(*, deprecated, message: "Use 'getSingles(fields:offset:limit:) async throws -> APISingles' instead")
    public func getSingles(fields: String? = nil, offset: Int? = nil, limit: Int? = nil) throws -> AnyPublisher<APISingles, APIError> {
        return apiGetListPublisher(singlesEndpoint, fields: fields, offset: offset, limit: limit)
            .decode(type: APISingles.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                }
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }

    /**
     GET /{singlesEndpoint}/:id
     */
//    @available(*, deprecated, message: "Use 'get(singleId:) async throws -> Single' instead")
    public func getSingle(_ id: String) throws -> AnyPublisher<Single, APIError> {
        return apiGetPublisher(singlesEndpoint, id: id)
            .decode(type: Single.self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                }
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }
    
    /**
     POST /{singlesEndpoint}/:id
     */
    public func postSingle(_ single: Single) throws -> AnyPublisher<Void, APIError> {
        let publisher = PassthroughSubject<AnyPublisher<Void, APIError>, APIError>()
        if let json = single.json,
           let directory = single.directory {
            let metaDataPostPublisher = apiPostPublisher(singlesEndpoint, id: single.id, data: json)
            
            metaDataPostPublisher
                .sink(
                    receiveCompletion: { [self] completion in
                        switch completion {
                        case .failure(let apiError):
                            publisher.send(completion: .failure(apiError))
                            
                        case .finished:
                            let filename = single.filename
                            let localSingleURL = fileRootURL.appendingPathComponent(directory)
                            let localFileURL = localSingleURL.appendingPathComponent(filename)
                            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                                let fileDataPostPublisher = apiPostPublisher(singlesEndpoint, id: single.id, filename: filename, data: data)
                                publisher.send(fileDataPostPublisher)
                            }
                            publisher.send(completion: .finished)
                            
                            
                        }
                        
                    },
                    receiveValue: { _ in } )
                .store(in: &subscriptions)
            
            
            return publisher
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        throw APIError.unknown
    }
            
    /**
     PUT /{singlesEndpoint}/:id
     */
    public func putSingle(_ single: Single) throws -> AnyPublisher<Void, APIError> {
        if let json = single.json {
            return apiPutPublisher(singlesEndpoint, id: single.id, data: json)
                .eraseToAnyPublisher()
        }
        throw APIError.unknown
    }
    
    /**
     DELETE /{singlesEndpoint}/:id
     */
    public func deleteSingle(_ id: String) throws -> AnyPublisher<Void, APIError> {
        return apiDeletePublisher(singlesEndpoint, id: id)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Single Files

    /**
     GET /{singlesEndpoint)}/:id/:filename}

     Retrieve a single file contents from a single

     - Parameter singleId: Unique identifier of single

     - Parameter filename: Filename of the file to retrieve

     - Returns: Contents of the file (Data)

     - Throws: APIError
     */
    public func getFile(singleId: String, filename: String) async throws -> Data {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId).appendingPathComponent(filename)

            let (data, _) = try await URLSession.shared.data(from: endpointURL)
            return data
        }
        throw APIError.badURL
    }

    /**
     POST /{singlesEndpoint}/:id/:filename}

     Post a file contents related to the single.

     - Parameter single: Previously retrieved (get(singleId:) metadata for the single

     - Parameter filename: Filename of the file to post

     - Parameter data: Content of file to post

     - Returns: No returrn value

     - Throws: APIError
     */
    public func postFile(singleId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")

            let (_, response) = try await URLSession.shared.upload(for: request, from: data)
            let apiError = getAPIError(from: response)
            if apiError == .ok {
                return
            }
            throw apiError
        }
        throw APIError.badURL

    }

    /**
     POST /{singlesEndpoint}/:id/:filename}

     Post a file contents related to the single.  The file to post will be found on the local disk in the directory specified in the Single metadata

     - Parameter single: Previously retrieved (get(singleId:) metadata for the single

     - Parameter filename: Filename of the file to post

     - Returns: No returrn value

     - Throws: APIError
     */
    public func postFile(single: Single, filename: String) async throws {
        if let directory = single.directory {
            let localSingleURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localSingleURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = "POST"
                    request.setValue(contentType, forHTTPHeaderField: "Content-Type")

                    let (_, response) = try await URLSession.shared.upload(for: request, from: data)
                    let apiError = getAPIError(from: response)
                    if apiError == .ok {
                        return
                    }
                    throw apiError
                }
                throw APIError.badURL
            }
        }
        throw APIError.badRequest
    }

    /**
     PUT /{singleEndpoint}/:id/:filename}

     Replace a file related to the single.

     - Parameter singleId: Unique identifier of associated single

     - Parameter filename: Filename of the file to put

     - Parameter data: Contents of the file to put

     - Returns: No return value

     - Throws: APIError
     */
    public func putFile(singleId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "PUT"
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")

            let (_, response) = try await URLSession.shared.upload(for: request, from: data)
            let apiError = getAPIError(from: response)
            if apiError == .ok {
                return
            }
            throw apiError
        }
        throw APIError.badURL
    }

    /**
     PUT /{singleEndpoint}/:id/:filename}

     Put a file related to the single.  The file to put will be found on the local disk in the directory specified in the Single metadata

     - Parameter single: Previously retrieved (get(singleId:) metadata for the single

     - Parameter filename: Filename of the file to put

     - Returns: Contents of the file (Data)

     - Throws: APIError
     */
    public func putFile(single: Single, filename: String) async throws {
        if let directory = single.directory {
            let localSingleURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localSingleURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = "PUT"
                    request.setValue(contentType, forHTTPHeaderField: "Content-Type")

                    let (_, response) = try await URLSession.shared.upload(for: request, from: data)
                    let apiError = getAPIError(from: response)
                    if apiError == .ok {
                        return
                    }
                    throw apiError
                }
                throw APIError.badURL
            }
        }
        throw APIError.badRequest
    }

    public func deleteFile(singleId: String, filename: String) async throws {
        if let url = URL(string: serverURL) {
            let endPointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId).appendingPathComponent(filename)
            var request = URLRequest(url: endPointURL)
            request.httpMethod = "DELETE"

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    throw getAPIError(from: response)
                }
                return
            }
            throw APIError.unknown
        }
        throw APIError.badURL
    }

    // MARK: Single Files (Combine)
    
    /**
     GET /{singlesEndpoint}/:id/:filename
     */
    public func getSingleFile(_ id: String, filename: String) throws -> AnyPublisher<Data, APIError> {
        return apiGetPublisher(singlesEndpoint, id: id, filename: filename)
    }
    
    public func postSingleFile(_ single: Single, filename: String) throws -> AnyPublisher<Void, APIError> {
        if let directory = single.directory {
            let localSingleURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localSingleURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                return apiPostPublisher(singlesEndpoint, id: single.id, filename: filename, data: data)
            }
        }
        throw APIError.unknown
    }
    
    public func putSingleFile(_ single: Single, filename: String) throws -> AnyPublisher<Void, APIError> {
        if let directory = single.directory {
            let localSingleURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localSingleURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                return apiPutPublisher(singlesEndpoint, id: single.id, filename: filename, data: data)
            }
        }
        throw APIError.unknown
    }
    
    public func deleteSingleFile(_ id: String, filename: String) throws -> AnyPublisher<Void, APIError> {
        return apiDeletePublisher(singlesEndpoint, id: id, filename: filename)
    }
    
    // MARK: - Playlists

    /**
     GET /{playlistsEndpoint}?fields&offset&limit

     HTTP call to return a list of playlists.  Use fields to limit the metadata for each playlist and offset/limit to page through the results

     - Parameter fields: A comma separated list of fields to be include in the result.  nil for all fields
     - Parameter offset: Offset in list of all playlists, to start the result
     - Parameter limit: Maximum number of playlists to return

     - Returns: APIPlaylists
     */
    public func getPlaylists(fields: String? = nil, offset: Int? = nil, limit: Int? = nil) async throws -> APIPlaylists {
        if let url = URL(string: serverURL) {
            var endPoint = url.appendingPathComponent(playlistsEndpoint)
            var queryItems: [(String,String)] = []
            if let fields = fields {
                queryItems.append(("fields",fields))
            }
            if let offset = offset {
                queryItems.append(("offset",String(offset)))
            }
            if let limit = limit {
                queryItems.append(("limit",String(limit)))
            }
            if !queryItems.isEmpty {
                endPoint.append(queryItems: queryItems)
            }
            var request = URLRequest(url: endPoint)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            if let playlists = try? JSONDecoder().decode(APIPlaylists.self, from: data) {
                return playlists
            }
            throw getAPIError(from: response)
        }
        throw APIError.badURL
    }

    /**
     HEAD /{playlistsEndpoint}/:id

     HTTP HEAD call to determine if a specific playlist exits.

     - Parameter playlistId: Unique id of specific playlist to check

     - Returns: true if playlist exists, false otherwise.
     */
    public func head(playlistId: String) async throws -> Bool {
        if let endPoint = URL(string: playlistsEndpoint)?.appendingPathComponent(playlistId) {
            var request = URLRequest(url: endPoint)
            request.httpMethod = "HEAD"
            let (_, response) = try await URLSession.shared.data(for: request)
            let error = getAPIError(from: response)
            switch error {
            case .ok:
                return true
            case .notFound:
                return false
            default:
                throw error
            }
        }
        throw APIError.badURL
    }

    /**
     GET /{playlistsEndpoint}/:id

     HTTP call to retrieve a specfic playlist's metadata.

     - Parameter playlistId: Unique id of specific playlist to retrieve

     - Returns: playlist
     */
    public func get(playlistId: String) async throws -> Playlist {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlistId)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            if let playlist = Playlist.decodeFrom(json: data) {
                return playlist
            }
            throw getAPIError(from: response)
        }
        throw APIError.badURL
    }

    /**
     POST playlist metadata to server

     POSTs playlist metadata to server.

     POST /(playlistsEndpoint}/:id

     - Parameter playlist: Playlist metadata to post

     - Returns: Transaction
     */
    public func post(playlist: Playlist) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlist.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let json = playlist.json {
                let (data, response) = try await URLSession.shared.upload(for: request, from: json)
                if let transaction = Transaction.decodeFrom(json: data) {
                    return transaction
                }
                throw getAPIError(from: response)
            }
            throw APIError.badRequest
        }
        throw APIError.badURL
    }

    /**
     PUT playlist metadata to server

     PUTs playlist metadata to server.

     PUT /{playlistsEndpoint}/:id

     - Parameter playlist: Playlist metadata to put

     - Returns: Transaction
     */
    public func put(playlist: Playlist) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlist.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let json = playlist.json {
                let (data, response) = try await URLSession.shared.upload(for: request, from: json)
                if let transaction = Transaction.decodeFrom(json: data) {
                    return transaction
                }
                throw getAPIError(from: response)
            }
            throw APIError.badRequest
        }
        throw APIError.badURL
    }

    /**
     DELETE /{playlistsEndpoint}/:id

     Deletes playlist from the server.

     - Parameter playlistId: Unique id of the playlist to be deleted

     - Returns: Transaction
     */
     public func delete(playlistId: String) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlistId)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "DELETE"

            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(Transaction.self, from: data)
        }
        throw  APIError.badURL
    }



}
