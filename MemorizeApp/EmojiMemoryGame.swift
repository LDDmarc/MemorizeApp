//
//  EmojiMemoryGame.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 08.06.2022.
//

import SwiftUI

class EmojiMemoryGame: MemoryGameInterface {
    typealias Model = MemoryGame<String>
    typealias Card = Model.Card
    
    private static let emojis = ["🚎", "🛵", "🚁", "⛵️", "🚗", "🚌", "🚓", "🚛", "🏍", "🛺", "🚀", "🛶", "✈️", "🚂", "🚇", "🚢", "🚠", "🛰"]
    
    private static func createMemoryGame() -> Model {
        Model(numberOfPairsOfCard: emojis.count, createCardContent: { index in
            emojis[index]
        })
    }
    
    @Published private var model = createMemoryGame()
    
    var cards: [Card] {
        model.cards
    }
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func restart() {
        model = EmojiMemoryGame.createMemoryGame()
    }
}
