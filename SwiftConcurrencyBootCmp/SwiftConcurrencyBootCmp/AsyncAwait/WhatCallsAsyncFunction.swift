//
//  WhatCallsAsyncFunction.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 05/03/2024.
//

import SwiftUI

struct WhatCallsAsyncFunction: View {
    @State private var site = "https://"
    @State private var sourceCode = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Website address", text: $site)
                    .textFieldStyle(.roundedBorder)
                Button("Go") {
                    Task {
                        await fetchSource()
                    }
                }
            }
            .padding()
            
            ScrollView {
                Text(site)
                Text(sourceCode)
            }
        }
    }
    
    func fetchSource() async {
        do {
            let url = URL(string: site)!
            let (data, _) = try await URLSession.shared.data(from: url)
            sourceCode = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            print(sourceCode)
        } catch {
            sourceCode = "Failed to fetch \(site)"
        }
    }
}

#Preview {
    WhatCallsAsyncFunction()
}
