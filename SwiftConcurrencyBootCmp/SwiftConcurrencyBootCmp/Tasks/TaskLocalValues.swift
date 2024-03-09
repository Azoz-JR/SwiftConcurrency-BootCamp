//
//  TaskLocalValues.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 09/03/2024.
//

import SwiftUI

struct TaskLocalValues: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    TaskLocalValues()
}


enum LocalUser {
    @TaskLocal static var id = "Anonymous"
}

enum LogLevel: Comparable {
    case debug, info, warn, error, fatal
}


struct Logger {
    // The log level for an individual task
    @TaskLocal static var logLevel = LogLevel.info

    // Make this struct a singleton
    private init() { }
    static let shared = Logger()

    // Print out a message only if it meets or exceeds our log level.
    func write(_ message: String, level: LogLevel) {
        if level >= Logger.logLevel {
            print(message)
        }
    }
}
