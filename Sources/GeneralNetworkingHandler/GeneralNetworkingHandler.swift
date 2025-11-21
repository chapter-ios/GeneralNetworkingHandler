// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Alamofire

public protocol Networking {
    func get<T: Decodable & Sendable>(
        _ url: String,
        token: String?
    ) async throws -> T
}

public final class NetworkingHelper: Networking {

    public init() {}

    public func get<T: Decodable & Sendable>(
        _ url: String,
        token: String?
    ) async throws -> T {

        return try await withCheckedThrowingContinuation { continuation in

            var headers: HTTPHeaders = [
                "Accept": "application/json"
            ]
            
            if let token = token {
                headers.add(name: "Authorization", value: "Bearer \(token)")
            }
            
            AF.request(url, method: .get, headers: headers)
                .validate()
                .responseDecodable(of: T.self) { response in
        
                    switch response.result {
                    case .success(let decoded):
                        continuation.resume(returning: decoded)

                    case .failure(_):
                        
                        let statusCode = response.response?.statusCode
                        let message = try? JSONDecoder().decode(ErrorResponse.self, from: response.data ?? Data()).unifiedMessage
                        
                        let apiError: ApiError
                        
                        switch statusCode {
                        case 400: return apiError = .badRequest(message: message)
                        case 401: return apiError = .unauthorized
                        case 403: return apiError = .forbidden
                        case 404: return apiError = .notFound
                        case 500: apiError = .serverError(message: message)
                        default:
                            return apiError = .unknown(statusCode: statusCode, message: message)
                        }
                        
                        continuation.resume(throwing: apiError)
                    }
                }
        }
    }
}

