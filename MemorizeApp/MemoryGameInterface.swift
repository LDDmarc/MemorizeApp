//
//  MemoryGameInterface.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 29.06.2022.
//

import SwiftUI

protocol MemoryGameInterface: ObservableObject {
    associatedtype Content: Equatable & StringProtocol
    typealias Model = MemoryGame<Content>
    typealias Card = Model.Card
    
    var cards: [Card] { get }
    
    func choose(_ card: Card)
    func shuffle()
    func restart()
}
