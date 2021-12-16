//
//  EndpointClientError.swift
//  URLSessionStartProject
//
//  Created by Alexey Pavlov on 29/11/21.
//

import Foundation

public enum EndpointClientError: Error {
    case serverError(ServerError)
    case noParsingData
    case parsingError
    case cantBuildJWTBody
    case wrongURL
}

// MARK: - LocalizedError

extension EndpointClientError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .noParsingData, .parsingError, .cantBuildJWTBody: return ""
        case .wrongURL: return ""
        case .serverError(let serverError): return serverError.errorDescription
        }
    }
}

/// MARK: - Equatable

extension EndpointClientError: Equatable {
    public static func == (lhs: EndpointClientError, rhs: EndpointClientError) -> Bool {
        switch (lhs, rhs) {
        case (.noParsingData, .noParsingData):
            return true
        case (.parsingError, .parsingError):
            return true
        case (.cantBuildJWTBody, .cantBuildJWTBody):
            return true
        case (.wrongURL, .wrongURL):
            return true
        case (.serverError(let lhsServerError), .serverError(let rhsServerError)):
            return lhsServerError == rhsServerError
        default:
            return false
        }
    }

}

