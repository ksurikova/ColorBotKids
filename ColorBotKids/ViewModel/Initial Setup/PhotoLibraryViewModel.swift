//
//  PhotoLibraryViewModel.swift
//  ColorBotKids
//
//  Created by ksurikova on 3.03.2026.
//
import SwiftUI

@MainActor
final class PhotoLibraryViewModel: ObservableObject {
    @Published private(set) var status: PermissionStatus
    private let manager: PermissionManager

    init(manager: PermissionManager) {
        self.manager = manager
        status = manager.photoLibrary.value

        manager.photoLibrary
            .receive(on: DispatchQueue.main)
            .assign(to: &$status)
    }

    func request() async -> Bool {
        await manager.request(Permissions.photoLibrary)
    }
}
