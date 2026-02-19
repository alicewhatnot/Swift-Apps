//
//  AddBookView.swift
//  Bookworm
//
//  Created by Michael Gillbanks on 18/02/2026.
//

import SwiftData
import SwiftUI

struct AddBookView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var genre = "Fantasy"
    @State private var review = ""
    @State private var rating = 3
    
    var validBook: Bool {
        var valid = true
        let bookProperties = [title, author]
        for index in 0..<2 {
            if bookProperties[index].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                valid = false
            }
        }
        
        return valid
    }
    
    let genres = ["Fantasy", "Horror", "Kids", "Mystery", "Poetry", "Romance", "Thriller"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name of book", text: $title)
                    TextField("Author's name", text: $author)
                    
                    Picker("Genre", selection: $genre) {
                        ForEach(genres, id: \.self) {
                            Text($0)
                        }
                    }

                }
                
                Section("Write a review") {
                    TextEditor(text: $review)
                    
                    HStack {
                        RatingView(rating: $rating)
                    }
                    .containerRelativeFrame(.horizontal)
                    
                    
                    
                }
                
                Section {
                    Button("Save") {
                        if review == "" {
                            review = "No Review"
                        }
                        let newBook = Book(title: title, author: author, genre: genre, review: review, rating: rating)
                        modelContext.insert(newBook)
                        dismiss()
                    }
                }
                .disabled(!validBook)
            }
            .navigationTitle("Add Book")
        }
    }
}

#Preview {
    AddBookView()
}
