@testable import YAMLMerger
import XCTest

final class YamlMergerTests: XCTestCase {
    func testMergeSchemaYAML() throws {
        
        print("📂 CWD:", FileManager.default.currentDirectoryPath)
        
        // Access the resource from the test bundle
        let bundle = Bundle.module
        guard let schemaFolder = bundle.url(forResource: "Schema", withExtension: nil) else {
            XCTFail("Failed to locate Schema folder in resources")
            return
        }

        // Merge the files
        let merger = YAMLMerger(
            rootDirectory: schemaFolder,
            outputFileName: "CombinedSpec.yaml"
        )
        merger.merge()

        // Optional: assert output file exists
        let outputURL = schemaFolder.appendingPathComponent("CombinedSpec.yaml")
        print("📂 CWD:", outputURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
    }
}
