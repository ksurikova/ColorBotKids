//
//  MockStateStorage.swift
//  ColorBotKids
//
//  Created by ksurikova on 5.12.2025.
//
import Foundation

class MockStateStorage: StateStorage {
    private var currentStateURL: URL?

    func setCurrentStateURL(_ url: URL?) {
        currentStateURL = url
    }

    func getCurrentStateURL() -> URL? {
        currentStateURL
    }

    func clearStateMetadata() {
        currentStateURL = nil
    }
}

extension MockStateStorage {
    static var empty: MockStateStorage {
        MockStateStorage()
    }

    static var withSavedState: MockStateStorage {
        let mock = MockStateStorage()
        mock.setCurrentStateURL(URL(fileURLWithPath: "/tmp/preview-state"))
        return mock
    }
}
