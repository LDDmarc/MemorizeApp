//
//  Cardify.swift
//  MemorizeApp
//
//  Created by Дарья Леонова on 26.06.2022.
//

import SwiftUI

struct Cardify: Animatable, ViewModifier {
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    /// in degrees
    private var rotation: Double
    
    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: Constants.cornerRadius)
            if rotation < 90 {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: Constants.borderWidth)
            } else {
                shape.fill()
            }
            content.opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (x: 0, y: 1, z: 0))
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let borderWidth: CGFloat = 3
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
