//
//  CardDetailsView.swift
//  Gifty
//
//  Created by Joseph Francis on 3/23/21.
//

import Foundation
import SwiftUI

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
                
                if let img = card.pdf417CodeImg {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                        
                        img
                            .resizable()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                    }
                }
            }
        }
        .navigationBarTitle(card.merchant)
    }
    
}
