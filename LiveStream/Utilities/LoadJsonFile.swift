//
//  LoadJsonFile.swift
//  LiveStream
//
//  Created by Mujahed Ansari on 17/12/24.
//

import Foundation

struct LoadJsonFile {
    
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T? {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            if let data = try? Data(contentsOf: url) {
                let decoder = JSONDecoder()
                return try? decoder.decode(T.self, from: data)
            }
        }
        return nil
    }

}
