//
//  DefaultTapStyle.swift
//  Gifty
//
//  Created by Joseph Francis on 3/23/21.
//

import Foundation
import SwiftUI

struct DefaultTapStyle: ButtonStyle {
    
    let backgroundColor: Color = .clear
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor)
    }
    
}
