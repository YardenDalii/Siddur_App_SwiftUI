//
//  AboutView.swift
//  Siddur
//
//  Created by Yarden Dali on 31/03/2024.
//

import SwiftUI

// AboutView
struct AboutView: View {
    @State private var isTapped: [CreditURL: Bool] = Dictionary(uniqueKeysWithValues: CreditURL.allCases.map { ($0, false) })
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("ACKS_CREDITS", comment: ""))) {
                    ForEach(CreditURL.allCases, id: \.self) { credit in
                        CreditURLItem(label: NSLocalizedString(credit.label, comment: ""),
                                      imageName: credit.imageName,
                                      bgColor: credit.bgColor)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isTapped[credit] = true
                                openCreditURL(credit: credit)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) {
                                    isTapped[credit] = false
                                }
                            }
                            .listRowBackground(isTapped[credit] ?? false ? Color.gray.opacity(0.3) : nil)
                    }
                }
            }
            .background(
                Image("pageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .scrollContentBackground(.hidden)
        }
        .navigationBarTitle(NSLocalizedString("ABOUT_LOC_STRING", comment: ""), displayMode: .inline)
    }
    
    private func openCreditURL(credit: CreditURL) {
        guard let url = URL(string: credit.rawValue), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

// CreditURLItem component
struct CreditURLItem: View {
    var label: String
    var imageName: String
    var bgColor: Color
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 6).fill(bgColor)
                    .frame(width: 28, height: 28)
                Image(imageName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString(label, comment: ""))
            Spacer()
            Image(systemName: NSLocalizedString("SETTINGS-ARROW-ICOM", comment: ""))
                .resizable()
                .bold()
                .foregroundColor(Color.gray.opacity(0.46))
                .frame(width: 6.8, height: 12)
        }
    }
}

// CreditURL Enum
enum CreditURL: CaseIterable {
    case hebcalApi, pasuk, tehillim
    
    var rawValue: String {
        switch self {
        case .pasuk:
            return "https://he.wikisource.org/wiki/פסוק_המתחיל_ומסתיים_באות"
        case .hebcalApi:
            return "https://www.hebcal.com/home/developer-apis"
        case .tehillim:
            return "https://tehilim.co"
        }
    }
    
    var label: String {
        switch self {
        case .pasuk:
            return "Pasuk-Credit"
        case .hebcalApi:
            return "Hebcal-Credit"
        case .tehillim:
            return "TEHILLIM_CREDITS_LOC"
        }
    }
    
    var imageName: String {
        switch self {
        case .pasuk:
            return "wikisource_logo"
        case .hebcalApi:
            return "hebcal_logo"
        case .tehillim:
            return "tehilim.co_logo"
        }
    }
    
    var bgColor: Color {
        switch self {
        case .pasuk:
            return .white
        case .hebcalApi:
            return CustomPalette.hebcal.color
        case .tehillim:
            return CustomPalette.darkBlue.color
        }
    }
}

#Preview {
    AboutView()
}

// NSLocalizedString(, comment: "")

// PASUK - https://he.wikisource.org/wiki/פסוק_המתחיל_ומסתיים_באות
// HebcalAPI - https://www.hebcal.com/home/developer-apis
// sefaria - https://www.sefaria.org.il/
// Daat - https://www.daat.ac.il/daat/sidurim/shaar-2.htm
// tehilim - https://tehilim.co/book/1/


#Preview {
    AboutView()
}
