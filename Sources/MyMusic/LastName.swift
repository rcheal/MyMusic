//
//  LastName.swift
//  
//
//  Created by Robert Cheal on 2/21/23.
//

import Foundation

public func lastName(_ name: String?) -> String? {
    if var value = name {
        let pattern = " *\\(\\d{4}(-\\d{4})?\\) *"
        if let dateRange = value.range(of: pattern, options:.regularExpression) {
            value.removeSubrange(dateRange)
        }
        value = value.trimmingCharacters(in: .whitespaces)
        // if person does not contain comma, strip last word and return
        if !value.contains(",") {
            if let index = value.lastIndex(of: " ") {
                let endIndex = value.endIndex
                let last = String(value[index..<endIndex].dropFirst())
                return last
            }
            return value
        } else {
            // Return everything in front of the comma
            return value.components(separatedBy: ",")[0]
        }
    }
    return nil
}
