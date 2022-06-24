//
//  Album+sort.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {

    /// Sort contents by disk and track
    public mutating func sortContents() {
        for index in contents.indices {
            if var composition = contents[index].composition {
                composition.sortContents()
                contents[index].composition = composition
                contents[index].disk = composition.startDisk
                contents[index].track = composition.startTrack
            }
        }
        
        contents = contents.sorted {
            let diska = $0.disk ?? 1
            let diskb = $1.disk ?? 1
            if diska == diskb {
                return $0.track < $1.track
            }
            return diska < diskb
        }
        
    }

    /// Return sort friendly version of title
    ///
    /// Returns a title with articles ('a', 'an', 'the') stripped from the beginning of the string
    /// - Parameter title: The title
    /// - Returns: Sort friendly version of title
    public static func sortedTitle(_ title: String) -> String {
        var value = title
        if title.lowercased().hasPrefix("the ") {
            value = String(value.dropFirst(4))
        } else if title.lowercased().hasPrefix("a ") {
            value = String(value.dropFirst(2))
        } else if title.lowercased().hasPrefix("an ") {
            value = String(value.dropFirst(3))
        }
        return value
    }

    /// Returns sort friendly version of a persons name
    ///
    /// The returned name attempts to be last name first with a comma separated the last name from
    /// the rest of the name.  Leading articles are removed
    /// - Parameter person: Person's name
    /// - Returns: Sort friendly version of person's name
    public static func sortedPerson(_ person: String?) -> String? {
        if var value = person {
            // Remove 'A', 'An' or 'The'
            value = Album.sortedTitle(value)
            // Remove (birthyear-deathyear) from end of value
            let pattern = " *\\(\\d{4}-\\d{4}\\) *"
            if let dateRange = value.range(of: pattern, options:.regularExpression) {
                value.removeSubrange(dateRange)
            }
            value = value.trimmingCharacters(in: .whitespaces)
            // if person does not contain comma, strip last word and insert at front followed by ', ' and the rest of the field
            if !value.contains(",") {
                if let index = value.lastIndex(of: " ") {
                    let startIndex = value.startIndex
                    let endIndex = value.endIndex
                    let first = String(value[startIndex..<index])
                    let last = String(value[index..<endIndex].dropFirst())
                    value = last + ", " + first
                }
            }
            return value
        }
        return nil
    }
    
}
