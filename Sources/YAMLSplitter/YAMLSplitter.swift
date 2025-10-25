import Foundation
import Yams

/// YAMLSplitter - The opposite of YAMLMerger
/// Takes a single OpenAPI YAML file and splits it into organized schema files
public struct YAMLSplitter {
    public let inputFile: URL
    public let outputDirectory: URL
    
    public init(inputFile: URL, outputDirectory: URL) {
        self.inputFile = inputFile
        self.outputDirectory = outputDirectory
    }
    
    /// Convenience initializer that creates Schema directory in Documents
    public init(inputFile: URL) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let schemaDirectory = documentsURL.appendingPathComponent("Schema")
        self.init(inputFile: inputFile, outputDirectory: schemaDirectory)
    }
    
    /// Splits the OpenAPI YAML file into organized schema files
    public func split() throws {
        // Ensure output directory exists
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        
        // Load and parse the input YAML file
        let yamlContent = try String(contentsOf: inputFile, encoding: .utf8)
        guard let yaml = try Yams.load(yaml: yamlContent) as? [String: Any] else {
            throw YAMLSplitterError.invalidYAMLStructure
        }
        
        // Split into organized sections
        try splitInfoSection(from: yaml)
        try splitServersSection(from: yaml)
        try splitTagsSection(from: yaml)
        try splitPathsSection(from: yaml)
        try splitComponentsSection(from: yaml)
        try splitSecuritySection(from: yaml)
        try splitExternalDocsSection(from: yaml)
        
        print("✅ YAML split successfully into \(outputDirectory.path)")
    }
    
    // MARK: - Section Splitters
    
    private func splitInfoSection(from dict: [String: Any]) throws {
        guard let info = dict["info"] else { return }
        
        let infoDir = outputDirectory.appendingPathComponent("01_Info")
        try FileManager.default.createDirectory(at: infoDir, withIntermediateDirectories: true)
        
        // Create __info.yaml (header)
        let infoHeader = """
        openapi: 3.1.0
        info:
        """
        try infoHeader.write(to: infoDir.appendingPathComponent("__info.yaml"), atomically: true, encoding: .utf8)
        
        // Create api-info.yaml
        let apiInfo = try Yams.dump(object: info, width: -1, sortKeys: true)
        try apiInfo.write(to: infoDir.appendingPathComponent("api-info.yaml"), atomically: true, encoding: .utf8)
    }
    
    private func splitServersSection(from dict: [String: Any]) throws {
        guard let servers = dict["servers"] else { return }
        
        let serversDir = outputDirectory.appendingPathComponent("02_Servers")
        try FileManager.default.createDirectory(at: serversDir, withIntermediateDirectories: true)
        
        // Create __servers.yaml (header)
        let serversHeader = """
        servers:
        """
        try serversHeader.write(to: serversDir.appendingPathComponent("__servers.yaml"), atomically: true, encoding: .utf8)
        
        // Create individual server files
        if let serversArray = servers as? [[String: Any]] {
            for (index, server) in serversArray.enumerated() {
                let serverYaml = try Yams.dump(object: server, width: -1, sortKeys: true)
                let fileName = "server-\(index + 1).yaml"
                try serverYaml.write(to: serversDir.appendingPathComponent(fileName), atomically: true, encoding: .utf8)
            }
        }
    }
    
    private func splitTagsSection(from dict: [String: Any]) throws {
        guard let tags = dict["tags"] else { return }
        
        let tagsDir = outputDirectory.appendingPathComponent("03_Tags")
        try FileManager.default.createDirectory(at: tagsDir, withIntermediateDirectories: true)
        
        // Create __tags.yaml (header)
        let tagsHeader = """
        tags:
        """
        try tagsHeader.write(to: tagsDir.appendingPathComponent("__tags.yaml"), atomically: true, encoding: .utf8)
        
        // Create tags.yaml
        let tagsYaml = try Yams.dump(object: tags, width: -1, sortKeys: true)
        try tagsYaml.write(to: tagsDir.appendingPathComponent("tags.yaml"), atomically: true, encoding: .utf8)
    }
    
    private func splitPathsSection(from dict: [String: Any]) throws {
        guard let paths = dict["paths"] as? [String: Any] else { return }
        
        let pathsDir = outputDirectory.appendingPathComponent("04_Paths")
        try FileManager.default.createDirectory(at: pathsDir, withIntermediateDirectories: true)
        
        // Create __paths.yaml (header)
        let pathsHeader = """
        paths:
        """
        try pathsHeader.write(to: pathsDir.appendingPathComponent("__paths.yaml"), atomically: true, encoding: .utf8)
        
        // Split each path into its own file
        for (path, pathData) in paths {
            let fileName = sanitizeFileName(path) + ".yaml"
            let pathYaml = try Yams.dump(object: [path: pathData], width: -1, sortKeys: true)
            try pathYaml.write(to: pathsDir.appendingPathComponent(fileName), atomically: true, encoding: .utf8)
        }
    }
    
    private func splitComponentsSection(from dict: [String: Any]) throws {
        guard let components = dict["components"] as? [String: Any] else { return }
        
        let componentsDir = outputDirectory.appendingPathComponent("06_Components")
        try FileManager.default.createDirectory(at: componentsDir, withIntermediateDirectories: true)
        
        // Create __components.yaml (header)
        let componentsHeader = """
        components:
        """
        try componentsHeader.write(to: componentsDir.appendingPathComponent("__components.yaml"), atomically: true, encoding: .utf8)
        
        // Split schemas into individual files
        if let schemas = components["schemas"] as? [String: Any] {
            for (schemaName, schemaData) in schemas {
                let fileName = "\(schemaName).yaml"
                let schemaYaml = try Yams.dump(object: [schemaName: schemaData], width: -1, sortKeys: true)
                try schemaYaml.write(to: componentsDir.appendingPathComponent(fileName), atomically: true, encoding: .utf8)
            }
        }
    }
    
    private func splitSecuritySection(from dict: [String: Any]) throws {
        guard let security = dict["security"] else { return }
        
        let securityDir = outputDirectory.appendingPathComponent("07_Security")
        try FileManager.default.createDirectory(at: securityDir, withIntermediateDirectories: true)
        
        // Create __securitySchemes.yaml (header)
        let securityHeader = """
        security:
        """
        try securityHeader.write(to: securityDir.appendingPathComponent("__securitySchemes.yaml"), atomically: true, encoding: .utf8)
        
        // Create security.yaml
        let securityYaml = try Yams.dump(object: security, width: -1, sortKeys: true)
        try securityYaml.write(to: securityDir.appendingPathComponent("security.yaml"), atomically: true, encoding: .utf8)
    }
    
    private func splitExternalDocsSection(from dict: [String: Any]) throws {
        guard let externalDocs = dict["externalDocs"] else { return }
        
        let externalDocsDir = outputDirectory.appendingPathComponent("08_ExternalDocs")
        try FileManager.default.createDirectory(at: externalDocsDir, withIntermediateDirectories: true)
        
        // Create __externalDocs.yaml (header)
        let externalDocsHeader = """
        externalDocs:
        """
        try externalDocsHeader.write(to: externalDocsDir.appendingPathComponent("__externalDocs.yaml"), atomically: true, encoding: .utf8)
        
        // Create externalDocs.yaml
        let externalDocsYaml = try Yams.dump(object: externalDocs, width: -1, sortKeys: true)
        try externalDocsYaml.write(to: externalDocsDir.appendingPathComponent("externalDocs.yaml"), atomically: true, encoding: .utf8)
    }
    
    // MARK: - Helper Methods
    
    private func sanitizeFileName(_ path: String) -> String {
        return path
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: " ", with: "_")
    }
}

// MARK: - Errors

public enum YAMLSplitterError: Error {
    case invalidYAMLStructure
    case fileNotFound
    case directoryCreationFailed
}
