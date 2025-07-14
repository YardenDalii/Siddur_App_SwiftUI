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
                        CreditURLItem(label: credit.label,
                                      description: credit.description,
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("ABOUT_LOC_STRING")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
//                            .foregroundStyle(CustomPalette.golden.color)
                }
            }
        }
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
    var description: String
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
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString(label, comment: ""))
                    .font(.headline)
                Text(NSLocalizedString(description, comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
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
    case hebcalApi, pasuk, tehillim, sefaria
    
    var rawValue: String {
        switch self {
        case .pasuk:
            return "https://he.wikisource.org/wiki/פסוק_המתחיל_ומסתיים_באות"
        case .hebcalApi:
            return "https://www.hebcal.com/home/developer-apis"
        case .tehillim:
            return "https://tehilim.co"
        case .sefaria:
            return "https://www.sefaria.org.il/"
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
        case .sefaria:
            return "SEFARIA_CREDITS_LOC"
        }
    }
    
    var description: String {
        switch self {
        case .pasuk:
            return "PASUK_CREDITS_DESC"
        case .hebcalApi:
            return "HEBCAL_CREDITS_DESC"
        case .tehillim:
            return "TEHILLIM_CREDITS_DESC"
        case .sefaria:
            return "SEFARIA_CREDITS_DESC"
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
        case .sefaria:
            return "sefaria_logo"
        }
    }
    
    var bgColor: Color {
        switch self {
        case .pasuk:
            return CustomPalette.hebcal.color
        case .hebcalApi:
            return CustomPalette.hebcal.color
        case .tehillim:
            return CustomPalette.darkBlue.color
        case .sefaria:
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
