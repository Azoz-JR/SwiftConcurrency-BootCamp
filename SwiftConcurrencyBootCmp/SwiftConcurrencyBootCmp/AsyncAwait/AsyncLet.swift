//
//  AsyncLet.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 06/03/2024.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var user: User?
    @State private var messages: [Message2] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading) {
                        if let user {
                            Text(user.name)
                                .font(.headline)
                            Text("Age: \(user.age.description)")
                        } else {
                            ProgressView()
                        }
                        
                    }
                }
                
                Section {
                    ForEach(messages) { message in
                        VStack(alignment: .leading) {
                            Text(message.from)
                                .font(.headline)
                            
                            Text(message.message)
                        }
                    }
                }
            }
            .task {
                await loadData()
            }
        }
    }
    
    func loadData() async {
        async let (userData, _) = URLSession.shared.data(from: URL(string: "https://hws.dev/user-24601.json")!)

        async let (messageData, _) = URLSession.shared.data(from: URL(string: "https://hws.dev/user-messages.json")!)
        
        do {
            let decoder = JSONDecoder()
            let user = try await decoder.decode(User.self, from: userData)
            self.user = user
            
            let messages = try await decoder.decode([Message2].self, from: messageData)
            self.messages = messages
            
            print("User \(user.name) has \(messages.count) message(s).")
        } catch {
            print("Sorry, there was a network problem.")
        }
    }
    
    func fetchFavorites(for user: User) async -> [Int] {
        print("Fetching favorites for \(user.name)…")

        do {
            async let (favorites, _) = URLSession.shared.data(from: URL(string: "https://hws.dev/user-favorites.json")!)
            return try await JSONDecoder().decode([Int].self, from: favorites)
        } catch {
            return []
        }
    }
    
    func x() async {
        // user must be constant to because it's captured by async let, and it makes sure user will not change by surprise
        let user = User(id: UUID(), name: "Taylor Swift", age: 26)
        async let favorites = fetchFavorites(for: user)
        await print("Found \(favorites.count) favorites.")
    }
}

#Preview {
    AsyncLet()
}


struct User: Decodable {
    let id: UUID
    let name: String
    let age: Int
}

struct Message2: Decodable, Identifiable {
    let id: Int
    let from: String
    let message: String
}
