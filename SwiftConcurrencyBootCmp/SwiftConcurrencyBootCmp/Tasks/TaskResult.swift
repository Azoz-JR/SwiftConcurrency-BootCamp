//
//  TaskResult.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 07/03/2024.
//

import SwiftUI

struct TaskResult: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                await fetchQuotes()
            }
    }
    
    func fetchQuotes() async {
        let downloadTask = Task { () -> String in
            let url = URL(string: "https://hws.dev/quotes.txt")!
            let data: Data
            
            do {
                (data, _) = try await URLSession.shared.data(from: url)
            } catch {
                throw LoadError.fetchFailed
            }
            
            if let string = String(data: data, encoding: .utf8) {
                return string
            } else {
                throw LoadError.decodeFailed
            }
        }
        
        let result = await downloadTask.result
        
        do {
            let string = try result.get()
            print(string)
        } catch LoadError.fetchFailed {
            print("Unable to fetch the quotes.")
        } catch LoadError.decodeFailed {
            print("Unable to convert quotes to text.")
        } catch {
            print("Unknown error.")
        }
    }
    
}

#Preview {
    TaskResult()
}


enum LoadError: Error {
    case fetchFailed, decodeFailed
}
