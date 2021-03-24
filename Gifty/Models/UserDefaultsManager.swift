//
//  UserDefaultsManager.swift
//  Gifty
//
//  Created by Joseph Francis on 3/23/21.
//

import Foundation

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
