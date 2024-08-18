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
    
    let dailyPrayers: [Prayer] = [.init(name: NSLocalizedString("Shachar", comment: "")),
                                  .init(name: NSLocalizedString("Shacharit", comment: "")),
                                  .init(name: NSLocalizedString("Shacharit+", comment: "")),
                                  .init(name: NSLocalizedString("Mincha", comment: "")),
                                  .init(name: NSLocalizedString("Arvit", comment: "")),
                                  .init(name: NSLocalizedString("Bedtime-Shema", comment: "")),
                                  .init(name: NSLocalizedString("Tikkun-Chatzot", comment: ""))]
    
    let mazonPrayers: [Prayer] = [.init(name: NSLocalizedString("Birchat-Hamazon", comment: "")),
                                  .init(name: NSLocalizedString("Borei-Nefashot", comment: "")),
                                  .init(name: NSLocalizedString("Me'ein-Shalosh", comment: ""))]
    
    let temp: String = ""
    
}

