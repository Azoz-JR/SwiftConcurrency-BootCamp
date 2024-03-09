//
//  CreatingAsyncSequence.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 07/03/2024.
//

import SwiftUI

struct CreatingAsyncSequence: View {
    
    @State private var current = ""
    @State private var users = [User2]()
    
    var body: some View {
        List(users) { user in
            Text(user.name)
        }
        .task {
            //await double()
            
            // continuously check the URL watcher for data
            await fetchUsers()
        }
    }
    
    func double() async {
        let sequence = DoubleGenerator()

        for await number in sequence {
            print(number)
        }
    }
    
    func fetchUsers() async {
        let url = Bundle.main.url(forResource: "users", withExtension: "json")!
        
        
        let urlWatcher = URLWatcher(url: url, delay: 3)
        
        do {
            for try await data in urlWatcher {
                try withAnimation {
                    users = try JSONDecoder().decode([User2].self, from: data)
                }
            }
        } catch {
            // just bail out
        }
    }
    
}

#Preview {
    CreatingAsyncSequence()
}


struct DoubleGenerator: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Int
    var current = 1
    
    mutating func next() async -> Element? {
        defer {
            current &*= 2
        }
        
        if current < 0 {
            return nil
        } else {
            return current
        }
    }
    
    func makeAsyncIterator() -> DoubleGenerator {
        self
    }
}

// Separate Iterator
//struct DoubleGenerator: AsyncSequence {
//    typealias Element = Int
//
//    struct AsyncIterator: AsyncIteratorProtocol {
//        var current = 1
//
//        mutating func next() async -> Element? {
//            defer { current &*= 2 }
//
//            if current < 0 {
//                return nil
//            } else {
//                return current
//            }
//        }
//    }
//
//    func makeAsyncIterator() -> AsyncIterator {
//        AsyncIterator()
//    }
//}


struct URLWatcher: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Data

    let url: URL
    let delay: Int
    private var comparisonData: Data?
    private var isActive = true

    init(url: URL, delay: Int = 10) {
        self.url = url
        self.delay = delay
    }

    mutating func next() async throws -> Element? {
        // Once we're inactive always return nil immediately
        guard isActive else { return nil }

        if comparisonData == nil {
            // If this is our first iteration, return the initial value
            comparisonData = try await fetchData()
        } else {
            // Otherwise, sleep for a while and see if our data changed
            while true {
                try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                let latestData = try await fetchData()

                if latestData != comparisonData {
                    // New data is different from previous data,
                    // so update previous data and send it back
                    comparisonData = latestData
                    break
                }
            }
        }

        if comparisonData == nil {
            isActive = false
            return nil
        } else {
            return comparisonData
        }
    }

    private func fetchData() async throws -> Element {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    func makeAsyncIterator() -> URLWatcher {
        self
    }
}

struct User2: Identifiable, Decodable {
    let id: Int
    let name: String
}
