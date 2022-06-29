//
//  EmojiMemoryGameView.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 07.06.2022.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var game: EmojiMemoryGame
    
    @Namespace private var dealingNamespace
    
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
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * Constants.totalDealDuration / Double(game.cards.count)
        }
        return .easeOut(duration: Constants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: Constants.aspectRatio) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView(card: card)
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
        .foregroundColor(Constants.color)
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: Constants.undealtWidth, height: Constants.undealtHeight)
        .foregroundColor(Constants.color)
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
}

struct CardView: View {
    let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaning: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: -90), endAngle: Angle(degrees: (1 - animatedBonusRemaning) * 360 - 90))
                            .onAppear {
                                animatedBonusRemaning = card.bonusRemaning
                                withAnimation(.linear(duration: card.bonusTimeRemaning)) {
                                    animatedBonusRemaning = 0
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: -90), endAngle: Angle(degrees: (1 - card.bonusRemaning) * 360 - 90))
                    }
                }
                    .padding(Constants.circlePadding)
                    .opacity(Constants.circleOpacity)
                Text(card.content)
                    .font(.system(size: Constants.fontSize(thatFits: geometry.size)))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(game.cards.first!)
        return EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
    }
}

fileprivate enum Constants {
    static let aspectRatio: CGFloat = 2/3
    static let fontSize: CGFloat = 72
    static let fontScale: CGFloat = 0.65
    static let circlePadding: CGFloat = 5
    static let circleOpacity: CGFloat = 0.5
    
    static let undealtHeight: CGFloat = 90
    static let undealtWidth = undealtHeight * aspectRatio
    
    static let color: Color = .red
    
    static let dealDuration: Double = 0.5
    static let totalDealDuration: Double = 2
    
    static func fontSize(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) * Constants.fontScale
    }
    
    static func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (Constants.fontSize / Constants.fontScale)
    }
}
