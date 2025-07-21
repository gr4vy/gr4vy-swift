//
//  JSONDecoder+Extensions.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

extension JSONDecoder {
    func decodeIfPresent<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        try? self.decode(type, from: data)
    }
}
