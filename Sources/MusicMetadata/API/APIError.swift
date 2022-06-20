//
//  File.swift
//  
//
//  Created by Robert Cheal on 5/15/22.
//

import Foundation

public enum APIError: Error, Equatable {
    case ok
    case created
    case noContent
    case badRequest
    case unAuthorized
    case forbidden
    case notFound
    case conflict
    case internalServerError
    case notImplemented
    case serviceUnavailable
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case networkError(from: URLError)
    case badURL
    case unknown

    public init(status: Int) {
        switch status {
        case 200:
            self = .ok
        case 201:
            self = .created
        case 204:
            self = .noContent
        case 400:
            self = .badRequest
        case 401:
            self = .unAuthorized
        case 403:
            self = .forbidden
        case 404:
            self = .notFound
        case 409:
            self = .conflict
        case 500:
            self = .internalServerError
        case 501:
            self = .notImplemented
        case 503:
            self = .serviceUnavailable
        case 400...499:
            self = .clientError(statusCode: status)
        case 500...599:
            self = .serverError(statusCode: status)
        default:
            self = Self.unknown
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .created:
            return "Created"
        case .noContent:
            return "No Content"
        case .badRequest:
            return "Bad Request"
        case .unAuthorized:
            return "UnAuthorized"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not found"
        case .conflict:
            return "Conflict"
        case .internalServerError:
            return "Internal Server Error"
        case .notImplemented:
            return "Not Implemented"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .clientError(let statusCode):
            return "Client Error \(statusCode)"
        case .serverError(let statusCode):
            return "Server Error \(statusCode)"
        case .networkError(let urlError):
            return "Network Error: \(urlError.localizedDescription)"
        case .badURL:
            return "Bad URL"
        case .unknown:
            return "Unknown"
        default:
            return "Unknown network error"
        }
    }

}
