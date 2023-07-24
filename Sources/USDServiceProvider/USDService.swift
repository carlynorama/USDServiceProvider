//
//  USDService.swift
//  
//
//  Created by Carlyn Maw on 7/23/23.
//

import Foundation


protocol USDService {
    //TODO: All of these should be returning Result types. 
    func makeCrate(from inputFile:String, outputFile:String) -> Result<String, Error>
    func check(filePath inputFile:String) -> String
    func check(string inputString:String) -> String
}
