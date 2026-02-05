//
//  ContentView.swift
//  WordScramble
//
//  Created by Michael Gillbanks on 22/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords: [String] = []
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    @State private var score: Int = 0
    
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingErrorAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section ("The word to scramble is") {
                    Text(rootWord)
                        .font(Font.largeTitle.bold())
                }
                
                Section {
                    TextField ("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle("Word Scramble")
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text (errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("New Game") { startGame() }
                            .padding()

                        Spacer()
                        Text("Score: \(score)")
                            .padding()

                    }
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOrigianl(word: answer) else {
            wordError(title: "Word already used", message: "Come up with something else!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cannot create that word from \(rootWord).")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "That word is not a real word.")
            return
        }
        
        guard isLargeEnough(word: answer) else {
            wordError(title: "Word is too short", message: "That was hopeless do better.")
            return
        }
        
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .ascii) { // This may break it (.ascii encoded)
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOrigianl(word: String) -> Bool {
        return !usedWords.contains(word) || word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
        
    func isLargeEnough(word: String) -> Bool {
        return word.count > 2
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingErrorAlert = true
    }
}


#Preview {
    ContentView()
}
