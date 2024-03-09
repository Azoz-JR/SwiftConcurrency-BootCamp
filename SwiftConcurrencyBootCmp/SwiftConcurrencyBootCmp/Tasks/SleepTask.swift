//
//  SleepTask.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 08/03/2024.
//

import SwiftUI

struct SleepTask: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SleepTask()
}


extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duaration = UInt64(seconds * 1_000_000_000)
        try await self.sleep(nanoseconds: duaration)
    }
}
