//
//  ContentView.swift
//  HackingWithSwift-FlashZilla
//
//  Created by Michael Jones on 15/08/2026.
//

import SwiftUI

/// Adds a new method to all SwiftUI views and calculates how far from the bottom this item is.
/// Creates a visual stacking effect in SwiftUI by vertically offsetting each view based on its position in a collection.
extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @State private var cards = Array<Card>.init(repeating: .example, count: 10)
    
    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            VStack {
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                    }
                }
            }
        }
    }
    
    /// Removes a card from the array (of cards) at a specific position.
    func removeCard(at index: Int) {
        cards.remove(at: index)
    }
}

#Preview {
    ContentView()
}
