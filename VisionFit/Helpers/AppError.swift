//
//  AppError.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//


import Foundation
import HTTPClient

enum AppError: Error {
    case emptySuccess
    case badRequest(ErrorResponseDTO?)
    case message(String, ErrorResponseDTO?)
    case unauthorized
    case accessDenied
    case notFound
    case serviceUnavailable
    case responseValidationFailed
    case unknown
}

struct ErrorAdapter {
    static func convert(_ error: HTTPClientError) -> AppError {
        switch error {
        case .emptySuccess:
            return .emptySuccess
        case .badRequest(let model):
            if let msg = model?.message {
                return .message(msg, model)
            } else {
                return .badRequest(model)
            }
        case .unauthorized:
            DispatchQueue.main.async {
                AppCore.shared.logout()
            }
            return .unauthorized
        case .accessDenied:
            return .accessDenied
        case .notFound(let msg):
            Task { @MainActor in
                AppCore.shared.showError(msg: msg)
            }
            return .message(msg ?? "", nil)
        case .serviceUnavailable(let msg):
            Task { @MainActor in
                AppCore.shared.showError(msg: msg)
            }
            return .serviceUnavailable
        case .responseValidationFailed:
            Task { @MainActor in
                AppCore.shared.showError()
            }
            return .responseValidationFailed
        default:
            Task { @MainActor in
                AppCore.shared.showError()
            }
            return .unknown
        }
    }
}

struct ValidationWrapper {
    public static func validate<T: Codable>(response: HTTPClientResponse) throws -> T {
        do {
            return try Validation.validate(response: response)
        } catch let error as HTTPClientError {
            throw ErrorAdapter.convert(error)
        } catch {
            throw AppError.unknown
        }
    }
}
