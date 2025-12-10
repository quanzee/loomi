//
//  SavedView.swift
//
//  Created by Andrew Wang on 2/12/2025.
//

import SwiftUI

struct SavedView: View {
    @State private var currentSearchText = ""

    @State private var movies: [Movie] = []
    
    @State private var selectedValues: Set<String> = []

    private var allValues: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for movie in movies {
            for v in movie.values {
                if seen.insert(v).inserted { result.append(v) }
            }
        }
        return result
    }

    private var filteredMovies: [Movie] {
        guard selectedValues.isEmpty == false else { return movies }
        return movies.filter { movie in
            !selectedValues.isDisjoint(with: Set(movie.values))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                // Values chips (select to filter)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(allValues, id: \.self) { value in
                            let isSelected = selectedValues.contains(value)
                            Text(value)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(isSelected ? Color.paletteValue.opacity(0.22) : Color.paletteValue)
                                )
                                .foregroundStyle(isSelected ? Color.paletteText: Color.black)
                                .onTapGesture {
                                    if isSelected { selectedValues.remove(value) } else { selectedValues.insert(value) }
                                }
                                .accessibilityAddTraits(isSelected ? .isSelected : [])
                        }
                        
                        // Clear filter chip appears when any selected
                        if !selectedValues.isEmpty {
                            Button {
                                selectedValues.removeAll()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Clear")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.secondary.opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 100, maximum: 200)),
                    GridItem(.flexible(minimum: 100, maximum: 200))
                ]) {
                    ForEach(filteredMovies) { movie in
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .bottomLeading) {
                                Image(movie.posterPortrait)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 170, height: 240)
                                    .clipped()

                                // Gradient overlay: black at bottom to transparent at top
                                LinearGradient(
                                    colors: [Color.black.opacity(0.85), Color.black.opacity(0.0)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(width: 170, height: 240)
                                .allowsHitTesting(false)

                                // Title stacked on the poster
                                Text(movie.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .shadow(radius: 2)
                                    .padding(12)
                            }
                            .frame(width: 170, height: 240)
                            .clipShape(.rect(cornerRadius: 20))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
            .background(Color.paletteBackground)
            .scrollContentBackground(.hidden)
            .onAppear {
                let loaded = MovieDataManager.loadMovies()
                self.movies = loaded.filter { !$0.posterPortrait.isEmpty }
            }
            .navigationTitle("Your Saved")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                }
            }
        }
    }
}

#Preview {
    RootTabView()
}
