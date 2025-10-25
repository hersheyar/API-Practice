//
//  MainView.swift
//  ApiPractice
//
//  Created by Andrew Hershey on 10/25/25.
//

import SwiftUI

enum ResourceType: String, CaseIterable, Identifiable {
    case characters = "Characters"
    case episodes = "Episodes"
    case locations = "Locations"
    
    var id: String { rawValue }
}

struct MainView: View {
    @State private var selectedTab: ResourceType = .characters
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Resource", selection: $selectedTab) {
                    ForEach(ResourceType.allCases) { resource in
                        Text(resource.rawValue).tag(resource)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                Group {
                    switch selectedTab {
                    case .characters:
                        CharactersListView()
                    case .episodes:
                        EpisodeListView()
                    case .locations:
                        LocationListView()
                    }
                }
                .animation(.easeInOut, value: selectedTab)
                .transition(.opacity)
            }
            .navigationTitle("Rick & Morty API")
        }
    }
}

#Preview {
    MainView()
}
