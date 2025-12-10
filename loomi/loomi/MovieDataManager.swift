//
//  MovieDataManager.swift
//  loomi
//
//  Created by Janna Qian Zi Ng on 12/2/25.
//

import Foundation

struct MovieDataManager {
    
    static func loadMovies() -> [Movie] {
        guard let url = Bundle.main.url(forResource: "database", withExtension: "json") else {
            print("JSON file not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let movies = try JSONDecoder().decode([Movie].self, from: data)
            return movies
        } catch {
            print("Failed to decode JSON: \(error)")
            return []
        }
    }
}

