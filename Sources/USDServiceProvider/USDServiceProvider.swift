import Foundation

public struct USDServiceProvider {
    public private(set) var pathToBin:String
    public private(set) var pythonPath:String
    
    public init(_ pathToUSD:String? = nil) {
        self.pathToBin = "/Users/carlynorama/opd/USD_nousdview_0722/bin"
        self.pythonPath = "/Users/carlynorama/opd/USD_nousdview_0722/lib/python"
    }
    
    
    public func usdcatHelp() -> String {
        let message = try? shell("\(pathToBin)/usdcat -h")
        return (message != nil) ? message! : "nothing to say"
    }
    
    public func makeUSDC(inputFile:String, outputFile:String) {
       // print(try? shell("pwd"))
        let message = try? shell("\(pathToBin)/usdcat -o \(outputFile) --flatten \(inputFile)")
        print(message ?? "")
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
        
        
//        var environment =  ProcessInfo.processInfo.environment
//        environment["PYTHONPATH"] = "\(pythonPath)"
        //task.environment = environment
        print(task.environment ?? "")
        
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
