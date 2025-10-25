//
//  CharacterDetailView.swift
//  ApiPractice
//
//  Created by Andrew Hershey on 10/25/25.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: RMCharacter

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
     
                AsyncImage(url: URL(string: character.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    default:
                        ProgressView()
                            .frame(height: 300)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack {
                        Label(character.status, systemImage: "heart.fill")
                            .foregroundStyle(statusColor(for: character.status))

                        Text("•")
                            .foregroundStyle(.secondary)

                        Text(character.species)
                    }
                    .font(.headline)

                    Divider()

                    CharacterNotesView(characterId: character.id)
                }
                .padding()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}
