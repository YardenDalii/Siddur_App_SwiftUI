
import SwiftUI


struct TehillimView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject var TehillimModel = TehillimViewModel()

    @State private var searchText = ""

    let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(TehillimModel.episodeGroups) { group in
                    EpisodeGroupView(group: group)
                        .environmentObject(TehillimModel)
                }
            }
            .background {
                Image("pageBG")
            }
            .navigationTitle("TEHILLIM_LOC_STRING")
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "EPISODE_NUM_PROMPT")
            .onChange(of: searchText) { oldValue, newValue in
                TehillimModel.searchText = newValue
            }
            .onAppear {
                TehillimModel.updateSortAndFilter()
            }
            .toolbar {
                sortMenu
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
                    .border(Color.black)
                    .cornerRadius(6)
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
            Button(action: { TehillimModel.toggleFavorite(for: episode.id) }) {
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
