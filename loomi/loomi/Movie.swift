//
//  Movie.swift
//  loomi
//
//  Created by Janna Qian Zi Ng on 12/2/25.
//

import Foundation

struct Movie: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let values: [String]
    let suitableAge: String
    let genres: [String]
    let movieAgeRating: String
    let length: Int
    let releasedDate: String
    let synopsis: String
    let posterPortrait: String
    let posterLandscape: String
    let trailerID: String
    let popularity: String
    let questions: [String]
}
