//
//  TaskYield.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 08/03/2024.
//

import SwiftUI

struct TaskYield: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    func factors(for number: Int) async -> [Int] {
        var result = [Int]()
        
        for check in 1...number {
            if check.isMultiple(of: 100_000) {
                await Task.yield()
            }
            
            if number.isMultiple(of: check) {
                result.append(check)
            }
        }
        
        return result
    }
    
    func factors2(for number: Int) async -> [Int] {
        var result = [Int]()
        
        for check in 1...number {
            if number.isMultiple(of: check) {
                result.append(check)
                
                // That offers Swift the chance to pause every time a multiple is found. Calling yield() does not always mean the task will stop running: if it has a higher priority than other tasks that are waiting, it’s entirely possible your task will just immediately resume its work.
                await Task.yield()
            }
        }
        
        return result
    }
    
}

#Preview {
    TaskYield()
}
