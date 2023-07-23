# USDServiceProvider

Initial proof of concept for using OpenUSD Library in a MacOS or Linux project written in Swift.


## Example Usage

See: https://github.com/carlynorama/USDTestingCLI

A CLI Client Main File

```swift
import Foundation
import ArgumentParser
import USDServiceProvider

//MARK: --------------------- YOUR SETUP GOES HERE ------------------------
let USDBuild = "/Users/carlynorama/opd/USD_nousdview_py3_10_0723/"
let pythonEnv:USDServiceProvider.PythonEnvironment = .pyenv("3.10")

@main
public struct USDTestingCLI:ParsableCommand {
    public static let configuration = CommandConfiguration(
        
        abstract: "A Swift command-line tool",
        version: "0.0.1",
        subcommands: [
            testusdcat.self,
            makecrate.self
        ],
        defaultSubcommand: makecrate.self)
    
    public init() {}
    
    struct testusdcat:ParsableCommand {
        func run() throws {
            print(USDServiceProvider(pathToUSDBuild:USDBuild, pythonEnv: pythonEnv).usdcatHelp())
        }
    }
    
    struct makecrate:ParsableCommand {
        
        @Argument(help: "The input file") var inputFile: String
        @Argument(help: "The output file") var outputFile: String?
        
        func run() throws {
            
            //TODO: fragile. if cli sticks around, improve.
            let outputFilePath = outputFile ?? inputFile.replacingOccurrences(of: ".usda", with: ".usdc")
            
            let usdSP = USDServiceProvider(pathToUSDBuild: USDBuild, pythonEnv: .pyenv("3.10p"))
            print("hello")
            
            usdSP.makeCrate(from: inputFile, outputFile: outputFilePath)
            usdSP.check(inputFile)
        }
    }
}

```

Package file using as a local library

```
// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.



import PackageDescription

let package = Package(
    name: "USDTestingCLI",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "myusdtests",
            targets: ["USDTestingCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
        .package(path: "../USDServiceProvider"),
    ],
    targets: [
        .executableTarget(
            name: "USDTestingCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "USDServiceProvider", package: "USDServiceProvider"),
            ]),
        .testTarget(
            name: "USDTestingCLITests",
            dependencies: ["USDTestingCLI"]),
    ]
)

```
