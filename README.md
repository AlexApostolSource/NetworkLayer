
# NetworkLayer

**NetworkLayer** is a Swift package designed to provide a modular and reusable networking layer. It supports **iOS** and is built with **Swift Package Manager (SPM)**. The package also includes core utilities in a separate module, **NLCore**.

## Features

- Networking layer abstraction for REST API calls.
- Supports iOS (min iOS 15).
- Simple and flexible architecture.
- Easily extensible for different network-related functionalities.

## Requirements

- iOS 15.0+
- Xcode 12.5+
- Swift 5.5+

## Installation

### Swift Package Manager

You can add **NetworkLayer** to your project using **Swift Package Manager**.

1. In Xcode, select **File > Swift Packages > Add Package Dependency**.
2. Enter the repository URL:

```
https://github.com/your-repository/NetworkLayer.git
```

3. Choose the appropriate version or branch.
4. Add the `NetworkLayer` package to your target.

### Package.swift

Alternatively, if you're using a `Package.swift` file, you can add **NetworkLayer** as a dependency like so:

```swift
// swift-tools-version: 5.10.0
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/your-repository/NetworkLayer.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "YourProject", dependencies: ["NetworkLayer"]),
    ]
)
```

## Contributing

Contributions are welcome! Feel free to open issues, submit pull requests, or suggest improvements. Please adhere to the following guidelines:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes, ensuring that your code follows the style of the project.
4. Write tests to cover new functionality or bug fixes.
5. Submit a pull request.

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
