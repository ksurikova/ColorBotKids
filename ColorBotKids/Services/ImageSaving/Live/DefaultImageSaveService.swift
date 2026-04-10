//
//  DefaultImageSaveService.swift
//  ColorBotKids
//
//  Created by ksurikova on 13.11.2025.
//
import Photos
import UIKit

class DefaultImageSaveService: ImageSaveService {
    func saveImageToPhotoLibrary(_ image: UIImage) async throws {
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else if let error = error as NSError? {
                    // Manually defined constants
                    let PHPhotosErrorInvalid = -1
                    let PHPhotosErrorChangeNotAllowed = -101
                    let PHPhotosErrorOperationInterrupted = -104

                    switch error.code {
                    case PHPhotosErrorInvalid:
                        continuation.resume(throwing: ImageSaveServiceError.invalidImageToSave)
                    case PHPhotosErrorChangeNotAllowed:
                        continuation.resume(throwing: ImageSaveServiceError.noPermission)
                    case PHPhotosErrorOperationInterrupted:
                        continuation.resume(throwing: ImageSaveServiceError.savingIsInterrupted)
                    default:
                        continuation.resume(throwing: ImageSaveServiceError.unknownError)
                    }
                } else {
                    continuation.resume(throwing: ImageSaveServiceError.unknownError)
                }
            }
        }
    }
}
