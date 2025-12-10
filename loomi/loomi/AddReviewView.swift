import SwiftUI
import UIKit

// MARK: - Hex → Color helper

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Add Review

struct AddReviewView: View {
    private let movie: MovieItem          // Selected movie to review
    private let movieID: String?
    private let movieLookup: ((String) -> MovieItem?)?

    // Preferred initializer when you already have the full model
    init(movie: MovieItem) {
        self.movie = movie
        self.movieID = nil
        self.movieLookup = nil
    }

    // Fallback initializer when you only have an ID and a lookup function
    init(movieID: String, lookup: @escaping (String) -> MovieItem?) {
        let resolvedMovie = lookup(movieID) ?? MovieItem(
            id: movieID,
            title: "Unknown Movie",
            posterPortraitAssetName: "",
            posterLandscapeAssetName: ""
        )
        self.movie = resolvedMovie
        self.movieID = movieID
        self.movieLookup = { id in lookup(id) }
    }

    @Environment(\.dismiss) private var dismiss

    @State private var recommendation: Bool? = nil      // nil = nothing, true = up, false = down
    @State private var selectedValues: Set<String> = []
    @State private var showAllValues = false
    @State private var comment: String = ""
    @State private var showSubmittedAlert = false
    @State private var showValidationAlert = false

    // Palette
    private let backgroundColor   = Color(hex: "282828")
    private let lightGray         = Color(hex: "D9D9D9")
    private let accentGreen       = Color(hex: "CBFF8C")
    private let softYellow        = Color(hex: "E4E6C3")

    // Replace these with DB values later
    private let topValues  = ["Empathy", "Family", "Growth"]
    private let moreValues = ["Courage", "Friendship", "Hope", "Kindness", "Resilience"]

    private var valuesToShow: [String] {
        showAllValues ? (topValues + moreValues) : topValues
    }

    private var isValid: Bool {
        recommendation != nil && !selectedValues.isEmpty
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {   // section spacing
                movieHeader
                recommendSection
                valuesSection
                commentSection
                submitButton
                Spacer(minLength: 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationTitle("Leave a Review")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)   // ✅ hide system back, keep only custom one
        .toolbar {
            // Back to previous view (ReviewView)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            // Profile button – navigates to your ProfileView
            ToolbarItem(placement: .navigationBarTrailing) {
            }
        }
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Review submitted", isPresented: $showSubmittedAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Thank you for leaving a review.")
        }
        .alert("Incomplete Review", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please choose thumbs up or thumbs down and select at least one value before submitting.")
        }
    }

    // MARK: - Subviews

    private var movieHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(movie.title)
                .font(.system(size: 34, weight: .bold)) // heading
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .offset(x: -16)

            posterView
        }
        .padding(.top, 25)
    }

    @ViewBuilder
    private var posterView: some View {
        if !movie.posterPortraitAssetName.isEmpty {
            Image(movie.posterPortraitAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 200)  // 300x150
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityLabel(Text("Poster for \(movie.title)"))
                .clipped()
                .frame(maxWidth: .infinity, alignment: .center)
        } else if !movie.posterLandscapeAssetName.isEmpty {
            Image(movie.posterLandscapeAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityLabel(Text("Poster for \(movie.title)"))
                .clipped()
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(lightGray)
                .frame(width: 300, height: 150)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var recommendSection: some View {
        VStack(spacing: 20) {
            Text("Would you recommend this movie for kids?")
                .font(.system(size: 17, weight: .regular)) // subheading
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 50) {
                Button {
                    recommendation = (recommendation == true ? nil : true)
                } label: {
                    Image(systemName: recommendation == true ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.system(size: 34, weight: .semibold))
                        .frame(width: 50, height: 50) // 50x50
                        .foregroundColor(.white)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: recommendation)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Recommend thumbs up")
                .accessibilityAddTraits(recommendation == true ? .isSelected : [])

                Button {
                    recommendation = (recommendation == false ? nil : false)
                } label: {
                    Image(systemName: recommendation == false ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.system(size: 34, weight: .semibold))
                        .frame(width: 50, height: 50) // 50x50
                        .foregroundColor(.white)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: recommendation)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Recommend thumbs down")
                .accessibilityAddTraits(recommendation == false ? .isSelected : [])
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var valuesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What values did you find in this movie?")
                .font(.system(size: 17, weight: .regular)) // subheading
                .foregroundColor(.white)

            ValuesChipsView(
                values: valuesToShow,
                selectedValues: $selectedValues
            )

            Button {
                withAnimation {
                    showAllValues.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(showAllValues ? "Collapse values" : "Expand for more values")
                    Image(systemName: showAllValues ? "chevron.up" : "chevron.down")
                }
                .font(.system(size: 15, weight: .regular)) // same as values text
                .foregroundColor(.white.opacity(0.9))
            }
        }
    }

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Leave a comment")
                .font(.system(size: 17, weight: .regular)) // subheading
                .foregroundColor(.white)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(softYellow)

                TextEditor(text: $comment)
                    .font(.system(size: 15, weight: .regular)) // body text
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundColor(.black)
            }
            .frame(minHeight: 150)
        }
    }

    private var submitButton: some View {
        Button {
            if isValid {
                submitReview()
                showSubmittedAlert = true
            } else {
                showValidationAlert = true
            }
        } label: {
            Text("Submit")
                .font(.system(size: 15, weight: .regular)) // submit text
                .foregroundColor(.black.opacity(isValid ? 1.0 : 0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.paletteBigBlock))
                
                .animation(.easeInOut(duration: 0.15), value: isValid)
        }
        .padding(.top, 8)
    }

    // MARK: - Submit

    private func submitReview() {
        let resolvedMovie: MovieItem = {
            if let id = movieID, let lookup = movieLookup, let found = lookup(id) {
                return found
            } else {
                return movie
            }
        }()

        let payload: [String: Any] = [
            "movieID": resolvedMovie.id,
            "title": resolvedMovie.title,
            "recommendation": recommendation as Any,
            "values": Array(selectedValues),
            "comment": comment
        ]

        // Replace with your save / network call
        print("Submitting review payload: \(payload)")
    }
}

// MARK: - Value chips

struct ValuesChipsView: View {
    let values: [String]
    @Binding var selectedValues: Set<String>

    // 5 points (~5 px) horizontal & vertical spacing between buttons
    private let chipSpacing: CGFloat = 5

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 100), spacing: chipSpacing)  // min width 100, spacing 5
        ]
    }

    private let accentGreen = Color(hex: "CBFF8C")
    private let softYellow  = Color(hex: "E4E6C3")

    var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: chipSpacing      // vertical spacing
        ) {
            ForEach(values, id: \.self) { value in
                let isSelected = selectedValues.contains(value)

                Button {
                    if isSelected {
                        selectedValues.remove(value)
                    } else {
                        selectedValues.insert(value)
                    }
                } label: {
                    Text(value)
                        .font(.system(size: 15, weight: .regular)) // values text
                        .frame(width: 110, height: 30)             // your current chip size
                        .foregroundColor(.black)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? accentGreen : softYellow)
                        )
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("AddReviewView – Movie instance") {
    AddReviewView(movie: .preview)
}

#Preview("AddReviewView – Lookup by ID") {
    let db: [String: MovieItem] = [
        "42": MovieItem(id: "42",
                        title: "Spirited Away",
                        posterPortraitAssetName: "spirited_away_portrait",
                        posterLandscapeAssetName: "spirited_away")
    ]
    AddReviewView(movieID: "42") { id in db[id] }
}

#if DEBUG
private extension MovieItem {
    static var preview: MovieItem {
        MovieItem(
            id: UUID().uuidString,
            title: "Sample Movie",
            posterPortraitAssetName: "sample_poster_portrait",
            posterLandscapeAssetName: "sample_poster_landscape"
        )
    }
}
#endif
