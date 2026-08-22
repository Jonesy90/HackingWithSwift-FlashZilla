//
//  CardView.swift
//  HackingWithSwift-FlashZilla
//
//  Created by Michael Jones on 15/08/2026.
//

import SwiftUI

struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    
    let card: Card
    /// Defines a Optional Closure Property.
    /// This is a common technique in SwiftUI to allow parent views to inject custom behaviour into child views.
    var removal: (() -> Void)? = nil
    
    @State private var isShowingAnswer: Bool = false
    
    /// Represents how far the card has been dragged horizontally by the user (positive = right, negative = left).
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    accessibilityDifferentiateWithoutColor ?
                        .white
                    : .white
                        .opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    accessibilityDifferentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25)
                        .fill(offset.width > 0 ? .green : .red)
                )
                .shadow(radius: 10)
            
            VStack {
                Text(card.prompt)
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                
                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        
        /// Creates a natural and interactive effect where the card visually tilts as the user drags it left or right.
        .rotationEffect(.degrees(offset.width / 5.0))
        
        /// Moves the card left or right  (x axis) by a specific number of points.
        .offset(x: offset.width * 5)
        
        /// Adjusts the transparency of the CardView based on how far it has been dragged horizontally.
        .opacity(1 - Double(abs(offset.width / 50)))
        
        /// Attaches a drag gesture to the CardView, enabling interactive dragging of the card.
        .gesture(
            /// As the user drags the card, this closure is called repeatedly with the latest drag gesture data.
            DragGesture()
                .onChanged { gesture in
                    /// This represents how far the user has moved from the drag gestures's starting point.
                    offset = gesture.translation
                }
                /// This closure is called once the user ends the drag (remove their finger from the screen).
                .onEnded { _ in
                    /// If the drag is more than 100 points on either side, it calls a closure to remove the card from the stack. Otherwise, return the card back to its starting position.
                    if abs(offset.width) > 100 {
                        removal?()
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
}

#Preview {
    CardView(card: Card.example)
}
