//
//  XCTestManifests.swift
//  MusicMetadata
//
//  Created by Robert Cheal on 11/2/20.
//
import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MusicMetadataAlbumArtTests.allTests),
        testCase(MusicMetadataContentTests.allTests),
        testCase(MusicMetadataFieldTests.allTests),
        testCase(MusicMetadataMergeTests.allTests),
        testCase(MusicMetadataSortTests.allTests),
        testCase(MusicMetadataUpdateTests.allTests)
    ]
}
#endif
