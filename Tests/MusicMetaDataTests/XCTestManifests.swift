import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
//        testCase(MusicMetaDataTests.allTests),
        testCase(MetadataExtractorTests.allTests),
        testCase(AudioFileExtractorTests.allTests),
    ]
}
#endif
