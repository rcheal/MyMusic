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

/*
    200 OK
    201 Created
    202 Accepted
    204 No Content
 
    400 Bad Request
    401 Unauthorized
    404 Not found
    409 Conflict
 
    500 Internal Server Error
    501 Not Implemented
    503 Service Unavailable
 
 */

public struct APIResult {
    var data: Data?
    var response: HTTPURLResponse?
}

public enum APIError: Error, Equatable {
    case unknown
    case notFound
    case conflict
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case networkError(from: URLError)
    case badURL
}

@available(OSX 10.15, *)
public class MyMusicAPI {
    
    public var serverURL: String = ""
    public static var shared = MyMusicAPI()
    public var fileRootURL: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("MyMusicAPI")
    
    private var subscriptions = Set<AnyCancellable>()
    
    public init() {
        
        
    }
    
    private func getFilenames(album: Album) -> [String] {
        var filenames = [String]()
        // Add artwork filenames
        let artworkCount = album.artworkCount()
        if artworkCount > 0 {
            for index in 0..<artworkCount {
                if let filename = album.artRef(index)?.filename {
                    filenames.append(filename)
                }
            }
        }
        // Add audio track filenames
        for content in album.contents {
            if let single = content.single {
                filenames.append(single.filename)
            } else if let composition = content.composition {
                for movement in composition.movements {
                    filenames.append(movement.filename)
                }
            }
        }
        return filenames
    }
    
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
    
    // MARK: Server
    
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
    
    // MARK: Albums

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
                            let filenames = getFilenames(album: album)
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
    public func putAlbum(_ album: Album) throws -> AnyPublisher<Void, APIError> {
        if let json = album.json {
            return apiPutPublisher(albumsEndpoint, id: album.id, data: json)
                .eraseToAnyPublisher()
        }
        throw APIError.unknown
    }
    
    /**
     DELETE /{albumsEndpoint}/:id
     */
    public func deleteAlbum(_ id: String) throws -> AnyPublisher<Void, APIError> {
        return apiDeletePublisher(albumsEndpoint, id: id)
            .eraseToAnyPublisher()
    }
    
    // MARK: Album Files
    
    /**
     GET /{albumsEndpoint}/:id/:filename}
     */
    public func getAlbumFile(_ id: String, filename: String) throws -> AnyPublisher<Data, APIError> {
        return apiGetPublisher(albumsEndpoint, id: id, filename: filename)
    }
    
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
    
    public func deleteAlbumFile(_ id: String, filename: String) throws -> AnyPublisher<Void, APIError> {
        return apiDeletePublisher(albumsEndpoint, id: id, filename: filename)
    }
    
    // MARK: Singles
    
    /**
     GET /{singlesEndpoint}?fields&offset&limit
     */
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
    
    // MARK: Single Files
    
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
    
    // MARK: Playlists
    
    /**
     GET /{playlistsEndpoint}?fields&offset&limit
     */
//    public func getPlaylists(fields: String? = nil, offset: Int? = nil, limit: Int? = nil) throws -> AnyPublisher<APIPlaylists, APIError> {
//        return apiGetListPublisher(playlistsEndpoint, fields: fields, offset: offset, limit: limit)
//            .decode(type: APIPlaylists.self, decoder: JSONDecoder())
//            .mapError { error in
//                if let error = error as? APIError {
//                    return error
//                }
//                return APIError.unknown
//            }
//            .eraseToAnyPublisher()
//    }

//    public func getPlaylist(_ id: String) throws -> AnyPublisher<Playlist, APIError> {
//        return apiGetPublisher(playlistsEndpoint, id: id)
//            .decode(type: Playlist.self, decoder: JSONDecoder())
//            .mapError { error in
//                if let error = error as? APIError {
//                    return error
//                }
//                return APIError.unknown
//            }
//            .eraseToAnyPublisher()
//    }
    
//    public func postPlaylist(_ playlist: Playlist) throws {
//        
//    }
    
//    public func putPlaylist(_ playlist: Playlist) throws {
//        
//    }
    
//    public func deletePlaylist(_ playlist: Playlist) throws {
//
//    }
    
}
