import Foundation
import ArgumentParser

// Regular expressions for dependency extraction
let remoteDependencyRegex = try! NSRegularExpression(pattern: #"\.package\(.*?url: "https?://(?:[^/]+/)+([^/]+)\.git".*?\)"#, options: [])
let localDependencyRegex = try! NSRegularExpression(pattern: #"\.package\(name: "(.*?)", path: "(.*?)"\)"#, options: [])

/**
 A command-line tool for generating a dependency graph for Swift Package Manager projects.
 */
struct GenerateDependencyGraph: ParsableCommand {
    @Option(name: .shortAndLong, help: "Output file name for the generated graph (without extension).")
    var output: String = "dependencies_graph"

    @Option(name: .shortAndLong, help: "Color for project nodes.")
    var projectColor: String = "lightcoral"

    @Option(name: .shortAndLong, help: "Color for local dependency nodes.")
    var localColor: String = "lightblue"

    @Option(name: .shortAndLong, help: "Color for remote dependency nodes.")
    var remoteColor: String = "lightgreen"

    @Option(name: .long, help: "Path to the directory to scan for Package.swift files.")
    var path: String = "."
    
    /**
     Main execution function for the command.
     Scans the specified path for Package.swift files, extracts dependencies, and generates a Graphviz DOT file and PNG image.
     */
    func run() throws {
        // Find all Package.swift files in the specified directory
        let packageFiles = findPackageFiles(at: path)
        var dependencies = [String: ([String], [(String, String)])]()

        // Extract dependencies from each Package.swift file
        for packageFile in packageFiles {
            let projectName = URL(fileURLWithPath: packageFile).deletingLastPathComponent().lastPathComponent
            let (remoteDeps, localDeps) = extractDependencies(filePath: packageFile)
            dependencies[projectName] = (remoteDeps, localDeps)
        }

        // Create the Graphviz DOT representation
        let dot = createDependencyGraph(dependencies: dependencies, projectColor: projectColor, localColor: localColor, remoteColor: remoteColor)
        let dotFilePath = "\(output).dot"

        // Write the DOT file and check if it was created
        do {
            try dot.write(toFile: dotFilePath, atomically: true, encoding: .utf8)
            print("DOT file created: \(dotFilePath)")

            if FileManager.default.fileExists(atPath: dotFilePath) {
                print("DOT file successfully created at: \(dotFilePath)")

                // Generate the PNG image using Graphviz
                let process = Process()
                process.launchPath = "/usr/bin/env"
                process.arguments = ["dot", "-Tpng", dotFilePath, "-o", "\(output).png"]
                process.launch()
                process.waitUntilExit()
                print("Dependency graph created: \(output).png")
            } else {
                print("Failed to create the DOT file.")
            }
        } catch {
            print("Error writing file or creating graph: \(error)")
        }
    }
}

// Extracts remote and local dependencies from a Package.swift file
func extractDependencies(filePath: String) -> ([String], [(String, String)]) {
    do {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let remoteMatches = remoteDependencyRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        let localMatches = localDependencyRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))

        let remoteDependencies = remoteMatches.compactMap { match -> String? in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }

        let localDependencies = localMatches.compactMap { match -> (String, String)? in
            guard let nameRange = Range(match.range(at: 1), in: content),
                  let pathRange = Range(match.range(at: 2), in: content) else { return nil }
            let name = String(content[nameRange])
            let path = String(content[pathRange])
            return (name, path)
        }

        return (remoteDependencies, localDependencies)
    } catch {
        print("Error reading file: \(filePath)")
        return ([], [])
    }
}

/**
 Finds all Package.swift files in the specified directory and its subdirectories.
 - Parameter path: The path to the directory to scan.
 - Returns: An array of paths to Package.swift files.
 */
func findPackageFiles(at path: String) -> [String] {
    var packageFiles = [String]()
    let fileManager = FileManager.default
    let absolutePath = URL(fileURLWithPath: path).path

    if let enumerator = fileManager.enumerator(atPath: absolutePath) {
        for case let filePath as String in enumerator {
            if filePath.hasSuffix("Package.swift") {
                packageFiles.append(absolutePath + "/" + filePath)
            }
        }
    }
    return packageFiles
}

/**
 Creates a Graphviz DOT representation of the dependency graph.
 - Parameters:
   - dependencies: A dictionary where the key is the project name and the value is a tuple containing arrays of remote and local dependencies.
   - projectColor: The color for project nodes.
   - localColor: The color for local dependency nodes.
   - remoteColor: The color for remote dependency nodes.
 - Returns: A string containing the Graphviz DOT representation of the dependency graph.
 */
func createDependencyGraph(dependencies: [String: ([String], [(String, String)])], projectColor: String, localColor: String, remoteColor: String) -> String {
    var dot = "digraph dependencies {\n"
    dot += "    graph [rankdir=LR, splines=polyline, nodesep=1.0, ranksep=1.0];\n"
    dot += "    node [shape=box, style=filled, fontsize=12, fontcolor=black, width=2.0, height=1.0];\n"
    dot += "    edge [color=gray, fontsize=10, fontcolor=black];\n"

    for (project, (remoteDeps, localDeps)) in dependencies {
        dot += "    \"\(project)\" [color=\"\(projectColor)\"];\n"
        for dep in remoteDeps {
            dot += "    \"\(dep)\" [color=\"\(remoteColor)\"];\n"
            dot += "    \"\(project)\" -> \"\(dep)\";\n"
        }
        for (dep, _) in localDeps {
            dot += "    \"\(dep)\" [color=\"\(localColor)\"];\n"
            dot += "    \"\(project)\" -> \"\(dep)\";\n"
        }
    }

    dot += "}\n"
    return dot
}

GenerateDependencyGraph.main()