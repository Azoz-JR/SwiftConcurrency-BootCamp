//
//  SwiftConcurrencyBootCmpApp.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 05/03/2024.
//

import SwiftUI

@main
struct SwiftConcurrencyBootCmpApp: App {
    
//    static func main() async throws {
//        Task {
//            try await LocalUser.$id.withValue("Piper") {
//                print("Start of task: \(LocalUser.id)")
//                try await Task.sleep(nanoseconds: 1_000_000)
//                print("End of task: \(LocalUser.id)")
//            }
//        }
//        
//        Task {
//            try await LocalUser.$id.withValue("Alex") {
//                print("Start of task: \(LocalUser.id)")
//                try await Task.sleep(nanoseconds: 1_000_000)
//                print("End of task: \(LocalUser.id)")
//            }
//        }
//        
//        print("Outside of tasks: \(LocalUser.id)")
//    }
    
    // Returns data from a URL, writing log messages along the way.
    static func fetch(url urlString: String) async throws -> String? {
        Logger.shared.write("Preparing request: \(urlString)", level: .debug)

        if let url = URL(string: urlString) {
            let (data, _) = try await URLSession.shared.data(from: url)
            Logger.shared.write("Received \(data.count) bytes", level: .info)
            return String(decoding: data, as: UTF8.self)
        } else {
            Logger.shared.write("URL \(urlString) is invalid", level: .error)
            return nil
        }
    }
    
    static func main() async throws {
        Task {
            try await Logger.$logLevel.withValue(.debug) {
                try await fetch(url: "https://hws.dev/news-1.json")
            }
        }
        
        Task {
            try await Logger.$logLevel.withValue(.error) {
                try await fetch(url: "https:\\hws.dev/news-1.json")
            }
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            TaskLocalValues()
        }
    }
}
