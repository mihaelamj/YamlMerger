@testable import YAMLMerger
import XCTest

final class YamlMergerTests: XCTestCase {
    func testMergeSchemaYAML() throws {
        print("📂 CWD:", FileManager.default.currentDirectoryPath)

        // 1) INPUT: Schema in the test bundle
        let bundle = Bundle.module
        guard let schemaFolder = bundle.url(forResource: "Schema", withExtension: nil) else {
            XCTFail("Failed to locate Schema folder in resources")
            return
        }

        // 2) Merge as before (outputs inside schemaFolder)
        let merger = YAMLMerger(
            rootDirectory: schemaFolder,
            outputFileName: "CombinedSpec.yaml"
        )
        merger.merge()

        // 3) Verify source file exists where the merger wrote it
        let sourceURL = schemaFolder.appendingPathComponent("CombinedSpec.yaml")
        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path),
                      "Merged file not found at \(sourceURL.path)")

        // 4) DEST: ~/Documents/CombinedSpec.yaml
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destURL = documentsURL.appendingPathComponent("CombinedSpec.yaml")

        // Ensure Documents exists (it will) and replace if present
        let fm = FileManager.default
        if fm.fileExists(atPath: destURL.path) {
            try fm.removeItem(at: destURL)
        }

        // 5) Copy (or use moveItem if you want to move instead of copy)
        try fm.copyItem(at: sourceURL, to: destURL)

        // 6) Assert + log
        XCTAssertTrue(fm.fileExists(atPath: destURL.path))
        print("✅ Copied merged spec to:", destURL.path)
    }
}
