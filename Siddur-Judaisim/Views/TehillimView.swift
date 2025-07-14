import SwiftUI

struct TehillimView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var TehillimModel = TehillimViewModel()
    
    @State private var searchText = ""
    
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
                    EpisodeGroupView(group: group)
                        .environmentObject(TehillimModel)
                }
            }
            .background {
                ImageBackgroundView()
                    .ignoresSafeArea()
            }
            .searchable(text: $searchText, prompt: "EPISODE_NUM_PROMPT")
//            .searchable(text: $searchText, placement: .sidebar, prompt: "EPISODE_NUM_PROMPT")
//            .navigationTitle("TEHILLIM_LOC_STRING")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                TehillimModel.updateSortAndFilter()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("TEHILLIM_LOC_STRING")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
//                            .foregroundStyle(CustomPalette.golden.color)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    sortMenu
                }
            }
        }
    }
    
    var sortMenu: some View {
        Menu {
            Button("SORT_DAY_LOC", action: { TehillimModel.sortCriterion = .day })
            Button("SORT_BOOK_LOC", action: { TehillimModel.sortCriterion = .book })
            Button("SORT_FAV_LOC", action: { TehillimModel.sortCriterion = .favorite })
        } label: {
            Label("SORT_LOC_STRING", systemImage: "arrow.up.arrow.down")
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

#Preview {
    TehillimView()
        .environmentObject(AppSettings())
}
