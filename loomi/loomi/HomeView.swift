//
//  HomeView.swift
//  loomi
//
//  Created by Zayn on 1/12/2025.
//
import SwiftUI

struct HomeView: View {
    @State private var isSelected = false
    @State private var currentIndex = 3 // Start on card 3 (zero-based index)
    @State private var movies: [Movie] = []
    @State private var selectedMovie: Movie?
    @State private var options = FilterOptions()
    private let userName = "Beck"

    // Demo: most selected value this week
    private let mostSelectedValue: String = "Empathy"

    @State private var selectedChipText: String?
    
    private func reloadSuggestions() {
        // Reload from database; in a real app you might randomize or fetch fresh recommendations
        movies = MovieDataManager.loadMovies()
        // Prefer to start on card 3 (index 2) when possible
        if displayedMovies.count >= 3 {
            currentIndex = 2
        } else {
            currentIndex = min(currentIndex, max(0, displayedMovies.count - 1))
        }
        if displayedMovies.indices.contains(currentIndex) == false {
            currentIndex = max(0, displayedMovies.count - 1)
        }
    }
    
    private var displayedMovies: [Movie] {
        Array(movies.prefix(5))
//        if let selectedChipText {
//            return movies.filter { possibleMovie in
//                possibleMovie.values.contains(selectedChipText)
//            }
//        } else {
//            return Array(movies.prefix(5))
//        }
    }
    
    private var displayedValues: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for movie in displayedMovies {
            for value in movie.values {
                if seen.insert(value).inserted {
                    result.append(value)
                }
            }
        }
        return result
    }
    
    private var orderedDisplayedValues: [String] {
        var values = displayedValues

        // Pull out specific values we want to reposition
        var selfCompassion: String?
        if let idx = values.firstIndex(where: { $0.caseInsensitiveCompare("Self Compassion") == .orderedSame || $0.caseInsensitiveCompare("Self-Compassion") == .orderedSame }) {
            selfCompassion = values.remove(at: idx)
        }

        var loyalty: String?
        if let idx = values.firstIndex(where: { $0.caseInsensitiveCompare("Loyalty") == .orderedSame }) {
            loyalty = values.remove(at: idx)
        }

        var mindfulness: String?
        if let idx = values.firstIndex(where: { $0.caseInsensitiveCompare("Mindfulness") == .orderedSame || $0.caseInsensitiveCompare("Mindfullness") == .orderedSame }) {
            mindfulness = values.remove(at: idx)
        }

        // Reinsert at preferred positions (assuming ~3 columns)
        if let item = selfCompassion {
            let target = min(6, values.count)
            values.insert(item, at: target) // row 3 start
        }
        if let item = loyalty {
            let target = min(7, values.count)
            values.insert(item, at: target) // row 3, middle position next to Self-Compassion
        }
        if let item = mindfulness {
            let target = min(9, values.count)
            values.insert(item, at: target) // row 4 start (next row)
        }

        return values
    }

    private var mostFrequentDisplayedValue: String? {
        var counts: [String: Int] = [:]
        for movie in displayedMovies {
            for value in movie.values {
                counts[value, default: 0] += 1
            }
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private func focusMovie(withID id: Int) {
        guard !movies.isEmpty else { return }
        guard let existingIndex = movies.firstIndex(where: { $0.id == id }) else { return }
        var reordered = movies
        let target = reordered.remove(at: existingIndex)
        let insertionIndex = min(2, reordered.count)
        reordered.insert(target, at: insertionIndex)
        movies = reordered
        // Center on the third card (index 2) if available; otherwise clamp to last index
        let desiredIndex = 2
        currentIndex = min(desiredIndex, max(2, displayedMovies.count - 1))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    greeting
                    stackedCarousel
                        .padding(.top, 8)
                    exploreSection
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(
                Color.paletteBackground
                    .ignoresSafeArea(.all)
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ProfileView(options: $options)
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.paletteBigBlock)
                    }
                }
            }
            .navigationDestination(item: $selectedMovie) { movie in
                MovieView(movie: movie)
            }
            .onAppear {
                movies = MovieDataManager.loadMovies()
                if displayedMovies.count >= 3 {
                    currentIndex = 2
                } else {
                    currentIndex = min(currentIndex, max(0, displayedMovies.count - 1))
                }
            }
        }
    }

    // MARK: - Header (unused but kept)

    var header: some View {
        HStack {
            Spacer()
            Button {
                print("Profile tapped")
            } label: {
               Image(systemName: "person.crop.circle.fill")
                   .font(.system(size: 22, weight: .bold))
                   .foregroundStyle(.primary)
                   .padding(10)
                   .background(.ultraThinMaterial, in: Circle())
            }
        }
    }

    // MARK: - Greeting

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hi \(userName),")
                .font(.system(size: 34, weight: .bold))          // 34pt heading
                .foregroundStyle(Color.paletteText)

            Text("Here are your next suggested picks:")
                .font(.system(size: 17, weight: .regular))       // 17pt subheading
                .foregroundStyle(Color.paletteText.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, -70)
    }

    // MARK: - Stacked Carousel (overlapping, center on top)

    private var stackedCarousel: some View {
        StackedCarousel(
            items: Array(displayedMovies.enumerated()),
            index: $currentIndex,
            cardSize: CGSize(width: 250, height: 275),
            sidePeek: 25,
            sideScale: 1,
            layerSpacing: 15,
            reloadAction: reloadSuggestions
        ) { pair in
            let (offset, movie) = pair

            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.clear)
                    .overlay(
                        Group {
                            if let url = URL(string: movie.posterPortrait), url.scheme != nil {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure:
                                        Image(systemName: "photo").resizable().scaledToFit().padding(30)
                                    @unknown default:
                                        Color.clear
                                    }
                                }
                            } else {
                                Image(movie.posterPortrait)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        LinearGradient(colors: [Color.black.opacity(0.01), Color.black.opacity(0.22)], startPoint: .top, endPoint: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    )

                // Foreground overlays (only on the selected card)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            // Remove the current movie and adjust index safely
                            if displayedMovies.indices.contains(currentIndex) {
                                let toRemove = displayedMovies[currentIndex]
                                if let idx = movies.firstIndex(where: { $0.id == toRemove.id }) {
                                    movies.remove(at: idx)
                                }
                                currentIndex = min(currentIndex, max(0, displayedMovies.count - 1))
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)

                    Spacer()

                    // Values chips (on card) – fixed width 110
                    if !(movie.values).isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(movie.values, id: \.self) { value in
                                    Text(value)
                                        .font(.system(size: 15, weight: .regular)) // 15pt value text
                                        .foregroundStyle(Color.paletteBackground)
                                        .frame(width: 110, alignment: .center)     // <-- 110pt width
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(Color.paletteValue)
                                        )
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .opacity(offset == currentIndex ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedMovie = movie
            }
        }
        .frame(height: 300)
        .padding(.top, -5)
    }

    // MARK: - Explore

    private var exploreSection: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Single card that contains both the label and the highlighted value
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.paletteBigBlock)
                .overlay(
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Most selected\nvalue this week")
                                .font(.system(size: 17, weight: .regular)) // subheading
                                .foregroundStyle(Color.paletteBackground)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Highlighted value pill on the right
                        ZStack {
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .fill(isSelected ? Color.paletteBackground : Color.paletteValue)
                                        .animation(.easeInOut(duration: 0.2), value: isSelected) // smooth transition

                                    Button(action: {
                                        isSelected.toggle()
                                        focusMovie(withID: 7)
                                    }) {
                                        Text("Kindness")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(isSelected ? Color.paletteValue : Color.paletteBackground)
                                            .padding()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // removes default button styling
                                }
                                .frame(width: 175)
                            }
                        .padding(20)
                )
                .frame(height: 100)
            
            Text("Explore other values to update your suggested picks")
                .font(.system(size: 17, weight: .regular))        // subheading style
                .foregroundStyle(Color.paletteText)

            chipRows
        }
        .padding(.vertical, 20)
    }

    private var chipRows: some View {
        RaggedRightBubblesLayout(bubbleSpacing: 12, verticalSpacing: 12) {
            ForEach(orderedDisplayedValues, id: \.self) { value in
                chip(value)
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func chip(_ title: String) -> some View {
        Button {
            selectedChipText = title
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .regular))           // 15pt value text
                .foregroundStyle(Color.paletteBackground)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.paletteValue)
                )
        }
    }

    private func chipRow(_ titles: [String]) -> some View {
        HStack(spacing: 12) {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.tertiarySystemFill))
                    )
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Reusable StackedCarousel (overlapping deck)

// Update StackedCarousel to accept reloadAction closure
private struct StackedCarousel<Item: Identifiable, Content: View>: View {
    private let items: [Item]
    @Binding private var index: Int
    private let cardSize: CGSize
    private let sidePeek: CGFloat
    private let sideScale: CGFloat
    private let layerSpacing: CGFloat
    private let content: (Item) -> Content
    private let reloadAction: () -> Void

    // Convenience init for enumerated arrays (index, value)
    init<Wrapped>(
        items: [(offset: Int, element: Wrapped)],
        index: Binding<Int>,
        cardSize: CGSize,
        sidePeek: CGFloat = 36,
        sideScale: CGFloat = 0.9,
        layerSpacing: CGFloat = 16,
        reloadAction: @escaping () -> Void = {},
        @ViewBuilder content: @escaping ((offset: Int, element: Wrapped)) -> Content
    ) where Item == _PairIdentified<Wrapped> {
        self.items = items.map { _PairIdentified(offset: $0.offset, element: $0.element) }
        self._index = index
        self.cardSize = cardSize
        self.sidePeek = sidePeek
        self.sideScale = sideScale
        self.layerSpacing = layerSpacing
        self.reloadAction = reloadAction
        self.content = { pair in content((offset: pair.offset, element: pair.element)) }
    }

    @GestureState private var drag: CGFloat = 0

    var body: some View {
        ZStack {
            if items.isEmpty {
                Button {
                    reloadAction()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 22, weight: .bold))
                        Text("No more suggestions")
                            .font(.system(size: 17, weight: .bold))
                        Text("Tap to get more")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: cardSize.width, height: cardSize.height)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
            } else {
                ForEach(items.indices, id: \.self) { i in
                    let rel = CGFloat(i - index)
                    let isCenter = i == index

                    let xBase: CGFloat = rel * sidePeek
                    let xDrag: CGFloat = drag / 8
                    let depth: CGFloat = rel * layerSpacing

                    let scale: CGFloat = isCenter ? 1.0 : sideScale
                    let y: CGFloat = isCenter ? 0 : 8
                    let z: Double = Double(1000 - Int(abs(rel) * 10))
                    let opacity: Double = isCenter ? 1.0 : 0.92
                    let blurRadius: CGFloat = isCenter ? 0 : 0.5

                    content(items[i])
                        .frame(width: cardSize.width, height: cardSize.height)
                        .shadow(color: .black.opacity(0.08), radius: isCenter ? 18 : 12, x: 0, y: 10)
                        .scaleEffect(scale)
                        .blur(radius: blurRadius)
                        .opacity(opacity)
                        .offset(x: xBase + depth + xDrag, y: y)
                        .zIndex(z)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: cardSize.height, maxHeight: cardSize.height)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .updating($drag) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    guard !items.isEmpty else { return }
                    let threshold: CGFloat = 60
                    if value.translation.width < -threshold, index < items.count - 1 {
                        index += 1
                    } else if value.translation.width > threshold, index > 0 {
                        index -= 1
                    }
                }
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: index)
    }
}

private struct _PairIdentified<Wrapped>: Identifiable {
    let offset: Int
    let element: Wrapped
    var id: Int { offset }
}

#Preview {
    HomeView()
}

struct RaggedRightBubblesLayout: Layout {
    var bubbleSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if width + size.width > maxWidth {
                height += rowHeight + verticalSpacing
                width = 0
                rowHeight = 0
            }
            width += size.width + bubbleSpacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let boundaryWidth = bounds.width
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            if currentX + subviewSize.width > bounds.minX + boundaryWidth {
                currentX = bounds.minX
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(subviewSize)
            )
            currentX += subviewSize.width + bubbleSpacing
            rowHeight = max(rowHeight, subviewSize.height)
        }
    }
}

