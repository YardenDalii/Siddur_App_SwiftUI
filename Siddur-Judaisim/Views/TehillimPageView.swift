//
//  TehilimPAgeView.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 31/03/2024.
//

import SwiftUI
import UIKit


struct TehillimPageView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var TehillimModel: TehillimViewModel
    
    var episode: TehillimEpisode
    var groupName: String
    var episodeGroup: [TehillimEpisode]
    
    @State private var toolbarTitle: String = "Default"
    
    @State private var selectedTehillimEpisode = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTehillimEpisode) {
                ForEach(Array(episodeGroup.enumerated()), id: \.element.id) { index, episode in
                    EpisodeDetailView(episode: episode)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    selectedTehillimEpisode = episodeGroup.firstIndex(where: { $0.id == episode.id }) ?? 0
                }
            }
        }
        .navigationBarTitle(NSLocalizedString(groupName, comment: ""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                favoriteButton
                textSizeAdjustmentMenu
            }
        }
        
    }
    
    
    private var favoriteButton: some View {
        Button(action: {
            let currentEpisode = episodeGroup[selectedTehillimEpisode]
            TehillimModel.toggleFavorite(for: currentEpisode.id)
        }) {
            let currentEpisode = episodeGroup[selectedTehillimEpisode]
            Image(systemName: TehillimModel.isFavorite(episodeId: currentEpisode.id) ? "star.fill" : "star")
                .foregroundStyle(CustomPalette.golden.color)
        }
    }
    
    
    private var textSizeAdjustmentMenu: some View {
        Menu {
            Stepper("\(NSLocalizedString("TEXT_SIZE_LOC_STRING", comment: "")): \(Int(appSettings.textSize))", value: $appSettings.textSize, step: 1)
            
            Button(action: { appSettings.textSize = 20.0 }) {
                Text(NSLocalizedString("RESET_TO_DEFAULT", comment:""))
            }
        } label: {
            Label("TEXT_SIZE_LOC_STRING", systemImage: "textformat.size")
        }
    }
}



struct EpisodeDetailView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    var episode: TehillimEpisode
    
    var body: some View {
        ScrollView {
            Text(NSLocalizedString("TEHILLIM_EP_LOC", comment: "") + " \(episode.name)")
                .bold().font(.custom("Guttman Drogolin", size: appSettings.textSize * 1.5))
                .padding(.bottom, 1)
                .foregroundColor(CustomPalette.black.color)
            
            Divider()
            
            if let textContent = loadContent(fileName: episode.name) {
                Text(textContent.string)
//                    .font(.custom("Guttman Drogolin-Bold", size: textSize))
                    .font(.custom("Guttman Drogolin", size: appSettings.textSize))
//                    .font(.custom("Guttman Vilna-Bold", size: appSettings.textSize))
                    .padding()
                    .foregroundColor(CustomPalette.black.color)
//                    .multilineTextAlignment(.center)
                
            } else {
                Text("CONTANT_FAIL_LOADING")
            }
        }
        .background {
            Image("pageBG")
        }
        .padding(.top, 1)
        .environment(\.layoutDirection, .rightToLeft)
        
    }
}



struct TextSizePopoverView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack {
            Stepper("\(NSLocalizedString("TEXT_SIZE_LOC_STRING", comment: "")): \(Int(appSettings.textSize))", value: $appSettings.textSize, step: 1)
                .padding()
            Button(action: { appSettings.textSize = 20.0 }) {
                Text(NSLocalizedString("RESET_TO_DEFAULT", comment:""))
            }
            .padding(.top)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .frame(maxWidth: 200)
    }
}


//
//#Preview {
//    TehillimPageView(episode:.init(id: 1, name: "ה", isFavorite: true))
//        .environmentObject(AppSettings())
//}
