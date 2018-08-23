//
//  Carrier.swift
//  WAL
//
//  Created by Christian Braun on 22.08.18.
//

import Foundation

struct Carrier <A: Codable>: Codable {
    let data: A

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}
