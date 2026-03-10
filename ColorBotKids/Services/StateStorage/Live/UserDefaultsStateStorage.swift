//
//  UserDefaultsStateStorage.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import Foundation

class UserDefaultsStateStorage: StateStorage {
    private let defaults = UserDefaults.standard
    private let key = "current_drawing_session_url"

    func setCurrentStateURL(_ url: URL?) {
        defaults.set(url?.absoluteString, forKey: AppConstants.stateURLKey)
    }

    func getCurrentStateURL() -> URL? {
        guard let urlString = defaults.string(forKey: AppConstants.stateURLKey) else { return nil }
        return URL(string: urlString)
    }
}
