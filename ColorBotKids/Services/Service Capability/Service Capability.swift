//
//  ServiceAvailability.swift
//  ColorBotKids
//
//  Created by ksurikova on 10.02.2026.
//
protocol CriticalServiceCapability {
    static func canRunApp() -> Bool
    static func unavailabilityMessage() -> String?
}
