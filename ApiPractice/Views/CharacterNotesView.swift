//
//  CharacterNotesView.swift
//  ApiPractice
//
//  Created by Andrew Hershey on 10/25/25.
//

import SwiftUI

struct CharacterNotesView: View {
    let characterId: Int
    @State private var note: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Notes")
                .font(.headline)
            
            TextEditor(text: $note)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: note) { _, newValue in
                    CharacterNotes.save(newValue, for: characterId)
                }
        }
        .onAppear {
            note = CharacterNotes.load(for: characterId)
        }
    }
}
