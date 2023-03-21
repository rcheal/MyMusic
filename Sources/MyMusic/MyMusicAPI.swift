//
//  MyMusicAPI.swift
//
//
//  Created by Robert Cheal on 2/12/21.
//

import Foundation

#if !os(Linux)

/// URL prefix for server access - `"v1"`
public let serverEndpoint = "v1"

/// URL prefix for album access - `"v1/albums"`
public let albumsEndpoint = "v1/albums"
/// URL prefix for single access - `"v1/singles"`
public let singlesEndpoint = "v1/singles"
/// URL prefix for playlist access - `"v1/playlists"`
public let playlistsEndpoint = "v1/playlists"
/// URL prefix for transaction access = "v1/transactions"
public let transactionsEndpoint = "v1/transactions"

/// Swift API for MyMusicServer RESTful web api
///
/// This is version 1 of the MyMusicServer web api.
///
/// The URL prefix for these services is http://{server-name}:{port}/v1.
/// - albumsEndpoint = "v1/albums"
/// - singlesEndpoint = "v1/singles"
/// - playlistsEndpoint = "v1/playlists"
public class MyMusicAPI {

    /// URL of MyMusicServer to connect to
    public var serverURL: String = ""
    /// Globally shared api class
    public static var shared = MyMusicAPI()
    /// URL of local directory containing associated files.  Used by some file upload (`post` and `put`) calls to find file contents.
    public var fileRootURL = URL(fileURLWithPath: "")


    /// Initiator if more than one api class is requred (for instance copying metadata between servers).  In normal cases ``shared`` should be used.
    public init() {


    }

    /// Convert URLResponse into APIError
    ///
    /// - Parameter response: response from URLSession
    /// - Returns: Corresponding ``APIError``
    private func getAPIError(from response: URLResponse) -> APIError {
        guard let httpResponse = response as? HTTPURLResponse else {
            return APIError.unknown
        }
        return APIError(status: httpResponse.statusCode)
    }


    // MARK: - Server

    /// Returns a structure containing general server infomation
    ///
    ///  Results in the following web service request:
    ///  ```
    ///  GET /v1
    ///  ```
    /// - Returns: Server status in ``APIServerStatus``
    /// - Throws: ``APIError``
    public func getServerStatus() async throws -> APIServerStatus {
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

    /// Get a list of transactions
    ///
    /// Returns a list of all transactions from `startTime` until now.  If `startTime` is
    /// omitted - returns a list of all transactions.
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{transactionsEndPoint}?startTime
    /// ```
    /// - Parameter startTime: Start timestamp of transactions to return.  ISO 8601 (yyyy-MM-dd'T'HH:mm:ss.SSS'Z').
    /// - Returns: ``APITransactions``
    /// - Throws: ``APIError``
    public func getTransactions(startTime: String? = nil) async throws -> APITransactions {
        if let url = URL(string: serverURL) {
            var endPoint = url.appendingPathComponent(transactionsEndpoint)
            var queryItems : [(String,String)] = []
            if let startTime = startTime {
                queryItems.append(("startTime", startTime))
                endPoint.append(queryItems: queryItems)
            }
            var request = URLRequest(url: endPoint)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            if let transaction = try? JSONDecoder().decode(APITransactions.self, from: data) {
                return transaction
            }
            throw getAPIError(from: response)
        }
        throw APIError.badURL
    }

    // MARK: - Albums

    ///  Get a list of album metadata
    ///
    ///  Returns a list of all album metadata or a subset of album metadata, defined by fields, offset and limit
    ///
    ///  Results in the following web service request:
    ///  ```
    ///  GET /{albumsEndpoint}?fields&offset&limit
    ///  ```
    /// - Parameters:
    ///     - fields: A comma separated list of fields to be included in the result.  Set to nil for all fields.
    ///     - offset: Offset in list of all albums, to start the result
    ///     - limit: Maximum number of albums to return
    /// - Returns: ``APIAlbums``
    /// - Throws: ``APIError``
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

    /// Determine if a specific album exists
    ///
    /// Results in the following web service request:
    /// ```
    /// HEAD /{albumsEndpoint}/:id
    /// ```
    /// where ``albumsEndpoint``
    /// - Parameter albumId: Unique id of specific album to check
    /// - Returns: `true` if album exists, `false` otherwise
    /// - Throws: ``APIError``
    public func head(albumId: String) async throws -> Bool {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
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

    /// Retrieve metadata for a specific album
    ///
    /// Separate calls to ``get(albumId:filename:)`` must be made to retrieve audio files and cover artwork
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{albumsEndpoint}/:id
    /// ```
    /// - Parameter albumId: Unique id of specific album to retrieve
    /// - Returns: ``Album``
    /// - Throws: ``APIError``
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

    /// Uploads album metadata and file(s) to server
    ///
    /// Uploads album metatdata and associated audio and artwork files to the server.
    /// The albums must not already exist on the server.
    ///
    /// Results in the following web service request(s):
    /// ```
    /// POST /{albumsEndpoint}/:id
    /// ```
    /// If not skipFiles, then for each audio or artwork file:
    /// ```
    /// POST /{albumsEndpoint}/:id:filename
    /// ```
    /// - Parameters:
    ///     - album: Album metadata to upload
    ///     - skipFiles: Set to true to upload metadata without associated files
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
    public func post(album: Album, skipFiles: Bool = false) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = postMethod
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
                             fileRequest.httpMethod = postMethod
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

    /// Replaces album metadata and file(s) on server
    ///
    /// By default only replaces metadata.  Setting `skipFiles` to `false` will also replace audio and artwork files
    ///
    /// Results in the following web server request(s):
    /// ```
    /// PUT /{albumsEndpoint}/:id
    /// ```
    /// If not `skipFiles`, then for each audio or artwork file:
    /// ```
    /// PUT /{albumsEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - album: New album metadata
    ///   - skipFiles: Set to false to include associated files
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
    public func put(album: Album, skipFiles: Bool = true) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = putMethod
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
                            fileRequest.httpMethod = putMethod
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

    /// Removes album metadata and associated files from the server
    ///
    /// Results in the following web service request:
    /// ```
    /// DELETE /{albumsEndpoint}/:id
    /// ```
    /// - Parameter albumId: Unique id of the album to be deleted
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
    public func delete(albumId: String) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = deleteMethod

            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(Transaction.self, from: data)
        }
        throw  APIError.badURL
    }

    // MARK: - Album Files

    /// Retrieves a file associated with an album from the server
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{albumsEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - albumId: Unique id of the associated album
    ///   - filename: Name of the file to retrieve
    /// - Returns: Contents of file
    /// - Throws: ``APIError``
    public func get(albumId: String, filename: String) async throws -> Data {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId).appendingPathComponent(filename)

            let (data, _) = try await URLSession.shared.data(from: endpointURL)
            return data
        }
        throw APIError.badURL
    }

    /// Upload a single associated file to the server
    ///
    /// The file must not already exist on the server
    ///
    /// Results in the following web service request:
    /// ```
    /// POST /{albumsEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - albumId: Unique identifier of the associated album
    ///   - filename: Name of the file to upload; this must match the name in the album metadata
    ///   - data: Content of the file to upload
    /// - Throws: ``APIError``
    public func post(albumId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = postMethod
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

    /// Upload a single associated file to the server
    ///
    /// The file must not already exist on the server.
    /// The file to upload will be found on the local disk in the directory specified in the Album metadata.
    ///
    /// Results in the following web service request:
    /// ```
    /// POST /{albumsEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - album: Album metadata for the associated file.
    ///   - filename: Name of the file to upload.  This should match the value in the album metadata.
    /// - Throws: ``APIError``
    public func post(album: Album, filename: String) async throws {
        if let directory = album.directory {
            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localAlbumURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = postMethod
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

    /// Replace a single file related to an album
    ///
    /// Results in the following web service request:
    /// ```
    /// PUT /{albumsEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - albumId: Unique identifier of the associated album
    ///   - filename: Name of file to replace
    ///   - data: Content of new file
    /// - Throws: ``APIError``
    public func put(albumId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = putMethod
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

    /// Replace a single file related to an album
    ///
    /// The file must already exist on the server.
    /// The file to upload will be found on the local disk in the directory specified in the Album metadata.
    ///
    /// Results in the following web service request:
    /// ```
    /// PUT /{albumsEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - album: Album metadata for the associated file
    ///   - filename: Name of the file to upload.  This should match the value in the album metadata.
    /// - Throws: ``APIError``
    public func put(album: Album, filename: String) async throws {
        if let directory = album.directory {
            let localAlbumURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localAlbumURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(album.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = putMethod
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

    /// Delete a single file related to an album
    ///
    /// Results in the following web service request:
    /// ```
    /// DELETE /{albumsEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - albumId: Unique identifier of the associated album
    ///   - filename: Name of the file to delete
    /// - Throws: ``APIError``
    public func delete(albumId: String, filename: String) async throws {
        if let url = URL(string: serverURL) {
            let endPointURL = url.appendingPathComponent(albumsEndpoint).appendingPathComponent(albumId).appendingPathComponent(filename)
            var request = URLRequest(url: endPointURL)
            request.httpMethod = deleteMethod

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

    // MARK: - Singles

    /// Get a list of single metadata
    ///
    /// Returns a list of all single metadata or a subset of single metadata, defined by `fields`, `offset` and `limit`
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{singlesEndpoint}?fields&offset&limit
    /// ```
    /// - Parameters:
    ///   - fields: A comma separated list of fields to be included in the result.  Set to nil for all fields.
    ///   - offset: Offset in list of all singles, to start the result
    ///   - limit: Maximum nummber of singles to return
    /// - Returns: ``APISingles``
    /// - Throws: ``APIError``
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

    /// Determine if a specific single exists
    ///
    /// Results in the following web service request:
    /// ```
    /// HEAD /{singlesEndpoint}/:id
    /// ```
    /// - Parameter singleId: Unique id of specific single to check
    /// - Returns: `true` if single exists, `false` otherwise
    /// - Throws: ``APIError``
    public func head(singleId: String) async throws -> Bool {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
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

    /// Retrieve metadata for a specific single
    ///
    /// A separate call to ``get(singleId:filename:)`` must be made to retrieve the associated audio file.
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{singlessEndpoint}/:{id}
    /// ```
    /// - Parameter albumId: Unique id of specific single to retrieve
    /// - Returns: ``Single``
    /// - Throws: ``APIError``
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

    /// Uploads single metadata and audio file to server
    ///
    /// The single must not already exist on the server.
    ///
    /// Results in the following web service request:
    /// ```
    /// POST /{singlesEndpoint}/:id
    /// ```
    /// If not skipFiles, then:
    /// ```
    /// POST /{singlesEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - single: Single metadata to upload
    ///   - skipFiles: Set to `true` to upload metadata without the audio file
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
    public func post(single: Single, skipFiles: Bool = false) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = postMethod
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
                        fileRequest.httpMethod = postMethod
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

    /// Replaces single metadata and audio file on server
    ///
    /// By default only replaces metadata.  Setting `skipFiles` to `false` will also replace the associated
    /// audio file.
    ///
    /// Results in the following web server request:
    /// ```
    /// PUT /{SinglesEndpoint}/:id
    /// ```
    /// If not `skipfiles`, then:
    /// ```
    /// PUT /{SinglesEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - single: New single metadata
    ///   - skipFiles: Set to false to include audio files
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
    public func put(single: Single, skipFiles: Bool = true) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = putMethod
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let json = single.json {
                let (data, response) = try await URLSession.shared.upload(for: request, from: json)
                if let transaction = Transaction.decodeFrom(json: data) {
                    if !skipFiles, let directory = single.directory {
                        let filename =  single.filename
                        let localSingleURL = fileRootURL.appendingPathComponent(directory)
                            let localFileURL = localSingleURL.appendingPathComponent(filename)
                            var fileRequest = URLRequest(url: endPoint.appendingPathComponent(filename))
                            fileRequest.httpMethod = putMethod
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

    /// Removes single metadata and audio file from the server
    ///
    /// Results in the folllowing web service request:
    /// ```
    /// DELETE /{singlesEndpoint}/:id
    /// ```
    /// - Parameter singleId: Unique id of the single to be deleted
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
     public func delete(singleId: String) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = deleteMethod

            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(Transaction.self, from: data)
        }
        throw  APIError.badURL
    }


    // MARK: - Single Files

    /// Retrieves the audio file for a single
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{albumsEndpoint}/:id:filename
    /// ```
    /// - Parameters:
    ///   - singleId: Unique identifier of single
    ///   - filename: Name of audio file
    /// - Returns: Contents of the audio file (Data)
    /// - Throws: ``APIError``
    public func get(singleId: String, filename: String) async throws -> Data {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId).appendingPathComponent(filename)

            let (data, _) = try await URLSession.shared.data(from: endpointURL)
            return data
        }
        throw APIError.badURL
    }

    /// Upload the audio file associated with a single
    ///
    /// The file must not already exist on the server.
    ///
    /// Results in the following web service request:
    /// ```
    /// POST /{singlesEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - singleId: Unique identifier of the associated single
    ///   - filename: Name of the file to upload; this must match the name in the single metadata
    ///   - data: Content of the file to upload
    /// - Throws: ``APIError``
    public func post(singleId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = postMethod
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

    /// Upload the audio file associated with a single
    ///
    /// The file must not already exist on the server.
    ///
    /// Results in the following web service request:
    /// ```
    /// POST /{singlesEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - single: Single metadata for the associated audio file
    ///   - filename: Name of the audio file to upload.  This should match the value in the single metadata
    /// - Throws: ``APIError``
    public func post(single: Single, filename: String) async throws {
        if let directory = single.directory {
            let localSingleURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localSingleURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = postMethod
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

    /// Replace an audio file related to a Single
    ///
    /// Results in the following web service request:
    /// ```
    /// PUT /{singlesEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - singleId: Unique identifier of the associated single
    ///   - filename: Name of the audio file to replace
    ///   - data: Content of new audio file
    /// - Throws: ``APIError``
    public func put(singleId: String, filename: String, data: Data) async throws {
        if let url = URL(string: serverURL) {
            var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId)
            let contentType = "application/octet-stream"
            endpointURL.appendPathComponent(filename)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = putMethod
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

    /// Replace an audio file related to a Single
    ///
    /// Results in the following web service request:
    /// ```
    /// PUT /{singlesEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - single: Single metadata for the associated audio file
    ///   - filename: Name of the audio file to replace
    /// - Throws: ``APIError``
    public func put(single: Single, filename: String) async throws {
        if let directory = single.directory {
            let localSingleURL = fileRootURL.appendingPathComponent(directory)
            let localFileURL = localSingleURL.appendingPathComponent(filename)
            if let data = FileManager.default.contents(atPath: localFileURL.path) {
                if let url = URL(string: serverURL) {
                    var endpointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(single.id)
                    let contentType = "application/octet-stream"
                    endpointURL.appendPathComponent(filename)
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = putMethod
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

    /// Delete an audio file related to a single
    ///
    /// Results in the following web service request:
    /// ```
    /// DELETE /{singlesEndpoint}/:id/:filename
    /// ```
    /// - Parameters:
    ///   - singleId: Unique identifier of the associated single
    ///   - filename: Name of the audio file to delete
    /// - Throws: ``APIError``
    public func delete(singleId: String, filename: String) async throws {
        if let url = URL(string: serverURL) {
            let endPointURL = url.appendingPathComponent(singlesEndpoint).appendingPathComponent(singleId).appendingPathComponent(filename)
            var request = URLRequest(url: endPointURL)
            request.httpMethod = deleteMethod

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

    // MARK: - Playlists

    /// Get a list of playlist metadata
    ///
    /// Returns a list of all playlist metatdata or a subset of playlist metadata, defined by `fields`, `offset` and `limit`
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{playlistsEndpoint}?fields&offset&limit
    /// ```
    /// - Parameters:
    ///   - fields: A comma separated list of fields to be included in the result.  Set to nil for all fields.
    ///   - offset: Offset in list of all playlists, to start the result
    ///   - limit: Maximum number of playlists to return.  Set to nil for all playlists
    /// - Returns: ``APIPlaylists``
    /// - Throws: ``APIError``
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

    /// Determine if a specific playlist exists
    ///
    /// Results in the following web service request:
    /// ```
    /// HEAD /{playlistsEndpoint}/:id
    /// ```
    /// - Parameter playlistId: Unique id of specific playlist to check
    /// - Returns: `true` if playlist exists, `false` otherwise
    /// - Throws: ``APIError``
    public func head(playlistId: String) async throws -> Bool {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlistId)
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

    /// Retrieve a specific playlist
    ///
    /// Results in the following web service request:
    /// ```
    /// GET /{playlistsEndpoint}/:id
    /// ```
    /// - Parameter playlistId: Unique id of specific playlist to retrieve
    /// - Returns: ``Playlist``
    /// - Throws: ``APIError``
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

    /// Uploads a playlist to the server
    ///
    /// The playlist must not already exist on the server.
    ///
    /// Results in the following web service requests:
    /// ```
    /// POST /{playlistsEndpoint}/:id
    /// ```
    /// - Parameter playlist: Playlist to upload
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
    public func post(playlist: Playlist) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlist.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = postMethod
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

    /// Replaces a playlist on the server
    ///
    /// Results in the following web service request:
    /// ```
    /// PUT /{playlistsEndpoint}/:id
    /// ```
    /// - Parameter playlist: New Playlist
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
    public func put(playlist: Playlist) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endPoint = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlist.id)
            var request = URLRequest(url: endPoint)
            request.httpMethod = putMethod
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

    /// Remove playlist from the server
    ///
    /// Results in the following web service request:
    /// ```
    /// DELETE /{playlistsEndpoint}/:id
    /// ```
    /// - Parameter playlistId: Unique id of the playlist to be deleted
    /// - Returns: ``Transaction``
    /// - Throws: ``APIError``
     public func delete(playlistId: String) async throws -> Transaction {
        if let url = URL(string: serverURL) {
            let endpointURL = url.appendingPathComponent(playlistsEndpoint).appendingPathComponent(playlistId)
            var request = URLRequest(url: endpointURL)
            request.httpMethod = deleteMethod

            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(Transaction.self, from: data)
        }
        throw  APIError.badURL
    }

}

#endif
