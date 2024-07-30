# DependencyGraphScript

A command-line tool for generating a dependency graph for Swift Package Manager projects using Graphviz.

## Features

- Scans a specified directory for `Package.swift` files.
- Extracts remote and local dependencies from each `Package.swift` file.
- Generates a Graphviz DOT representation of the dependency graph.
- Outputs a PNG image of the dependency graph.

## Requirements

- Swift 5.3 or later
- Graphviz installed (e.g., via Homebrew: `brew install graphviz`)

## Installation

1. Clone the repository:

    ```sh
    git clone https://github.com/Xopoko/DependencyGraphScript
    cd DependencyGraphScript
    ```

2. Build the project:

    ```sh
    swift build
    ```

## Usage

Run the script with the desired options:

```sh
swift run dependency_graph --output <output-filename> --project-color <project-color> --local-color <local-color> --remote-color <remote-color> --path <directory-path>

### Options

- `--output` (`-o`): Output file name for the generated graph (without extension). Default is `dependencies_graph`.
- `--project-color` (`-p`): Color for project nodes. Default is `lightcoral`.
- `--local-color` (`-l`): Color for local dependency nodes. Default is `lightblue`.
- `--remote-color` (`-r`): Color for remote dependency nodes. Default is `lightgreen`.
- `--path` (`--path`): Path to the directory to scan for `Package.swift` files. Default is the current directory (`.`).

### Example

Generate a dependency graph for a project located at `/path/to/your/project`:

```sh
swift run dependency_graph --output my_graph --project-color red --local-color blue --remote-color green --path /path/to/your/project
```

This will create a `my_graph.png` file in the current directory, containing the dependency graph.

## Development

### Structure

- `Package.swift`: Swift package description file.
- `Sources/main.swift`: Main source file containing the script logic.

### Adding Dependencies

To add new dependencies, update the `Package.swift` file and run `swift build` to fetch and integrate them.

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
