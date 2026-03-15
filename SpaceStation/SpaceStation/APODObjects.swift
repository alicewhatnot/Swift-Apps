//
//  APODObjects.swift
//  SpaceStation
//
//  Created by Michael Gillbanks on 15/03/2026.
//

import Foundation

struct APOD: Codable {
    let copyright: String?
    let explanation: String
    let media_type: String
    let title: String
    let url: String

    var decodedUrl: URL? { URL(string: url) }
    static let placeholder = APOD(copyright: nil, explanation: "", media_type: "image", title: "Loading APOD...", url: "")
}
