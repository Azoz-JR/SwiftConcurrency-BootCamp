//
//  TasksCancellation.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 08/03/2024.
//

import SwiftUI

struct TasksCancellation: View {
    
    @State private var value: Double = 1
    
    var body: some View {
        Text("Value: \(value)")
            .task {
                await getAverageTemperature()
            }
    }
    
    func getAverageTemperature() async {
        let fetchTask = Task { () -> Double in
            let url = URL(string: "https://hws.dev/readings.json")!
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if Task.isCancelled { return 0 }
                
                let readings = try JSONDecoder().decode([Double].self, from: data)
                let sum = readings.reduce(0, +)
                return sum / Double(readings.count)
            } catch {
                return 0
            }
        }
        
        fetchTask.cancel()
        
        let result = await fetchTask.value
        value = result
        print("Average temperature: \(result)")
    }
    
    func getAverageTemperature_CheckCancellation() async {
        let fetchTask = Task { () -> Double in
            let url = URL(string: "https://hws.dev/readings.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Throws an error if the task is already cancelled.
            try Task.checkCancellation()
            
            let readings = try JSONDecoder().decode([Double].self, from: data)
            let sum = readings.reduce(0, +)
            return sum / Double(readings.count)
        }

        do {
            let result = try await fetchTask.value
            print("Average temperature: \(result)")
        } catch {
            print("Failed to get data.")
        }
    }
    
}

#Preview {
    TasksCancellation()
}
