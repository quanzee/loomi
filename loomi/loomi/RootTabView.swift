//
//  TabView.swift
//
//
//  Created by Andrew Wang on 1/12/2025.
//

import SwiftUI

// Temporary shims to align filter UI with your Movie model.
// Map these to your real fields (and remove the defaults) when ready.
extension Movie {
    // Overall rating for the movie (0...5). You don't have a numeric rating yet; keep nil for now.
    var rating: Double? { return nil }

    // Whether the user saved/bookmarked this movie. You don't have this yet; keep nil for now.
    var isSaved: Bool? { return nil }

    // Parse an integer age from your `suitableAge` string (e.g., "7+", "PG-13", etc.).
    // If parsing fails, return nil so the movie isn't filtered out by age.
    var ageRecommendation: Int? {
        // Try to capture a leading number in the string
        let digits = suitableAge.prefix { $0.isNumber }
        if let n = Int(digits) { return n }
        // Handle common MPAA-like strings as a fallback
        let lower = suitableAge.lowercased()
        if lower.contains("pg-13") { return 13 }
        if lower.contains("pg") { return 10 }
        if lower.contains("g") { return 0 }
        if lower.contains("r") { return 17 }
        return nil
    }

    // Use your existing `values` array from the model; do NOT redeclare it.
    // For the filter, we can expose it directly via a computed passthrough if needed under a different name.
    var filterValues: [String] { return values }

    // Derive a category from your `popularity` string to support recommendation filters.
    // This is a heuristic; adjust as needed.
    var recommendedCategory: String? {
        let p = popularity.lowercased()
        if p.contains("trend") { return "Trending" }
        if p.contains("editor") { return "Editor's Picks" }
        if p.contains("friend") { return "Friends' Favorites" }
        return nil
    }
}

struct FilterOptions: Equatable {
    var useAgeRange: Bool = false
    var childAge: Int = 8
    var minAge: Int = 5
    var maxAge: Int = 12

    var selectedGenres: Set<String> = []
    
    var selectedValues: Set<String> = []
}

struct FilterView: View {
    @Binding var isPresented: Bool
    @Binding var options: FilterOptions
    let allGenres: [String]
    
    // Get all unique values from your database
    let allValues: [String] = ["Empathy", "Resilience", "Compassion", "Kindness", "Honesty",
                               "Confidence", "Authenticity", "Leadership", "Courage", "Responsibility",
                               "Integrity", "Respect", "Accountability", "Teamwork", "Loyalty",
                               "Altruism", "Love", "Friendship", "Forgiveness", "Self-Compassion"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Children's Age") {
                    Toggle("Use age range", isOn: $options.useAgeRange)
                    if options.useAgeRange {
                        HStack {
                            Stepper("Min: \(options.minAge)", value: $options.minAge, in: 0...17)
                            Stepper("Max: \(options.maxAge)", value: $options.maxAge, in: options.minAge...17)
                        }
                        .accessibilityElement(children: .contain)
                    } else {
                        Stepper("Age: \(options.childAge)", value: $options.childAge, in: 0...17)
                    }
                }
                
                Section("Genres") {
                    let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(allGenres.sorted(), id: \.self) { genre in
                            let isSelected = options.selectedGenres.contains(genre)
                            Button {
                                if isSelected {
                                    options.selectedGenres.remove(genre)
                                } else {
                                    options.selectedGenres.insert(genre)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    if isSelected { Image(systemName: "checkmark.circle.fill") }
                                    Text(genre)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                Section("Values") {
                    let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(allValues.sorted(), id: \.self) { value in
                            let isSelected = options.selectedValues.contains(value)
                            Button {
                                if isSelected {
                                    options.selectedValues.remove(value)
                                } else {
                                    options.selectedValues.insert(value)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    if isSelected { Image(systemName: "checkmark.circle.fill") }
                                    Text(value)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct RootTabView: View {
    @State var currentSearchText = ""
    
    @State private var availableMovies: [Movie] = []
    @State private var selectedMovie: Movie?
    
    @State private var showFilters = false
    @State private var filters = FilterOptions()
    
    private var allGenres: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for m in availableMovies {
            for g in m.genres {
                if seen.insert(g).inserted { result.append(g) }
            }
        }
        return result.sorted()
    }
    
    private var allValues: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for m in availableMovies {
            for v in m.values {
                if seen.insert(v).inserted { result.append(v) }
            }
        }
        return result.sorted()
    }
    
    func loadMovies() {
        // Load movies from your JSON data
        availableMovies = [
            Movie(id: 1, name: "Inside Out", values: ["Empathy", "Resilience", "Compassion", "Kindness", "Honesty"], suitableAge: "9+", genres: ["Animation", "Adventure", "Comedy"], movieAgeRating: "PG", length: 102, releasedDate: "2015", synopsis: "After young Riley is uprooted from her Midwest life and moved to San Francisco, her emotions, Joy, Fear, Anger, Disgust, and Sadness, conflict on how best to navigate a new city, house, and school.", posterPortrait: "InsideOut_portrait", posterLandscape: "InsideOut_landscape", trailerID: "yRUAzGQ3nSY", popularity: "95%", questions: ["1. Empathy: How do you think Riley wanted others to treat her when she was feeling sad or scared?", "2. Resilience: What else could Riley have done other than run away? What could you do to feel better if you were really sad, worried, or upset?", "3. Compassion: Sadness helped people understand Riley needed support. What good do you think can come from feeling sad?"]),
            
            Movie(id: 2, name: "Inside Out 2", values: ["Resilience", "Kindness", "Empathy", "Self-Compassion", "Honesty"], suitableAge: "9+", genres: ["Animation", "Adventure", "Comedy"], movieAgeRating: "PG", length: 96, releasedDate: "2024", synopsis: "A sequel that features Riley entering puberty and experiencing brand new, more complex emotions as a result. As Riley tries to adapt to her teenage years, her old emotions try to adapt to the possibility of being replaced.", posterPortrait: "InsideOut2_portrait", posterLandscape: "InsideOut2_landscape", trailerID: "LEjhY15eCx0", popularity: "90%", questions: ["1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "2. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "3. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."]),
            
            Movie(id: 4, name: "The Peanuts Movie", values: ["Confidence", "Authenticity", "Honesty", "Kindness"], suitableAge: "6+", genres: ["Animation", "Adventure", "Comedy"], movieAgeRating: "G", length: 93, releasedDate: "2015", synopsis: "Snoopy embarks upon his greatest mission as he and his team take to the skies to pursue their archnemesis, while his best pal Charlie Brown begins his own epic quest back home to win the love of his life.", posterPortrait: "ThePeanutsMovie_portrait", posterLandscape: "ThePeanutsMovie_landscape", trailerID: "zQpUQPrAfQM", popularity: "91%", questions: ["1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "2. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "3. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."]),
            
            Movie(id: 5, name: "Finding Nemo", values: ["Leadership", "Courage", "Responsibility", "Integrity"], suitableAge: "9+", genres: ["Animation", "Comedy", "Adventure"], movieAgeRating: "G", length: 100, releasedDate: "2003", synopsis: "When young clownfish Nemo is unexpectedly captured from Australia's Great Barrier Reef and taken to a dentist's office aquarium, it's up to Marlin, his worrisome father, and Dory, a friendly but forgetful regal blue tang fish, to make the epic journey to bring him home.", posterPortrait: "FindingNemo_portrait", posterLandscape: "FindingNemo_landscape", trailerID: "9oQ628Seb9w", popularity: "92%", questions: ["1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "2. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "3. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."]),
            
            Movie(id: 6, name: "Lion King", values: ["Resilience", "Respect", "Courage", "Integrity"], suitableAge: "8+", genres: ["Animation", "Comedy", "Adventure"], movieAgeRating: "G", length: 88, releasedDate: "1994", synopsis: "The Lion King journeys to the African savanna, where a future king overcomes betrayal and tragedy to assume his rightful place on Pride Rock. Through pioneering filmmaking techniques, The Lion King brings treasured characters to life in a whole new way.", posterPortrait: "LionKing_portrait", posterLandscape: "LionKing_landscape", trailerID: "lFzVJEksoDY", popularity: "89%", questions: ["1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "2. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "3. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."]),
            
            Movie(id: 7, name: "Cars", values: ["Kindness", "Accountability", "Teamwork", "Respect", "Loyalty"], suitableAge: "9+", genres: ["Action", "Adventure"], movieAgeRating: "G", length: 116, releasedDate: "2006", synopsis: "Race car Lightning McQueen is living in the fast lane...until he hits a detour and gets stranded in Radiator Springs, a forgotten town on Route 66. There he meets a heap of hilarious characters who help him discover there's more to life than fame.", posterPortrait: "Cars_portrait", posterLandscape: "Cars_landscape", trailerID: "W_H7_tDHFE8", popularity: "86%", questions: ["1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "2. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "3. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."]),
            
            Movie(id: 8, name: "The Lorax", values: ["Altruism", "Responsibility", "Love", "Honesty", "Respect"], suitableAge: "5+", genres: ["Animation", "Comedy", "Adventure", "Fantasy"], movieAgeRating: "PG", length: 86, releasedDate: "2012", synopsis: "A 12-year-old boy searches for the one thing that will enable him to win the affection of the girl of his dreams. To find it he must discover the story of the Lorax, the grumpy yet charming creature who fights to protect his world.", posterPortrait: "TheLorax_portrait", posterLandscape: "TheLorax_landscape", trailerID: "1bHdzTUNw-4", popularity: "84%", questions: ["1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "2. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "3. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."]),
            
            Movie(id: 9, name: "Wicked", values: ["Compassion", "Friendship", "Forgiveness", "Courage", "Integrity"], suitableAge: "8+", genres: ["Fantasy", "Adventure", "Musical"], movieAgeRating: "PG", length: 160, releasedDate: "2024", synopsis: "Misunderstood because of her green skin, a young woman named Elphaba forges an unlikely but profound friendship with Glinda, a student with an unflinching desire for popularity. Following an encounter with the Wizard of Oz, their relationship soon reaches a crossroad as their lives begin to take very different paths.", posterPortrait: "Wicked_portrait", posterLandscape: "Wicked_landscape", trailerID: "6COmYeLsz4c", popularity: "80%", questions: ["1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "2. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "3. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."])
        ]
    }
    
    func filterSearch() {
        withAnimation(.easeOut(duration: 0.25)) {
            showFilters = true
        }
    }

    var filteredMovies: [Movie] {
        
        return availableMovies.filter { candidateMovie in
            candidateMovie.name.lowercased().contains(currentSearchText.lowercased())
        }
        

    }
    
    // Show preview movies when no search (top 4 based on popularity)
    var previewMovies: [Movie] {
        // Sort by popularity (convert "95%" to 95, etc.)
        return availableMovies.sorted { movie1, movie2 in
            let pop1 = Int(movie1.popularity.replacingOccurrences(of: "%", with: "")) ?? 0
            let pop2 = Int(movie2.popularity.replacingOccurrences(of: "%", with: "")) ?? 0
            return pop1 > pop2
        }.prefix(4).map { $0 }
    }
    
    // Check if we should show preview section
    var shouldShowPreviewSection: Bool {
        return currentSearchText.isEmpty &&
               filters.selectedGenres.isEmpty &&
               filters.selectedValues.isEmpty &&
               !filters.useAgeRange
    }
    
    // Movies to display in the list
    var moviesToShow: [Movie] {
        if shouldShowPreviewSection {
            return availableMovies
        } else {
            return filteredMovies
        }
    }
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Review", systemImage: "plus.circle") {
                ReviewView()
            }
            Tab("Saved", systemImage: "bookmark") {
                SavedView()
            }
            Tab(role: .search) {
                NavigationStack {
                    VStack(spacing: 0) {
                        // Header with dynamic title
                        VStack(alignment: .leading, spacing: 4) {
                            if shouldShowPreviewSection {
                                Text("Search")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top,-15)
                            } else if !currentSearchText.isEmpty {
                                Text("Showing results for")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("\"\(currentSearchText)\"")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("Filtered Results")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        .background(Color.paletteBackground)
                        
                        // Show preview section when no search and no filters
                        if shouldShowPreviewSection {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Popular Movies")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(previewMovies) { movie in
                                            VStack(alignment: .leading, spacing: 8) {
                                                Button {
                                                    selectedMovie = movie
                                                } label: {
                                                    Image(movie.posterLandscape)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 180, height: 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Text(movie.name)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                
                                                Text(movie.genres.joined(separator: " • "))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(width: 180)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Text("All Movies")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
                            .padding(.bottom, 16)
                        }
                        
                        // Movie list
                        if moviesToShow.isEmpty {
                            // Show empty state
                            VStack(spacing: 20) {
                                Image(systemName: "film")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No movies found")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Try adjusting your search or filters")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxHeight: .infinity)
                            .padding()
                        } else {
                            List(moviesToShow) { movie in
                                VStack {
                                    ZStack(alignment: .top) {
                                        Button {
                                            selectedMovie = movie
                                        } label: {
                                            Image(movie.posterLandscape)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 370, height: 240)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                        }
                                        .buttonStyle(.plain)

                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                        .allowsHitTesting(false)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))

                                        HStack {
                                            Text(movie.name)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.paletteText)
                                            Spacer()
                                        }
                                        .allowsHitTesting(false)
                                        .padding(10)
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.paletteBackground)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
                    .background(Color.paletteBackground.ignoresSafeArea())
                    .toolbar {
                        ToolbarItem {
                            // FIXED: Simplified filter button without border
                            Button { filterSearch() } label: {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .toolbarBackground(Color.paletteBackground, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .searchable(text: $currentSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search movies...")
                    .navigationDestination(item: $selectedMovie) { movie in
                        MovieView(movie: movie)
                    }
                    .sheet(isPresented: $showFilters) {
                        FilterView(isPresented: $showFilters, options: $filters, allGenres: allGenres)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }
                    .onChange(of: currentSearchText) { oldValue, newValue in
                        print("Search text changed: '\(newValue)'")
                        print("Movies to show count: \(moviesToShow.count)")
                    }
                }
            }
        }
        .tint(Color.paletteBigBlock)
        .onAppear { loadMovies() }
    }
       
}

#Preview {
    RootTabView()
}
