import Foundation

public struct USDServiceProvider {
    public private(set) var text = "Hello, World!"
    
    public init() {
    }
    
    
    public func echo(_ input:String) -> String {
        if input.isEmpty {
            return "[crickets chirping]"
        } else {
            let message = try? shell("echo \(input)")
            return (message != nil) ? message! : "nothing to say"
        }
        
    }
    
    @discardableResult // Add to suppress warnings when you don't want/need a result
    func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        
        task.standardInput = nil
        task.executableURL = URL(fileURLWithPath: "/bin/bash") //<-- what shell
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    public func whatsInMyBin() {
        let testPath = "/usr/bin"
        let ls = Process()
        //https://manned.org/env.1
        ls.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        ls.arguments = ["ls", "-al", testPath]
        do{
            try ls.run()
        } catch {
            print(error)
        }
    }
    
}
