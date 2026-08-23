//
//  ContentView.swift
//  HackingWithSwift-FlashZilla
//
//  Created by Michael Jones on 15/08/2026.
//

import Combine
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
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @Environment(\.scenePhase) var scenePhase
    
    @State private var isActive = true
    @State private var showingEditScreen = false
    
    /// Creates an Array of Card that repeats on the example constant 10 times.
//    @State private var cards = Array<Card>.init(repeating: .example, count: 10)
    @State private var cards = [Card]()
    
    ///Used to track the countdown timer for the user and is displayed as Text.
    @State private var timeRemaining = 100
    /// Creates a repeating time that sends out an event every 1 second. It is later used in '.onReceive' modifier to decrement 'timeRemaining'.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                Text("Time Remaining: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                ZStack {
                    ForEach(Array(cards.enumerated()), id: \.element) { item in
                        CardView(card: item.element) { reinsert in
                            withAnimation {
                                removeCard(at: item.offset, reinsert: reinsert)
                            }
                        }
                        .stacked(at: item.offset, in: cards.count)
                        // Only allows the top card of the deck to be swiped.
                        .allowsHitTesting(item.offset == cards.count - 1)
                        // Only applies accessibility assistance to the top card on the deck.
                        .accessibilityHidden(item.offset < cards.count - 1)
                    }
                }
                /// Enables or disables user interactions for the view it's applied to (and all of its child views).
                /// If 'timeRemaining' drops to zero, all the user interactions will be disabled for this part of the UI.
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.75))
                            .clipShape(.circle)
                    }
                }
                
                Spacer()
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
            
            /// Helps users who have difficulty distinguishing colours by providing alternative options.
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1, reinsert: true)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect.")
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1, reinsert: false)
                            }
                        } label: {
                            
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct.")
                    }
                    .foregroundStyle(.white)
                    .font(.title)
                    .padding()
                }
            }
        }
        /// SwiftUI view modifier that allows the view to respond whenever the timer publisher emits a value.
        .onReceive(timer) { time in
            /// Makes sure the code inside the closure only runs if the 'isActive' state property is true.
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        /// If the 'scenePhase' changes state, which returns the current state of the apps scene (e.g., Active or Inactive).
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards()
        }
        .onAppear(perform: resetCards)
    }
    
    /// Removes a card from the array (of cards) at a specific position.
    func removeCard(at index: Int, reinsert: Bool) {
        guard index >= 0 else { return }
        
        if reinsert {
            cards.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
        } else {
            cards.remove(at: index)
        }
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    /// This function is responsible for restarting the game.
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
}

#Preview {
    ContentView()
}
