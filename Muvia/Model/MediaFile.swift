//
//  MediaFile.swift
//  Muvia
//
//  Created by Alexander Bralnin on 15.04.2025.
//

import Foundation

struct MediaFile: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let size: Int64?
    let resolution: String?
    let previewURL: String?

    enum CodingKeys: String, CodingKey {
        case name, size, resolution, previewURL
    }
}
