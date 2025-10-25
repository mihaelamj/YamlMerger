@testable import YAMLSplitter
@testable import YAMLMerger
import XCTest

final class YAMLSplitterTests: XCTestCase {
    
    func testSplitOpenAPIYAML() throws {
        print("📂 CWD:", FileManager.default.currentDirectoryPath)

        // 1) INPUT: openapi.yaml from Resources
        let bundle = Bundle.module
        guard let openapiFile = bundle.url(forResource: "openapi", withExtension: "yaml", subdirectory: "Resources") else {
            XCTFail("Failed to locate openapi.yaml in YAMLSplitterTests/Resources.")
            return
        }

        // 2) OUTPUT: Schema directory will be created in Documents automatically
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let schemaOutputDir = documentsURL.appendingPathComponent("Schema")
        
        // Clean up existing output directory
        let fm = FileManager.default
        if fm.fileExists(atPath: schemaOutputDir.path) {
            try fm.removeItem(at: schemaOutputDir)
        }

        // 3) Split the OpenAPI YAML (convenience initializer creates Schema in Documents)
        let splitter = YAMLSplitter(inputFile: openapiFile)
        try splitter.split()

        // 4) Verify the output structure
        XCTAssertTrue(fm.fileExists(atPath: schemaOutputDir.path), "Schema directory not created")
        
        // Verify all expected directories exist
        let expectedDirs = [
            "01_Info",
            "02_Servers", 
            "03_Tags",
            "04_Paths",
            "06_Components",
            "07_Security",
            "08_ExternalDocs"
        ]
        
        for dirName in expectedDirs {
            let dirPath = schemaOutputDir.appendingPathComponent(dirName)
            XCTAssertTrue(fm.fileExists(atPath: dirPath.path), "Directory \(dirName) not created")
        }
        
        // 5) Verify the split created files and folders
        let infoDir = schemaOutputDir.appendingPathComponent("01_Info")
        XCTAssertTrue(fm.fileExists(atPath: infoDir.path), "01_Info directory not created")
        
        let pathsDir = schemaOutputDir.appendingPathComponent("04_Paths")
        XCTAssertTrue(fm.fileExists(atPath: pathsDir.path), "04_Paths directory not created")
        
        let componentsDir = schemaOutputDir.appendingPathComponent("06_Components")
        XCTAssertTrue(fm.fileExists(atPath: componentsDir.path), "06_Components directory not created")
        
        // Check that files were created in each directory
        let pathFiles = try fm.contentsOfDirectory(at: pathsDir, includingPropertiesForKeys: nil)
        XCTAssertTrue(pathFiles.count > 0, "No files created in 04_Paths directory")
        
        let componentFiles = try fm.contentsOfDirectory(at: componentsDir, includingPropertiesForKeys: nil)
        XCTAssertTrue(componentFiles.count > 0, "No files created in 06_Components directory")
        
        print("✅ YAML split successfully into:", schemaOutputDir.path)
        print("📁 Created directories:", expectedDirs.joined(separator: ", "))
        print("📄 Path files created:", pathFiles.count)
        print("📄 Component files created:", componentFiles.count)
    }
    
    func testSplitAndMergeRoundTrip() throws {
        print("🔄 Testing split and merge round trip")
        
        // 1) Split the openapi.yaml
        let bundle = Bundle.module
        guard let openapiFile = bundle.url(forResource: "openapi", withExtension: "yaml", subdirectory: "Resources") else {
            XCTFail("Failed to locate openapi.yaml in YAMLSplitterTests/Resources")
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let schemaDir = documentsURL.appendingPathComponent("Schema")
        
        // Clean up
        let fm = FileManager.default
        if fm.fileExists(atPath: schemaDir.path) {
            try fm.removeItem(at: schemaDir)
        }
        
        // Split (convenience initializer creates Schema in Documents)
        let splitter = YAMLSplitter(inputFile: openapiFile)
        try splitter.split()
        
        // 2) Merge back using YAMLMerger
        let merger = YAMLMerger(rootDirectory: schemaDir, outputFileName: "CombinedSpec.yaml")
        merger.merge()
        
        // 3) Verify the merged file exists
        let mergedFile = schemaDir.appendingPathComponent("CombinedSpec.yaml")
        XCTAssertTrue(fm.fileExists(atPath: mergedFile.path), "Merged file not created")
        
        print("✅ Round trip completed successfully")
        print("📄 Original file:", openapiFile.path)
        print("📄 Merged file:", mergedFile.path)
    }
}
