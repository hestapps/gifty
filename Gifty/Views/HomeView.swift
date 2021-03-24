//
//  HomeView.swift
//  Gifty
//
//  Created by Joseph Francis on 3/2/21.
//

import SwiftUI

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
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("**** \(card.securedCardNumber)")
                                            .foregroundColor(.white)
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
                
                ZStack {
                    Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 60)
                    
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 26, height: 26)
                        
                        Text("Add Card")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    .onTapGesture {
                        isAddCardViewPresenting.toggle()
                    }
                    .sheet(isPresented: $isAddCardViewPresenting) {
                        AddCardView(isAddCardViewPresented: $isAddCardViewPresenting, refetchCards: homeViewModel.fetchCards)
                    }
                }
            }
            .navigationBarTitle("Wallet", displayMode: .inline)
        }
    }
}
