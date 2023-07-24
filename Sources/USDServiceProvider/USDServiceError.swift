//
//  File.swift
//  
//
//  Created by Carlyn Maw on 7/23/23.
//

//import Foundation


enum USDServiceError: Error, CustomStringConvertible {
    case message(String)
    public var description: String {
        switch self {
        case let .message(message): return message
        }
    }
    init(_ message: String) {
        self = .message(message)
    }
}
