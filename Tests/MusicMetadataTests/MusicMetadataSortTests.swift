//
//  MusicMetadataSortTests.swift
//  
//
//  Created by Robert Cheal on 11/1/20.
//

import XCTest
@testable import MusicMetadata


@available(OSX 11.0, *)
final class MusicMetadataSortTests: XCTestCase {
    
    func assertSortTitle(_ title: String, _ refSortTitle: String) {
        let sortTitle = Album.sortedTitle(title)
        XCTAssertEqual(sortTitle, refSortTitle)
    }
    
    func assertSortPerson(_ person: String, _ refSortPerson: String) {
        let sortPerson = Album.sortedPerson(person)
        XCTAssertEqual(sortPerson, refSortPerson)
    }

    func testSortTitle() throws {
        assertSortTitle("Deja Vu","Deja Vu")
        
        assertSortTitle("The Sorcerer's Apprentice", "Sorcerer's Apprentice")
        
        assertSortTitle("A Night in Tunisia", "Night in Tunisia")
        
        assertSortTitle("The Girl from Ipanema", "Girl from Ipanema")
        
    }
    
    func testSortPerson() throws {
        assertSortPerson("The Beatles", "Beatles")
        
        assertSortPerson("Ludwig Van Beethoven (1848-1921)", "Beethoven, Ludwig Van")
        
        assertSortPerson("The Rolling Stones,", "Rolling Stones,")
        
        assertSortPerson("John \"Dizzy\" Gillespie", "Gillespie, John \"Dizzy\"")
        
        assertSortPerson("Bach, Johann Sebastion", "Bach, Johann Sebastion")
        
    }
    
    static var allTests = [
        ("testSortTitle", testSortTitle),
        ("testSortPerson", testSortPerson)
    ]
}
