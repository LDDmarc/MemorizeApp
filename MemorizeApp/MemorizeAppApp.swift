//
//  MemorizeAppApp.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 07.06.2022.
//

import SwiftUI

@main
struct MemorizeAppApp: App {
    private let game = EmojiMemoryGame()
    var body: some Scene {
        WindowGroup {
            GameView(game: game, color: .pink)
        }
    }
}
