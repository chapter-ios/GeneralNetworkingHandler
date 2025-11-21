//
//  File.swift
//  GeneralNetworkingHandler
//
//  Created by Satori on 21/11/25.
//

import Foundation

public enum ApiError: Error {
    case badRequest(message: String?)
    case unauthorized
    case forbidden
    case notFound
    case serverError(message: String?)
    case decodingError(Error)
    case unknown(statusCode: Int?, message: String?)
}

extension ApiError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .badRequest(let message):
            return message ?? "Request was invalid." // 400
        case .unauthorized:
            return "Authentication required or expired." //401
        case .forbidden:
            return "You do not have permission to perform this action." // 403
        case .notFound:
            return "The requested resource was not found." // 404
        case .serverError(let message):
            return message ?? "The server encountered an error." // 500
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown(let statusCode, let message):
            if let message = message {
                return message
            }
            if let statusCode = statusCode {
                return "Unexpected error occurred. (Status: \(statusCode))"
            }
            return "Unexpected error occurred."
        }
    }
}

public struct ErrorResponse: Decodable {
    let message: String?
    let error: String?
    let detail: String?

    public var unifiedMessage: String? {
        message ?? error ?? detail
    }
}
