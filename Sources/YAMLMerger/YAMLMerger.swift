import Foundation

public struct YAMLMerger {
    public let rootDirectory: URL
    public let outputFileName: String

    public init(rootDirectory: URL, outputFileName: String) {
        self.rootDirectory = rootDirectory
        self.outputFileName = outputFileName
    }

    private func sortedYAMLFiles(in folder: URL) -> [URL] {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            return []
        }
        return contents
            .filter { $0.pathExtension == "yaml" || $0.pathExtension == "yml" }
            .sorted { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() }
    }

    private func sortedSubfolders(in folder: URL) -> [URL] {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return []
        }
        return contents
            .filter {
                var isDirectory: ObjCBool = false
                return fileManager.fileExists(atPath: $0.path, isDirectory: &isDirectory) && isDirectory.boolValue
            }
            .sorted { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() }
    }

    private func cleanedContent(_ text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(\\n\\s*){2,}", options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "\n\n")
    }

    public func merge() {
        let outputFile = rootDirectory.appendingPathComponent(outputFileName)
        var output = ""

        let folderURLs = sortedSubfolders(in: rootDirectory)

        for folderURL in folderURLs {
            let yamlFiles = sortedYAMLFiles(in: folderURL)

            var isFirstFile = true
            for fileURL in yamlFiles {
                guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }
                if !isFirstFile {
                    output += "\n" // only between files
                }
                output += content
                isFirstFile = false
            }
        }

        try? output.write(to: outputFile, atomically: true, encoding: .utf8)
        print("✅ Combined YAML written to \(outputFile.path)")
    }
}

