//
//  DetachedTasks.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 07/03/2024.
//

import SwiftUI

class ViewModel: ObservableObject {
    @Published var name = "Hello"
}

struct DetachedTasks: View {
    @State private var name = "Anonymous"
    
    @StateObject private var model = ViewModel()
    
    var body: some View {
        VStack {
            Text("Hello, \(name)!")
            Button("Authenticate") {
                Task {
                    //name = "Taylor"
                    model.name = "Taylor"
                }
            }
        }
    }
}

#Preview {
    DetachedTasks()
}


actor UserActor {
    func login() {
        Task {
            if authenticate(user: "taytay89", password: "n3wy0rk") {
                print("Successfully logged in.")
            } else {
                print("Sorry, something went wrong.")
            }
        }
    }
    
    func detached() {
        Task.detached {
            if await self.authenticate(user: "taytay89", password: "n3wy0rk") {
                print("Successfully logged in.")
            } else {
                print("Sorry, something went wrong.")
            }
        }
    }

    func authenticate(user: String, password: String) -> Bool {
        // Complicated logic here
        return true
    }
}


struct DetachedTasksUsage: View {
    @StateObject private var model = ViewModel()

    var body: some View {
        Button("Authenticate", action: doWork)
    }

    func doWork() {
        Task.detached {
            for i in 1...10_000 {
                print("In Task 1: \(i)")
            }
        }

        Task.detached {
            for i in 1...10_000 {
                print("In Task 2: \(i)")
            }
        }
    }
}
