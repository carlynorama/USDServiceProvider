import Foundation

public struct USDServiceProvider {
    
    enum PythonVersion {
        case defaultSystem
        case pyenv(String)
        case systemInstall(String)
    }
    
    public private(set) var pathToBaseDir:String
    
    public init(pathToUSDBuild:String) {
        self.pathToBaseDir = pathToUSDBuild
    }
    
    var pathToBin:String {
        "\(pathToBaseDir)/bin"
    }
    
    var pathToPython:String {
        "\(pathToBaseDir)/lib/python"
    }
    
    public func usdcatHelp() -> String {
        let message = try? shell("\(pathToBin)/usdcat -h")
        return (message != nil) ? message! : "nothing to say"
    }
    
    public func makeCrate(from inputFile:String, outputFile:String) {
       // print(try? shell("pwd"))
        let message = try? shell("usdcat -o \(outputFile) --flatten \(inputFile)")
        print(message ?? "")
    }
    
    public func check(_ inputFile:String) {
       // print(try? shell("pwd"))
        let message = try? shell("usdchecker \(inputFile)")
        print(message ?? "")
    }
    
    @discardableResult
    func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", environmentWrap(command)]
        
        task.standardInput = nil
        task.executableURL = URL(fileURLWithPath: "/bin/bash") //<-- what shell
        
        //The technically correct way to pass in environment vars.
        //Does work.
        //var environment =  ProcessInfo.processInfo.environment
        //environment["PYTHONPATH"] = "\(pathToPython)"
        //task.environment = environment
        //print(task.environment ?? "")
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}

extension USDServiceProvider {
    //TODO: Needs improvement
//    public init?() {
//        guard let path = try? Self.shell("which usdchecker") else {
//            return nil
//        }
//        if path.isEmpty { return nil }
//        if path.contains("not found") { return nil }
//        guard let urlTest = URL(string: path ) else { return nil }
//        self.pathToBin = path
//    }
    
    func environmentWrap(_ newCommand:String) -> String {
        """
        \(setPythonWithPyEnv(version:"3.10"))
        export PATH=$PATH:\(pathToBaseDir)/bin;
        export PYTHONPATH=$PYTHONPATH:\(pathToBaseDir)/lib/python
        \(newCommand)
"""
    }
    
    func setPythonWithPyEnv(version:String) -> String {
        """
        export PYENV_ROOT="$HOME/.pyenv"
        command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        export PYENV_VERSION=\(version)
        """
    }
}


//public func echo(_ input:String) -> String {
//    if input.isEmpty {
//        return "[crickets chirping]"
//    } else {
//        let message = try? shell("echo \(input)")
//        return (message != nil) ? message! : "nothing to say"
//    }
//
//}
//
//public func whatsInMyBin() {
//    let testPath = "/usr/bin"
//    let ls = Process()
//    //https://manned.org/env.1
//    ls.executableURL = URL(fileURLWithPath: "/usr/bin/env")
//    ls.arguments = ["ls", "-al", testPath]
//    do{
//        try ls.run()
//    } catch {
//        print(error)
//    }
//}
