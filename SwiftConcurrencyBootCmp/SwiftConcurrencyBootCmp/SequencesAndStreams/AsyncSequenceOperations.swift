//
//  AsyncSequenceOperations.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 07/03/2024.
//

import SwiftUI

struct AsyncSequenceOperations: View {
    @State private var lines = [String]()
    
    var body: some View {
        List {
            ForEach(lines, id: \.self) { line in
                Text(line)
            }
        }
        .onAppear {
            Task {
                //try await shoutQuotes()
                //try await printQuotes()
                //try await printAnonymousQuotes()
                //try await printTopQuotesUppercased()
                try await printHighestNumber()
            }
        }
    }
    
    func shoutQuotes() async throws {
        let url = URL(string: "https://hws.dev/quotes.txt")!
        let uppercaseLines = url.lines.map(\.localizedUppercase)
        
        for try await line in uppercaseLines {
            lines.append(line)
        }
    }

    func printQuotes() async throws {
        let url = URL(string: "https://hws.dev/quotes.txt")!

        let quotes = url.lines.map { Quote.init(text: $0) }

        for try await quote in quotes {
            lines.append(quote.text)
        }
    }
    
    func printAnonymousQuotes() async throws {
        let url = URL(string: "https://hws.dev/quotes.txt")!
        let anonymousQuotes = url.lines.filter { $0.contains("Anonymous") }

        for try await line in anonymousQuotes {
            lines.append(line)
        }
    }
    
    func printTopQuotes() async throws {
        let url = URL(string: "https://hws.dev/quotes.txt")!
        let topQuotes = url.lines.prefix(5)

        for try await line in topQuotes {
            print(line)
        }
    }
    
    func printTopQuotesUppercased() async throws {
        let url = URL(string: "https://hws.dev/quotes.txt")!
        let topQuotes = url.lines
                            .filter { $0.contains("Anonymous") }
                            .prefix(5)
                            .map(\.localizedUppercase)
        
        for try await line in topQuotes {
            lines.append(line)
        }
    }
    
    func getQuotes() async -> some AsyncSequence {
        let url = URL(string: "https://hws.dev/quotes.txt")!
        let anonymousQuotes = url.lines.filter { $0.contains("Anonymous") }
        let topAnonymousQuotes = anonymousQuotes.prefix(5)
        let shoutingTopAnonymousQuotes = topAnonymousQuotes.map(\.localizedUppercase)
        return shoutingTopAnonymousQuotes
    }
    
    func checkQuotes() async throws {
        let url = URL(string: "https://hws.dev/quotes.txt")!
        let noShortQuotes = try await url.lines.allSatisfy { $0.count > 30 }
        print(noShortQuotes)
    }
    
    func printHighestNumber() async throws {
        let url = URL(string: "https://hws.dev/random-numbers.txt")!

        if let highest = try await url.lines.compactMap({ Int($0) }).max() {
            lines.append(highest.description)
        } else {
            print("No number was the highest.")
        }
    }
    
    func sumRandomNumbers() async throws {
        let url = URL(string: "https://hws.dev/random-numbers.txt")!
        let sum = try await url.lines.compactMap({Int($0)}).reduce(0, +)
        print("Sum of numbers: \(sum)")
    }
    
}

#Preview {
    AsyncSequenceOperations()
}

struct Quote {
    let text: String
}
