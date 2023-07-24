import Foundation

public struct USDServiceProvider:USDService {
    
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
    
    //MARK: Conversion
    
//    public func usdcatHelp() -> String {
//        //Environment setting means don't need full path.
//        let message = try? shell("\(pathToBin)/usdcat -h")
//        return (message != nil) ? message! : "nothing to say"
//    }
    
    //TODO: Better form would to have all the intakes be URLs?
    
    @discardableResult
    public func makeCrate(from inputFile:String, outputFile:String) -> String {
       // print(try? shell("pwd"))
        let message = try? shell("usdcat -o \(outputFile) --flatten \(inputFile)")
        return message ?? ""
    }
    
    //MARK: Checking/Validating
    public func check(filePath inputFile:String) -> String {
        let message = try? shell("usdchecker \(inputFile)")
        return message ?? "no message"
    }
    
    public func check(url inputURL:URL) -> String {
        let message = try? shell("usdchecker \(inputURL.absoluteString)")
        return message ?? "no message"
    }
    
    public func check(string inputString:String) -> String {
        let tmp_file_dir = FileManager().temporaryDirectory.appendingPathComponent(UUID().uuidString)
        print(tmp_file_dir.absoluteString)
        let tmp_file_path = "\(tmp_file_dir.absoluteString)/tmp_test.usda"
        
        do {
            try inputString.write(toFile:tmp_file_path, atomically: true, encoding: .utf8)
            FileManager.fileExists(tmp_file_path)
            let message = try shell("usdchecker \(tmp_file_path)")
            print("TEST: \(message)")
            try FileManager.default.removeItem(at: URL(string: tmp_file_path )!)
            return message
        } catch {
            return "\(error) FAILURE!!!"
        }
    }
    
    //MARK: Proof can use python
    
    // TODO: Try on computer with system python USD Build
    // (Works from Terminal other shell program, not so much XCode b/c of pyenv, see above todo)

    // If doing things with Python ends up being The Way, look into
    // - https://github.com/pvieito/PythonKit?
    // - PythonKit difficult to support? https://forums.swift.org/t/pythonkit-library-not-working-after-releasing-it-to-testflight/65759/3
    // - https://forums.swift.org/t/pythonkit-not-linking/62459/4
    // - https://github.com/apple/swift-evolution/blob/main/proposals/0195-dynamic-member-lookup.md
    // - https://docs.python.org/3/c-api/index.html
    
    public func saveHelloWorld(to outputLocation:String) {
        let current = URL(string: #file)
        let dir = current!.deletingLastPathComponent()
        let message = try? shell("python3 \(dir)/python_scripts/hello_world.py \(outputLocation)")
        print("message:\(message ?? "no message")")
    }
    
    
    //MARK: Helpers
    @discardableResult
    func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", environmentWrap(command, python: pythonEnv)]
        
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

//MARK: Python Environment Management
extension USDServiceProvider {
    
    func environmentWrap(_ newCommand:String, python:PythonEnvironment) -> String {
        """
        \(python.setString)
        export PATH=$PATH:\(pathToBaseDir)/bin;
        export PYTHONPATH=$PYTHONPATH:\(pathToBaseDir)/lib/python
        \(newCommand)
        """
    }
    
    public enum PythonEnvironment {
        case defaultSystem
        case pyenv(String)
        case systemInstallMacOS(String)
        case customPath(String)
        
        var setString:String {
            switch self {
                
            case .defaultSystem:
                return ""
            case .pyenv(let v):
                return setPythonWithPyEnv(version: v)
            case .systemInstallMacOS(let v):
                return setPythonSystemMacOS(version: v)
            case .customPath(let p):
                return prependPath(customString: p)
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
        
        func setPythonSystemMacOS(version:String) -> String {
            """
            PATH="/Library/Frameworks/Python.framework/Versions/\(version)/bin:${PATH}"
            export PATH
            """
        }
        
        func prependPath(customString:String) -> String {
            """
            PATH="\(customString):${PATH}"
            export PATH
            """
        }
    }

}
