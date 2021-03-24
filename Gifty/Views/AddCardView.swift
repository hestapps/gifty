//
//  AddCardView.swift
//  Gifty
//
//  Created by Joseph Francis on 3/23/21.
//

import Foundation
import SwiftUI

struct AddCardView: View {
    
    @State fileprivate var cardNumber = ""
    @State fileprivate var pinCodeNumber = ""
    @State fileprivate var merchant = ""
    @State fileprivate var balance = ""
    
    @State fileprivate var showErrorSavingCardAlert = false
    @Binding var isAddCardViewPresented: Bool
    var refetchCards: () -> ()
    
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
                    refetchCards()
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
