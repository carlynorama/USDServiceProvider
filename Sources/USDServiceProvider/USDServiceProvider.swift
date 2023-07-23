import Foundation

public struct USDServiceProvider {
    
    public private(set) var pathToBaseDir:String
    public private(set) var pythonEnv:PythonEnvironment
    
    
    public init(pathToUSDBuild:String, pythonEnv:PythonEnvironment) {
        self.pathToBaseDir = pathToUSDBuild
        self.pythonEnv = pythonEnv
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
        task.arguments = ["-c", environmentWrap(command, python: .pyenv("3.10"))]
        
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
    
    public enum PythonEnvironment {
        case defaultSystem
        case pyenv(String)
        case systemInstall(String)
        
        var setString:String {
            switch self {
                
            case .defaultSystem:
                return ""
            case .pyenv(let v):
                return setPythonWithPyEnv(version: v)
            case .systemInstall(let v):
                return setPythonSystem(version: v)
            }
        }
        
        func setPythonWithPyEnv(version:String) -> String {
            """
            export PYENV_ROOT="$HOME/.pyenv"
            command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
            export PYENV_VERSION=\(version)
            """
        }
        
        func setPythonSystem(version:String) -> String {
            """
            PATH="/Library/Frameworks/Python.framework/Versions/\(version)/bin:${PATH}"
            export PATH
            """
        }
    }
    
    
    func environmentWrap(_ newCommand:String, python:PythonEnvironment) -> String {
        """
        \(python.setString)
        export PATH=$PATH:\(pathToBaseDir)/bin;
        export PYTHONPATH=$PYTHONPATH:\(pathToBaseDir)/lib/python
        \(newCommand)
        """
    }

}
