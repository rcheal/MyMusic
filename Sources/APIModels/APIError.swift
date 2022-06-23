//
//  File.swift
//  
//
//  Created by Robert Cheal on 5/15/22.
//

import Foundation

public enum APIError: Error, Equatable {
    /// HTTP status code 200 - The request has succeeded
    case ok
    /// HTTP status code 201 - The requested resource was created
    case created
    /// HTTP status code 204 - Call was successfull but did not need to return a response body
    case noContent
    /// HTTP status code 400 - The server could not understand the request due to malformed syntax
    case badRequest
    /// HTTP status code 401 - Request requires authorization, but either none was provided, or authorization failed
    case unAuthorized
    /// HTTP status code 403 - The server will not fulfill the reequest.  Authorization will not help.
    case forbidden
    /// HTTP status code 404 - Requested resource not found.
    case notFound
    /// HTTP status code 409 - The request could not be completed due to a conflict with the current state of the resource.
    case conflict
    /// Server encountered an unexpected error.
    case internalServerError
    /// HTTP status code 501 - The server does not support the functionality required to fulfill the request.
    case notImplemented
    /// HTTP status code 503 - The server is currently unable to handle the request due to a temporary problem.
    case serviceUnavailable
    /// HTTP status code 4xx - Unexpected status code
    case clientError(statusCode: Int)
    /// HTTP status code 5xx - Unexpected status code
    case serverError(statusCode: Int)
    /// Network layer error - see original URLError
    case networkError(from: URLError)
    /// Invalid URL
    case badURL
    /// Unknown error
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
