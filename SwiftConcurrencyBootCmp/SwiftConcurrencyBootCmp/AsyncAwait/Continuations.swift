//
//  Continuations.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 06/03/2024.
//

import SwiftUI

struct Continuations: View {
    
    @State private var messages: [Message2] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(messages) { message in
                    VStack(alignment: .leading) {
                        Text(message.from)
                            .font(.headline)
                        
                        Text(message.message)
                    }
                }
            }
            .task {
                messages = await fetchMessages()
            }
        }
    }
    
    func fetchMessages(completion: @escaping ([Message2]) -> Void) {
        let url = URL(string: "https://hws.dev/user-messages.json")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let messages = try? JSONDecoder().decode([Message2].self, from: data) {
                    completion(messages)
                    return
                }
            }

            completion([])
        }.resume()
    }
    
    func fetchMessages() async -> [Message2] {
        return await withCheckedContinuation { continuation in
            fetchMessages { messages in
                continuation.resume(returning: messages)
            }
        }
    }
    
    func fetchThrowingMessages() async throws -> [Message2] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchMessages { messages in
                if messages.isEmpty {
                    continuation.resume(throwing: FetchError.noMessages)
                } else {
                    continuation.resume(returning: messages)
                }
            }
        }
    }
    
}

#Preview {
    Continuations()
}


enum FetchError: Error {
    case noMessages
}
