//
//  ContentView.swift
//  Flashzilla
//
//  Created by Michael Gillbanks on 01/03/2026.
//

import SwiftData
import SwiftUI
internal import Combine

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 20)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @Environment(\.modelContext) var modelContext
    
    @Query var cards: [Card]
    @State private var displayCards = [Card]()
    @State private var showingEditScreen = false
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                ZStack {
                    ForEach(displayCards) { card in
                        if let index = displayCards.firstIndex(where: { $0.id == card.id }) {
                            CardView(card: card) { correct in
                                withAnimation {
                                    removeCard(card: card, correct: correct)
                                }
                            }
                            .stacked(at: index, in: displayCards.count)
                            .allowsHitTesting(index == displayCards.count - 1)
                            .accessibilityHidden(index < displayCards.count - 1)
                        }
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if displayCards.isEmpty {
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
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    }
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding(35)
            
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            withAnimation {
                                if let last = displayCards.last {
                                    removeCard(card: last, correct: false)
                                }
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
                                if let last = displayCards.last {
                                    removeCard(card: last, correct: false)
                                }
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
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) { EditCards(modelContext: modelContext, cards: cards) }
        .onAppear(perform: resetCards)
    }
        
    func removeCard(card: Card, correct: Bool) {
        guard let index = displayCards.firstIndex(where: { $0.id == card.id }) else { return }
        
        let removed = displayCards.remove(at: index)
        
        if displayCards.isEmpty {
            isActive = false
        }
        
        if !correct {
            displayCards.insert(removed, at: 0)
        }
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        displayCards = cards
    }
}

#Preview {
    ContentView()
}
