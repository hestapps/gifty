//
//  Card.swift
//  Gifty
//
//  Created by Joseph Francis on 3/23/21.
//

import Foundation
import SwiftUI

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
    
    var pdf417CodeImg: Image? {
        guard let img = generatePDF417Barcode() else {
            return nil
        }
        
        return Image(uiImage: img)
    }
    
    private func generatePDF417Barcode() -> UIImage? {
        let ciContext = CIContext()
        let cardNumberStr = String(cardNumber)
        let data = cardNumberStr.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        let transformer = CGAffineTransform(scaleX: 3, y: 3)
        
        guard let ciImage = filter.outputImage?.transformed(by: transformer) else {
            return nil
        }
        
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(cardNumber)
    }
}
