//
//  CharacterListView.swift
//  ApiPractice
//
//  Created by Andrew Hershey on 10/23/25.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject private var vm = CharacterVM()
    
    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .idle:
                    Color.clear
                        .onAppear {
                            Task { await vm.firstLoad() }
                        }
                    
                case .loading:
                    ProgressView("Loading characters...")
                    
                case .loaded:
                    charactersList
                    
                case .failed(let error):
                    errorView(error)
                }
            }
            .navigationTitle("Rick & Morty")
            .searchable(text: $vm.searchText, prompt: "Search characters")
            .onChange(of: vm.searchText) { oldValue, newValue in
                Task {
                    await vm.applySearch()
                }
            }
        }
    }

    private var charactersList: some View {
        VStack(spacing: 0) {
            List(vm.characters) { character in
                NavigationLink(value: character) {
                    CharacterRow(character: character)
                }
            }
            .navigationDestination(for: RMCharacter.self) { character in
                CharacterDetailView(character: character)
            }
            .refreshable {
                await vm.load(page: 1, name: vm.searchText.isEmpty ? nil : vm.searchText)
            }
            
            paginationControls
        }
    }

    private var paginationControls: some View {
        HStack(spacing: 20) {
            Button(action: {
                Task { await vm.prevPage() }
            }) {
                Label("Previous", systemImage: "chevron.left")
            }
            .disabled(vm.info?.prev == nil || vm.state == .loading)
            
            if let info = vm.info {
                Text("Page \(getCurrentPage(info: info)) of \(info.pages)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: {
                Task { await vm.nextPage() }
            }) {
                Label("Next", systemImage: "chevron.right")
            }
            .disabled(vm.info?.next == nil || vm.state == .loading)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task { await vm.firstLoad() }
            }) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    

    private func getCurrentPage(info: Info) -> Int {
        if let next = info.next, let url = URL(string: next),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let pageItem = components.queryItems?.first(where: { $0.name == "page" }),
           let pageStr = pageItem.value,
           let nextPage = Int(pageStr) {
            return nextPage - 1
        }
        if let prev = info.prev, let url = URL(string: prev),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let pageItem = components.queryItems?.first(where: { $0.name == "page" }),
           let pageStr = pageItem.value,
           let prevPage = Int(pageStr) {
            return prevPage + 1
        }
        return 1
    }
}


struct CharacterRow: View {
    let character: RMCharacter
    
    var body: some View {
        HStack(spacing: 12) {
            // Character Image
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "person.fill")
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(character.species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(character.status)
                        .font(.subheadline)
                        .foregroundStyle(statusColor(for: character.status))
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .gray
        }
    }
}

struct CharacterDetailView: View {
    let character: RMCharacter
    @State private var note: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Character Image
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Notes")
                            .font(.headline)
                        
                        TextEditor(text: $note)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: note) { _, newValue in
                                CharacterNotes.save(newValue, for: character.id)
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            note = CharacterNotes.load(for: character.id)
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    CharactersListView()
}
