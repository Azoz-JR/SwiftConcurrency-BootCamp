//
//  StoreContinuations.swift
//  SwiftConcurrencyBootCmp
//
//  Created by Azoz Salah on 06/03/2024.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

struct StoreContinuations: View {
    
    @StateObject private var locationManager = LocationManager()
    @State var location = "N/A"
    var body: some View {
        VStack {
            Text(location)
            
            LocationButton {
                Task {
                    if let location = try? await locationManager.requestLocation() {
                        self.location = "Location: \(location)"
                    } else {
                        location = "Unknown Location"
                    }
                }
            }
            .frame(height: 44)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    StoreContinuations()
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations.first?.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
    }
    
    func requestLocation() async throws -> CLLocationCoordinate2D? {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
}
