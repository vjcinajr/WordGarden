//
//  ContentView.swift
//  WordGarden
//
//  Created by VINCENT CINA on 2/25/25.
//

import SwiftUI

struct ContentView: View {
    private static let maximumGuesses: Int = 8 // Need to refer to this as Self.maximumGuesses
    
    @State private var wordsGuessed: Int = 0
    @State private var wordsMissed: Int = 0
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var currentWordIndexed = 0  // index in wordsToGuess
    @State private var wordToGuess: String = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = maximumGuesses
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden: Bool = true
    @State private var playAgainButtonLabel = "Another Word?"
    @FocusState private var textFieldIsFocused: Bool
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"]  // All caps
    
    var body: some View {
        VStack {
            HStack{
                VStack(alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                }
            }
            
            .padding(.horizontal)
            
            Spacer()
            
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            
            Text(revealedWord)
                .font(.title)
            
            if playAgainHidden {
                HStack{
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) {
                            guessedLetter = guessedLetter.trimmingCharacters(in:
                                    .letters.inverted)
                            guard let lastChar = guessedLetter.last else {
                                return
                            }
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .focused($textFieldIsFocused)
                        .onSubmit {
                            guard guessedLetter != "" else { return }
                            guessALetter()
                            updateGamePlay()
                        }
// see https://medium.com/better-programming/12-shades-of-keyboard-types-in-ios-a413cf93bf4f for .keyboardType doc
                    
                    Button("Guess a Letter:") {
                        guessALetter()
                        updateGamePlay()
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                Button(playAgainButtonLabel) {
                    // If all the words have been guessed…
                    if currentWordIndexed == wordsToGuess.count {
                        currentWordIndexed = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word"
                    }
                    // Reset after word was guessed or missed
                    wordToGuess = wordsToGuess[currentWordIndexed]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
                    lettersGuessed = ""
                    guessesRemaining = Self.maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
            
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: {
            wordToGuess = wordsToGuess[currentWordIndexed]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
        })
        .ignoresSafeArea(edges: .bottom)
    }
    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
        revealedWord = wordToGuess.map { letter in
            lettersGuessed.contains(letter) ? "\(letter)" : "_"
        }.joined(separator: " ")
        guessedLetter = ""
    }
    
    func updateGamePlay () {
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            imageName = "flower\(guessesRemaining)"
        }
        
        // When do we play another word?
        if !revealedWord.contains("_") {    // Guessed when no "_" in revealedWord
            gameStatusMessage = "You Guessed It! It Took You \(lettersGuessed.count) Guesses to Guess the Word."
            wordsGuessed += 1
            currentWordIndexed += 1
            playAgainHidden = false
        } else if guessesRemaining == 0 {
            gameStatusMessage = " So Sorry, You're out of Guesses"
            wordsMissed += 1
            currentWordIndexed += 1
            playAgainHidden = false
        } else { // Keep Guessing
            //TODO: Redo this with localizedStringKey & Inflect
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")"
        }
        if currentWordIndexed == wordToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've Tried All of the Words. Restart from the Beginning?"
        }
        guessedLetter = ""
    }
    
}

#Preview {
    ContentView()
}
