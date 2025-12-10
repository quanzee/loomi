import SwiftUI

// Temporary alias to support older references while migrating to ProfileScreen
typealias ProfileView = ProfileScreen

struct ProfileScreen: View {
    // Optional binding to filter options so the profile can reflect user preferences
    @Binding var options: FilterOptions

    @State private var displayName: String = "Beck"
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                stats
                preferences
                account
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 96, height: 96)
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: 8) {
                TextField("Name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                Button {
                    // Placeholder for avatar change action
                } label: {
                    Label("Edit Photo", systemImage: "camera")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.headline)
            HStack(spacing: 12) {
                statCard(title: "Saved", value: "—", systemImage: "bookmark.fill")
                statCard(title: "Reviews", value: "—", systemImage: "star.bubble.fill")
                statCard(title: "Watch Time", value: "—", systemImage: "clock.fill")
            }
        }
    }

    private func statCard(title: String, value: String, systemImage: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var preferences: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.headline)
            VStack(spacing: 12) {
                HStack {
                    Label("Age", systemImage: "person.2.fill")
                    Spacer()
                    if options.useAgeRange {
                        Text("\(options.minAge)–\(options.maxAge)")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(options.childAge)")
                            .foregroundStyle(.secondary)
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    Label("Values", systemImage: "heart.fill")
                    if options.selectedValues.isEmpty {
                        Text("No values selected")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        WrapTags(tags: Array(options.selectedValues))
                    }
                }
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var account: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.headline)
            VStack(spacing: 0) {
                Toggle(isOn: $notificationsEnabled) {
                    Label("Notifications", systemImage: "bell.fill")
                }
                .padding()
                Divider()
                NavigationLink {
                    Text("Privacy Settings")
                        .navigationTitle("Privacy")
                } label: {
                    HStack {
                        Label("Privacy", systemImage: "lock.fill")
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                    }
                    .padding()
                }
                Divider()
                Button(role: .destructive) {
                    // Sign out action placeholder
                } label: {
                    HStack {
                        Label("Sign Out", systemImage: "arrow.right.square")
                        Spacer()
                    }
                    .padding()
                }
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// Simple tag wrap for preferences values
struct WrapTags: View {
    var tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
            ForEach(tags.sorted(), id: \.self) { tag in
                Text(tag)
                    .font(.footnote)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    @Previewable @State var options = FilterOptions()
    NavigationStack { ProfileScreen(options: $options) }
}
