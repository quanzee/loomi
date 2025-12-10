import SwiftUI
import Combine

// MARK: - Data contracts you can wire to your DB

struct MovieItem: Identifiable, Hashable {
    let id: String
    let title: String
    let posterPortraitAssetName: String
    let posterLandscapeAssetName: String
}

protocol MovieRepository {
    func fetchAllMovies() async throws -> [MovieItem]
}

private struct MovieDTO: Decodable {
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
}

// Replace this with your real implementation.
// For example, map your DB entities to MovieItem(id:title:...)
struct DefaultMovieRepository: MovieRepository {
    func fetchAllMovies() async throws -> [MovieItem] {
        // Load local JSON named "database.json" from the main bundle
        guard let url = Bundle.main.url(forResource: "database", withExtension: "json") else {
            return []
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let dtos = try decoder.decode([MovieDTO].self, from: data)

        // Map DTOs to MovieItem used by the UI.
        // Now we store BOTH portrait + landscape asset names.
        let items: [MovieItem] = dtos.map { dto in
            MovieItem(
                id: String(dto.id),
                title: dto.name,
                posterPortraitAssetName: dto.posterPortrait,
                posterLandscapeAssetName: dto.posterLandscape
            )
        }
        return items
    }
}

// MARK: - View Model

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var allMovies: [MovieItem] = []
    @Published var recentMovies: [MovieItem] = []

    private let repository: MovieRepository

    init(repository: MovieRepository = DefaultMovieRepository()) {
        self.repository = repository
    }

    func load() async {
        do {
            let movies = try await repository.fetchAllMovies()
            self.allMovies = movies
            self.recentMovies = Array(movies.prefix(4))
        } catch {
            // Handle error (log, alert, etc.)
            print("Failed to load movies: \(error)")
            self.allMovies = []
            self.recentMovies = []
        }
    }
}

// MARK: - View

struct ReviewView: View {
    var onExit: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @StateObject private var viewModel: ReviewViewModel

    init(onExit: (() -> Void)? = nil) {
        self.onExit = onExit
        _viewModel = StateObject(wrappedValue: ReviewViewModel())
    }

    // 2-column grid
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // Single-expression computed property to avoid explicit returns
    var filteredResults: [MovieItem] {
        searchText.isEmpty
        ? viewModel.allMovies
        : viewModel.allMovies.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Match AddReviewView background
                Color(hex: "282828").ignoresSafeArea()

                    // MARK: - Search bar (top of the page content)

                    // MARK: - Grid content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {

                            if searchText.isEmpty {
                                Text("Recent Searches")
                                    .font(.system(size: 17, weight: .regular)) // subheading
                                    .foregroundStyle(Color.paletteText)
                                    .padding(.horizontal, 20)

                                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                                    ForEach(viewModel.recentMovies) { movie in
                                        NavigationLink {
                                            AddReviewView(movie: movie)
                                        } label: {
                                            // Use PORTRAIT poster in the grid
                                            ReviewGridItem(
                                                title: movie.title,
                                                assetName: movie.posterPortraitAssetName
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            } else {
                                Text("Searched Results")
                                    .font(.system(size: 17, weight: .regular)) // subheading
                                    .foregroundStyle(Color.paletteText)
                                    .padding(.horizontal, 20)

                                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                                    ForEach(filteredResults) { movie in
                                        NavigationLink {
                                            AddReviewView(movie: movie)
                                        } label: {
                                            ReviewGridItem(
                                                title: movie.title,
                                                assetName: movie.posterPortraitAssetName
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            Spacer().frame(height: 24)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            // Large nav title = 34pt SF Pro
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search movies to review")
            .navigationBarBackButtonHidden(true) // ✅ No back button on ReviewView
            .toolbarBackground(Color(hex: "282828"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { await viewModel.load() }
        }
    }

// MARK: - Grid item for posters

struct ReviewGridItem: View {
    let title: String
    let assetName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .aspectRatio(4/5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityLabel(Text(title))

            Text(title)
                .font(.system(size: 15, weight: .regular))  // match values / submit text size
                .lineLimit(2)
                .foregroundStyle(Color.paletteText)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    ReviewView()
}
