//
//  Enums.swift
//  MultiplicationTables
//
//  Created by Monty Harper on 1/13/24.
//

import Foundation
import SwiftUI

enum GameState {
    case preGame
    case gameOn
    case gameOver
}

extension Double {
    
    func oneDecimalString() -> String {
        
        String(format: "%.1f", self)

    }
}

struct Palette {
    
    static let shared = Palette()
    
    private init() {
    }
    
    let colors = [Color.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink]
    let complimentary = [Color.cyan, .blue, .indigo, .purple, .pink, .red, .orange, .yellow, .green, .mint, .teal]
}
