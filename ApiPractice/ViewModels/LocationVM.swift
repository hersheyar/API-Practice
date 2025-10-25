//
//  LocationVM.swift
//  ApiPractice
//
//  Created by Andrew Hershey on 10/25/25.
//

import Foundation
import SwiftUI

@MainActor
final class LocationVM: ObservableObject {
    @Published var locations: [RMLocation] = []
    @Published var info: Info? = nil
    @Published var state: LoadState = .idle
    @Published var searchText: String = ""
    
    private let api = APIClient()
    private var currentPage: Int = 1
    
    func firstLoad() async { await load(page: 1, name: nil) }
    
    func applySearch() async {
        currentPage = 1
        await load(page: currentPage, name: searchText.isEmpty ? nil : searchText)
    }
    
    func nextPage() async {
        guard let i = info, i.next != nil else { return }
        currentPage += 1
        await load(page: currentPage, name: searchText.isEmpty ? nil : searchText)
    }
    
    func prevPage() async {
        guard let i = info, i.prev != nil else { return }
        currentPage = max(1, currentPage - 1)
        await load(page: currentPage, name: searchText.isEmpty ? nil : searchText)
    }
    
    func load(page: Int?, name: String?) async {
        state = .loading
        do {
            let resp = try await api.fetchLocation(page: page, name: name)
            locations = resp.results
            info = resp.info
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
