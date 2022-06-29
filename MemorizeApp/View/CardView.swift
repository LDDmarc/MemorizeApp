//
//  CardView.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 29.06.2022.
//

import SwiftUI

struct CardView<Game: MemoryGameInterface>: View {
    let card: Game.Card
    
    @State private var animatedBonusRemaning: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                pie
                Text(card.content)
                    .font(.system(size: Constants.fontSize(thatFits: geometry.size)))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private var pie: some View {
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
    }
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView()
//    }
//}

fileprivate enum Constants {
    static let fontSize: CGFloat = 72
    static let fontScale: CGFloat = 0.65
    static let circlePadding: CGFloat = 5
    static let circleOpacity: CGFloat = 0.5
    
    static let color: Color = .red
    
    static func fontSize(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) * Constants.fontScale
    }
}
