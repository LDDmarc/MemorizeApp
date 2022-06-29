//
//  MemoryGame.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 08.06.2022.
//

import Foundation

struct MemoryGame<CardContent: Equatable> {
    private(set) var cards: [Card]
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter { cards[$0].isFaceUp }.first }
        set { cards.indices.forEach { cards[$0].isFaceUp = ($0 == newValue) } }
    }
    
    init(numberOfPairsOfCard: Int, createCardContent: (Int) -> CardContent) {
        cards = []
        for pairIndex in 0..<numberOfPairsOfCard {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
//        cards.shuffle()
    }
    
    mutating func choose(_ card: Card) {
        if
            let choosenIndex = cards.firstIndex(where: {card.id == $0.id} ),
            !cards[choosenIndex].isFaceUp,
            !cards[choosenIndex].isMatched
        {
            if
                let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard,
                cards[choosenIndex].content == cards[potentialMatchIndex].content
            {
                cards[choosenIndex].isMatched = true
                cards[potentialMatchIndex].isMatched = true
                cards[choosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = choosenIndex
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
}

extension MemoryGame {
    struct Card: Identifiable {
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                if isMatched {
                    stopUsingBonusTime()
                }
            }
        }
        var content: CardContent
        var id: Int
        
        var bonusTimeLimit: TimeInterval = 6
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = lastFaceUpDate {
                return pastFaceUpTime + Date.now.timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        var lastFaceUpDate: Date?
        var pastFaceUpTime: TimeInterval = 0
        
        var bonusTimeRemaning: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        ///percentage
        var bonusRemaning: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaning > 0) ? bonusTimeRemaning / bonusTimeLimit : 0
        }
        
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaning > 0
        }
        
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaning > 0
        }
        
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = .now
            }
        }
        
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            lastFaceUpDate = nil
        }
    }
}
