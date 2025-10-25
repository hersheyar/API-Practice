//
//  EpisodeListView.swift
//  ApiPractice
//
//  Created by Andrew Hershey on 10/25/25.
//

import SwiftUI

struct EpisodeListView: View {
    @StateObject private var vm = EpisodeVM()
    
    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .idle:
                    Color.clear.onAppear {
                        Task { await vm.firstLoad() }
                    }
                case .loading:
                    ProgressView("Loading episodes...")
                case .loaded:
                    episodesList
                case .failed(let error):
                    errorView(error)
                }
            }
            .navigationTitle("Episodes")
            .searchable(text: $vm.searchText, prompt: "Search episodes")
            .onChange(of: vm.searchText) { oldValue, newValue in
                Task { await vm.applySearch() }
            }
        }
    }

    private var episodesList: some View {
        VStack(spacing: 0) {
            List(vm.episodes) { episode in
                VStack(alignment: .leading, spacing: 4) {
                    Text(episode.name)
                        .font(.headline)
                    Text("\(episode.episode) • \(episode.air_date)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .refreshable {
                await vm.load(page: 1, name: vm.searchText.isEmpty ? nil : vm.searchText)
            }
            paginationControls
        }
    }

    private var paginationControls: some View {
        HStack(spacing: 20) {
            Button(action: { Task { await vm.prevPage() } }) {
                Label("Previous", systemImage: "chevron.left")
            }
            .disabled(vm.info?.prev == nil || vm.state == .loading)
            
            if let info = vm.info {
                Text("Page \(getCurrentPage(info: info)) of \(info.pages)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: { Task { await vm.nextPage() } }) {
                Label("Next", systemImage: "chevron.right")
            }
            .disabled(vm.info?.next == nil || vm.state == .loading)
        }
        .padding()
        .background(Color(.systemBackground))
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
}

#Preview {
    EpisodeListView()
}
