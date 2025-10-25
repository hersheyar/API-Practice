//
//  APIClient.swift
//  ApiPractice
//
//  Created by Andrew Hershey on 10/23/25.
//

import Foundation


struct APIClient {
    let baseURL = URL(string: "https://rickandmortyapi.com/api/")!
    
    func get(_ path: String, query: [URLQueryItem]? = nil) async throws -> Data {
        var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comps.queryItems = query
        let url = comps.url!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
            
        }
        return data
    }
    
    func fetchCharacters(page: Int?, name:String?) async throws -> CharactersResponse {
        var items: [URLQueryItem] = []
        if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
        if let name = name, !name.isEmpty { items.append(URLQueryItem(name: "name", value: name)) }
        
        let data = try await get("character", query: items.isEmpty ? nil : items)
        let dec = JSONDecoder()
        return try dec.decode(CharactersResponse.self, from: data)
    }
    
    func fetchEpisode(page: Int?, name:String?) async throws -> EpisodeResponse {
        var items: [URLQueryItem] = []
        if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
        if let name = name, !name.isEmpty { items.append(URLQueryItem(name: "name", value: name)) }
        
        let data = try await get("episode", query: items.isEmpty ? nil : items)
        let dec = JSONDecoder()
        return try dec.decode(EpisodeResponse.self, from: data)
        
    }
    
    func fetchLocation(page: Int?, name: String?) async throws -> LocationResponce {
        var items: [URLQueryItem] = []
        if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
        if let name = name, !name.isEmpty { items.append(URLQueryItem(name: "name", value: name)) }
        
        let data = try await get("location", query: items.isEmpty ? nil : items)
        let dec = JSONDecoder()
        return try dec.decode(LocationResponce.self, from: data)
    }
}
