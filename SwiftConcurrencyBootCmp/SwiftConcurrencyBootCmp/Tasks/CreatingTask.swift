//
//  CreatingTask.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 07/03/2024.
//

import SwiftUI

struct CreatingTask: View {
    
    @State var news = [NewsItem]()
    @State var highScore = [HighScore]()
    
    @State private var messages = [Message]()
    
    var body: some View {
        VStack {
            Text("NEWS: \(news.count) items")
            Text("High Score: \(highScore.first?.name ?? "") - \(highScore.first?.score ?? 0)")
        }
        .task {
            await fetchUpdates()
        }
    }
    
    func fetchUpdates() async {
        let newsTask = Task { () -> [NewsItem] in
            let url = URL(string: "https://hws.dev/headlines.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([NewsItem].self, from: data)
        }
        
        let highScoreTask = Task { () -> [HighScore] in
            let url = URL(string: "https://hws.dev/scores.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([HighScore].self, from: data)
        }
        
        do {
            let news = try await newsTask.value
            self.news = news
            
            let highScores = try await highScoreTask.value
            self.highScore = highScores
            
        } catch {
            print("There was an error loading user data.")
        }
        
    }
    
}

#Preview {
    FireAndForgetView()
}


struct NewsItem: Decodable {
    let id: Int
    let title: String
    let url: URL
}

struct HighScore: Decodable {
    let name: String
    let score: Int
}

struct Message3: Decodable, Identifiable {
    let id: Int
    let from: String
    let text: String
}


struct FireAndForgetView: View {
    @State private var messages = [Message3]()

    var body: some View {
        NavigationView {
            Group {
                if messages.isEmpty {
                    ScrollView {
                        Button("Load Messages") {
                            Task {
                                await loadMessages()
                            }
                        }
                        .padding(.top, 300)
                    }
                } else {
                    List(messages) { message in
                        VStack(alignment: .leading) {
                            Text(message.from)
                                .font(.headline)

                            Text(message.text)
                        }
                    }
                }
            }
            .navigationTitle("Inbox")
            .refreshable {
                messages = []
            }
        }
    }

    func loadMessages() async {
        do {
            let url = URL(string: "https://hws.dev/messages.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            messages = try JSONDecoder().decode([Message3].self, from: data)
        } catch {
            messages = [
                Message3(id: 0, from: "Failed to load inbox.", text: "Please try again later.")
            ]
        }
    }
}
