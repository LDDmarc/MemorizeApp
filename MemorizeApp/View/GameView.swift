//
//  GameView.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 29.06.2022.
//

import SwiftUI

struct GameView<Game: MemoryGameInterface>: View {
    @ObservedObject var game: Game
    
    @Namespace private var dealingNamespace
    
    @State private var dealt = Set<Game.Card.ID>()
    
    let color: Color
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                gameBody
                
                HStack {
                    shuffle
                    Spacer()
                    restart
                }
                .padding()
            }
            deckBody
        }
        .padding()
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: Constants.aspectRatio) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView<Game>(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(color)
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView<Game>(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: Constants.undealtWidth, height: Constants.undealtHeight)
        .foregroundColor(color)
        .onTapGesture {
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var shuffle: some View {
        Button("Shuffle") {
            withAnimation {
                game.shuffle()
            }
        }
    }
    
    var restart: some View {
        Button("Restart") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    private func deal(_ card: Game.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: Game.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: Game.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0 == card }) {
            delay = Double(index) * Constants.totalDealDuration / Double(game.cards.count)
        }
        return .easeOut(duration: Constants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: Game.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0 == card }) ?? 0)
    }
}

//
//struct GameView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameView()
//    }
//}

fileprivate enum Constants {
    static let aspectRatio: CGFloat = 2/3
    static let fontSize: CGFloat = 72
    static let fontScale: CGFloat = 0.65
    static let circlePadding: CGFloat = 5
    static let circleOpacity: CGFloat = 0.5
    
    static let undealtHeight: CGFloat = 110
    static let undealtWidth = undealtHeight * aspectRatio
    
    static let dealDuration: Double = 0.5
    static let totalDealDuration: Double = 2
    
    static func fontSize(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) * Constants.fontScale
    }
}
