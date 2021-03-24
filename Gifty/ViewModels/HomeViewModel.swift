//
//  HomeViewModel.swift
//  Gifty
//
//  Created by Joseph Francis on 3/23/21.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published fileprivate(set) var cards: [Card] = [Card]()
    
    func fetchCards() {
        guard let cards = UserDefaultsManager.shared.retrieveSavedCards() else {
            return
        }
        
        self.cards = cards
    }
    
    init() {
        fetchCards()
    }
    
}
