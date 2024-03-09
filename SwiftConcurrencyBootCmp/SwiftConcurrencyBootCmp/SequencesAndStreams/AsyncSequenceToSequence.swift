//
//  AsyncSequenceToSequence.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 07/03/2024.
//

import SwiftUI

struct AsyncSequenceToSequence: View {
    
    @State private var numbers = [String]()
    
    var body: some View {
        List {
            ForEach(numbers, id: \.self) { num in
                Text(num)
            }
        }
        .task {
            if let numbers = try? await getNumberArray() {
                for number in numbers {
                    self.numbers.append("Num: \(number)")
                }
            }
        }
    }
    
    func getNumberArray() async throws -> [Int] {
        let url = URL(string: "https://hws.dev/random-numbers.txt")!
        let numbers = url.lines.compactMap({ Int($0) })
        return try await numbers.collect()
    }
    
}

#Preview {
    AsyncSequenceToSequence()
}


extension AsyncSequence {
    func collect() async rethrows -> [Element] {
        try await self.reduce(into: [Element]()) { partialResult, next in
            partialResult.append(next)
        }
    }
}


