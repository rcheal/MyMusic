//
//  URL+query.swift
//  
//
//  Created by Robert Cheal on 2/15/21.
//

import Foundation

extension URL {
    func appending(queryItems: [(String, String)]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        let urlQueryItems = queryItems.map { item in
            return URLQueryItem(name: item.0, value: item.1)
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + urlQueryItems
        return urlComponents.url
    }
    
    mutating func append(queryItems: [(String, String)]) {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return
        }
        let urlQueryItems = queryItems.map { item in
            return URLQueryItem(name: item.0, value: item.1)
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + urlQueryItems
        self = urlComponents.url!
    }
}
