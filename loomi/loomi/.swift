import SwiftUI

struct SearchView2: View {
    @State private var query = ""
    @State private var results: [String] = []

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Search")
        }
        .searchable(text: $query, placement: .automatic, prompt: "Search")
        .onChange(of: query) { _, newValue in
            performSearch(for: newValue)
        }
    }

    @ViewBuilder
    private var content: some View {
        if query.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text("Start typing to search")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if results.isEmpty {
            Text("No results for \(query)")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(results, id: \.self) { item in
                Text(item)
            }
            .listStyle(.insetGrouped)
        }
    }

    private func performSearch(for text: String) {
        // Replace this with your real search logic.
        let allItems = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            results = []
        } else {
            results = allItems.filter { $0.localizedCaseInsensitiveContains(trimmed) }
        }
    }
}

#Preview {
    SearchView()
}
