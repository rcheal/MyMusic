import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MyMusicAPITests.allTests),
        testCase(MusicMetadataAlbumArtTests.allTests),
        testCase(MusicMetadataContentTests.allTests),
        testCase(MusicMetadataFieldTests.allTests),
        testCase(MusicMetadataMergeTests.allTests),
        testCase(MusicMetadataSortTests.allTests),
        testCase(MusicMetadataUpdateTests.allTests)
    ]
}
#endif
