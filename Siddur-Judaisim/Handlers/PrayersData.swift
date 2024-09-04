//
//  PrayPage.swift
//  Siddur
//
//  Created by Yarden Dali on 27/03/2024.
//

import Foundation


struct PrayerData: Decodable {
    let prayer: Prayer
}


struct Prayer: Identifiable, Decodable, Hashable {
    var id: UUID = UUID()
    let name: String
}


struct MockPray {
    
    let dailyPrayers: [Prayer] = [.init(name: "Shachar"),
                                  .init(name: "Shacharit"),
                                  .init(name: "Shacharit+"),
                                  .init(name: "Mincha"),
                                  .init(name: "Arvit"),
                                  .init(name: "Bedtime-Shema"),
                                  .init(name: "Tikkun-Chatzot"),]
    
    let mazonPrayers: [Prayer] = [.init(name: "Birchat-Hamazon"),
                                  .init(name: "Borei-Nefashot"),
                                  .init(name: "Me'ein-Shalosh"),]
    
    let slichot: [Prayer] = [.init(name: "slichot1"),
                             .init(name: "slichot2"),
                             .init(name: "slichot3"),
                             .init(name: "slichot4"),
                             .init(name: "slichot5"),
                             .init(name: "slichot6"),
                             .init(name: "slichot7"),]
    
    let temp: String = ""
    
}

