//
//  CancelTaskGroup.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 08/03/2024.
//

import SwiftUI

struct CancelTaskGroup: View {
    
    @State var stories = [NewsStory]()
    
    var body: some View {
        //        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        //            .task {
        //                await printMessage()
        //            }
        
        NavigationStack {
            List(stories) { story in
                VStack(alignment: .leading) {
                    Text(story.title)
                        .font(.headline)
                    
                    Text(story.strap)
                }
            }
            .navigationTitle("Latest News")
        }
        .task {
            //await loadStories()
            await testCancellation()
        }
    }
    
    func printMessage() async {
        let result = await withThrowingTaskGroup(of: String.self) { group -> String in
            group.addTask {
                try Task.checkCancellation()
                return "Testing"
            }
            
            group.addTask {
                return "Group"
            }
            
            group.addTask {
                return "Cancellation"
            }
            
            group.cancelAll()
            var collected = [String]()
            
            do {
                for try await value in group {
                    collected.append(value)
                }
            } catch {
                print(error.localizedDescription)
            }
            
            return collected.joined(separator: " ")
        }
        
        print(result)
    }
    
    func loadStories() async {
        do {
            try await withThrowingTaskGroup(of: [NewsStory].self) { group -> Void in
                for i in 1...5 {
                    group.addTask {
                        let url = URL(string: "https://hws.dev/news-\(i).json")!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        try Task.checkCancellation()
                        return try JSONDecoder().decode([NewsStory].self, from: data)
                    }
                }
                
                for try await result in group {
                    if result.isEmpty {
                        group.cancelAll()
                    } else {
                        stories.append(contentsOf: result)
                    }
                }
                
                stories.sort { $0.id < $1.id }
            }
        } catch {
            print("Failed to load stories: \(error.localizedDescription)")
        }
    }
    
    func testCancellation() async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group -> Void in
                group.addTask {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    throw ExampleError.badURL
                }
                
                group.addTask {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    print("1- Task is cancelled: \(Task.isCancelled)")
                }
                
                // do nothing if called on a cancelled group.
                let isTaskCancelled = group.addTaskUnlessCancelled {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                }
                
                print("2- Task is cancelled: \(isTaskCancelled)")
                
                try await group.next()
            }
        } catch {
            print("Error thrown: \(error.localizedDescription)")
        }
    }
    
}

#Preview {
    CancelTaskGroup()
}


enum ExampleError: Error {
    case badURL
}
