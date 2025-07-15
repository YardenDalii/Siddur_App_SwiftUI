import SwiftUI

struct TehillimView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var TehillimModel = TehillimViewModel()
    
    @State private var searchText = ""
    @State private var currentGroupTitle: String = ""
    
    var filteredEpisodeGroups: [EpisodeGroup] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return TehillimModel.episodeGroups
        }
        
        let lowercasedSearch = searchText.lowercased()
        
        // Filter episodes within groups by searchText
        let groupsWithFilteredEpisodes = TehillimModel.episodeGroups.compactMap { group in
            let filteredEpisodes = group.episodes.filter { episode in
                episode.name.lowercased().contains(lowercasedSearch)
            }
            if !filteredEpisodes.isEmpty {
                return EpisodeGroup(id: group.id, title: group.title, episodes: filteredEpisodes)
            } else {
                return nil
            }
        }
        return groupsWithFilteredEpisodes
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(filteredEpisodeGroups) { group in
                    TehillimGroupSection(group: group, updateCurrentGroupIfNeeded: updateCurrentGroupIfNeeded)
                        .environmentObject(TehillimModel)
                }
            }
            .coordinateSpace(name: "tehillimScroll")
            .background {
                ImageBackgroundView()
                    .ignoresSafeArea()
            }
            .searchable(text: $searchText, prompt: "EPISODE_NUM_PROMPT")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                TehillimModel.updateSortAndFilter()
                currentGroupTitle = filteredEpisodeGroups.first?.title ?? ""
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavTitleView(title: "TEHILLIM_LOC_STRING", section: currentGroupTitle)
                }
                ToolbarItem(placement: .topBarLeading) {
                    
                }
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItemGroup(placement: .topBarTrailing) {
                    sortMenu
                }
            }
        }
    }
    
    private func updateCurrentGroupIfNeeded(title: String, y: CGFloat) {
        if y < 80 && y > 0 && currentGroupTitle != title {
            currentGroupTitle = title
        }
    }
    
    var sortMenu: some View {
        Menu {
            Button("SORT_DAY_LOC", action: { TehillimModel.sortCriterion = .day })
            Button("SORT_BOOK_LOC", action: { TehillimModel.sortCriterion = .book })
            Button("SORT_FAV_LOC", action: { TehillimModel.sortCriterion = .favorite })
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundStyle(CustomPalette.golden.color)
        }
    }
}

struct Book: View {
    
    @EnvironmentObject var TehillimModel: TehillimViewModel
    
    let episode: TehillimEpisode
    let episodeGroup: EpisodeGroup
    
    var body: some View {
        NavigationLink(destination: TehillimPageView(episode: episode, groupName: episodeGroup.title, episodeGroup: episodeGroup.episodes).environmentObject(TehillimModel)) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [CustomPalette.brown.color, Color.brown.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 44, height: 150)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.black)
                    )
                    .containerRelativeFrame(.horizontal, count: 8, spacing: 11)
                
                VStack(spacing: 80) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.white)
                        .frame(width: 42, height: 15)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.white)
                        .frame(width: 42, height: 15)
                }
                Text(episode.name)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)
            }
        }
        .contextMenu {
            Button {
                TehillimModel.toggleFavorite(for: episode.id)
            } label: {
                Text(TehillimModel.isFavorite(episodeId: episode.id) ? "REMOVE_FAVS" : "ADD_FAVS")
                Image(systemName: TehillimModel.isFavorite(episodeId: episode.id) ? "star.fill" : "star")
            }
        }
    }
}

struct Shelf: View {
    var body: some View {
        Rectangle()
            .frame(height: 30)
            .foregroundColor(CustomPalette.brown.color)
            .shadow(radius: 1)
    }
}

struct EpisodeGroupView: View {
    let group: EpisodeGroup
    
    var body: some View {
        Section {
            Text(NSLocalizedString(group.title, comment: ""))
                .padding(.top, 5)
                .bold()
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(group.episodes) { episode in
                        Book(episode: episode, episodeGroup: group)
                    }
                }
            }
            .scrollTargetLayout()
            Shelf()
        }
        .contentMargins(16, for: .scrollContent)
        .scrollTargetBehavior(.paging)
    }
}

// MARK: - Group Section Helper
private struct TehillimGroupSection: View {
    let group: EpisodeGroup
    let updateCurrentGroupIfNeeded: (String, CGFloat) -> Void
    @EnvironmentObject var tehillimModel: TehillimViewModel
    
    var body: some View {
        Section {
            ZStack {
                Text(NSLocalizedString(group.title, comment: ""))
                    .font(.system(size: 20))
                    .padding(.top, 5)
                    .bold()
                GeometryReader { geo in
                    Color.clear
                        .onAppear { updateCurrentGroupIfNeeded(group.title, geo.frame(in: .named("tehillimScroll")).minY) }
                        .onChange(of: geo.frame(in: .named("tehillimScroll")).minY) { _, newY in
                            updateCurrentGroupIfNeeded(group.title, newY)
                        }
                }
                .frame(height: 0)
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(group.episodes) { episode in
                        Book(episode: episode, episodeGroup: group)
                    }
                }
            }
            .scrollTargetLayout()
            Shelf()
        }
        .contentMargins(16, for: .scrollContent)
        .scrollTargetBehavior(.paging)
        .environmentObject(tehillimModel)
    }
}

#Preview {
    TehillimView()
        .environmentObject(AppSettings())
}
