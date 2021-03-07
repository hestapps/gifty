//
//  HomeView.swift
//  Gifty
//
//  Created by Joseph Francis on 3/2/21.
//

import SwiftUI
import QRCode

struct HomeView: View {
    
    @State fileprivate var isAddCardViewPresenting = false
    @State fileprivate var isDetailsCardViewPresenting = false
    
    @ObservedObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical) {
                    HStack {
                        Text("Your Cards")
                            .font(.title)
                        Spacer()
                        
                        if homeViewModel.cards.isEmpty {
                            Text("You don't have any cards saved. Tap 'Add Card' to add a new card.")
                        }
                    }
                    .padding(.top)
                    
                    ForEach(homeViewModel.cards, id: \.self) { card in
                        NavigationLink(
                            destination: CardDetailsView(card: card),
                            isActive: $isDetailsCardViewPresenting) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray)
                                    .frame(height: 210)
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        if let balance = card.presentableBalance {
                                            Text("$\(balance)")
                                                .padding(.top, 12)
                                                .padding(.trailing, 20)
                                                .font(.system(size: 20, weight: .bold))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("**** \(card.securedCardNumber)")
                                        Spacer()
                                        ZStack {
                                            Text(card.merchant)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding([.leading, .trailing, .bottom])
                                }
                            }
                        }
                        .padding([.trailing, .bottom])
                        .buttonStyle(DefaultTapStyle())
                    }
                }
                .padding(.leading)
                
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 26, height: 26)
                    
                    Text("Add Card")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .offset(y: -30)
                .onTapGesture {
                    isAddCardViewPresenting.toggle()
                }
                .sheet(isPresented: $isAddCardViewPresenting) {
                    AddCardView(isAddCardViewPresented: $isAddCardViewPresenting)
                }
            }
            .navigationBarTitle("Wallet", displayMode: .inline)
        }
    }
}

class HomeViewModel: ObservableObject {
    
    @Published fileprivate(set) var cards: [Card] = [Card]()
    
    fileprivate func fetchCards() {
        guard let cards = UserDefaultsManager.shared.retrieveSavedCards() else {
            return
        }
        
        self.cards = cards
    }
    
    init() {
        fetchCards()
    }
    
}

struct CardDetailsView: View {
    
    @State var card: Card
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("BALANCE")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("$\(card.presentableBalance)")
                            .font(.largeTitle)
                    }
                    Spacer()
                }
                .padding([.leading, .top])
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray)
                        .frame(height: 210)
                    
                    VStack {
                        
                        HStack {
                            Spacer()
                            Text(card.merchant)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding([.trailing, .top])
                        
                        Spacer()
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading) {
                                    Text("Card Number")
                                        .font(.subheadline)
                                        .foregroundColor(Color.black.opacity(0.5))
                                    
                                    Text(card.unsecuredCardNumber)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Pin Code")
                                        .font(.subheadline)
                                        .foregroundColor(Color.black.opacity(0.5))
                                    
                                    Text("\(String(card.pinCode))")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding([.bottom, .leading])
                        
                        Spacer()
                    }
                }
                .padding()
                
                if let img = card.qrCodeImage {
                    img
                }
            }
        }
        .navigationBarTitle(card.merchant)
    }
    
}

struct DefaultTapStyle: ButtonStyle {
    
    let backgroundColor: Color = .clear
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor)
    }
    
}

struct AddCardView: View {
    
    @State fileprivate var cardNumber = ""
    @State fileprivate var pinCodeNumber = ""
    @State fileprivate var merchant = ""
    @State fileprivate var balance = ""
    
    @State fileprivate var showErrorSavingCardAlert = false
    @Binding var isAddCardViewPresented: Bool
    
    var body: some View {
        VStack {
            Text("Add Card")
                .font(.headline)
                .padding([.top, .bottom], 20)
            
            VStack(spacing: 50) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Merchant")
                            .font(.title3)
                        TextField("Enter merchant...", text: $merchant)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Enter Card Number")
                            .font(.title3)
                        TextField("16 digits code...", text: $cardNumber)
                            .keyboardType(.numberPad)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Enter pin code")
                            .font(.title3)
                        TextField("4 digits code...", text: $pinCodeNumber)
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .font(.title3)
                        TextField("Enter balance (Optional)...", text: $balance)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Spacer()
            }
            .padding()
            
            Button(action: {
                let ifSaved = saveCard()
                guard !ifSaved else {
                    isAddCardViewPresented.toggle()
                    return
                }
                showErrorSavingCardAlert.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12.0)
                        .fill(Color.blue)
                        .frame(height: 44)
                    
                    Text("Add Card")
                        .foregroundColor(Color.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding()
            .alert(isPresented: $showErrorSavingCardAlert) {
                Alert(title: Text("Error Saving Card"), message: Text("There was an error saving the card. Please make sure that you've entered the card number, pin code, merchant, and the balance."))
            }
        }
    }
    
    func saveCard() -> Bool {
        guard cardNumber.count > 0 && pinCodeNumber.count > 0, merchant.count > 0 else {
            return false
        }
        
        guard let cardNumber = Int(cardNumber), let pinCodeNumber = Int(pinCodeNumber) else {
            return false
        }
        
        let balanceAmount = Double(balance)
        let card = Card(merchant: merchant, cardNumber: cardNumber, pinCode: pinCodeNumber, dateAdded: Date(), balance: balanceAmount)
        UserDefaultsManager.shared.save(card: card)
        
        return true
    }
    
}

class UserDefaultsManager {
    
    static let _shared = UserDefaultsManager()
    
    static var shared: UserDefaultsManager {
        return _shared
    }
    
    enum Keys: String {
        case LocalSavedCards
    }
    
    func save(card: Card) {
        
        var existingCards = [Card]()
        do {
            let allCards = try UserDefaults.standard.getObject(forKey: Keys.LocalSavedCards.rawValue, castTo: Cards.self)
            existingCards = allCards.cards
        } catch {
            
        }
        
        existingCards.append(card)
        
        do {
            let cards = Cards(cards: existingCards)
            try UserDefaults.standard.setObject(cards, forKey: Keys.LocalSavedCards.rawValue)
        } catch {
            
        }
    }
    
    func retrieveSavedCards() -> [Card]? {
        do {
            let cardsObj = try UserDefaults.standard.getObject(forKey: Keys.LocalSavedCards.rawValue, castTo: Cards.self)
            return cardsObj.cards
        } catch {
            return nil
        }
    }
    
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

struct Cards: Codable {
    let cards: [Card]
}

struct Card: Codable, Hashable {
    let merchant: String
    let cardNumber: Int
    let pinCode: Int
    let dateAdded: Date
    let balance: Double?
    
    var securedCardNumber: String {
        let cardStr = String(cardNumber)
        return String(cardStr.suffix(4))
    }
    
    var unsecuredCardNumber: String {
        let number = String(cardNumber).separate(every: 4, with: " ")
        return number
    }
    
    var presentableBalance: String {
        guard let balance = balance else {
            return ""
        }
        
        return String(format: "%.2f", balance)
    }
    
    var qrCodeImage: Image? {
        guard let convertableImage = QRCode(String(cardNumber))?.image else {
            return nil
        }
        return Image(uiImage: convertableImage)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(cardNumber)
    }
}

extension String {
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}
