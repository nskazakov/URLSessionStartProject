//
//  ServerError.swift
//  URLSessionStartProject
//
//  Created by Alexey Pavlov on 29/11/21.
//

import Foundation

public enum ServerError: Error {
    
    // problem with sending request like no internet and others
    case networkProblem
    // our server is fallen down, most of the time it's happening case 500th error
    case serverFail
    // no way to parse receipt from apple directory
    case noReceipt
    // server cannot execute your request cause bad parameters
    // first value code status
    // second value error message
    case invalidRequest((Int, String))
    
}

// MARK: - LocalizedError

extension ServerError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .networkProblem: return ""
        case .serverFail: return ""
        case .noReceipt: return ""
        case .invalidRequest(_, let message): return message
        }
    }
    
}

/// MARK: - Equatable

extension ServerError: Equatable {
    
    public static func == (lhs: ServerError, rhs: ServerError) -> Bool {
        switch (lhs, rhs) {
        case (.networkProblem, .networkProblem):
            return true
        case (.serverFail, .serverFail):
            return true
        case (.noReceipt, .noReceipt):
            return true
        case (.invalidRequest(let code1, let message1), .invalidRequest(let code2, let message2)):
            if code1 == code2, message1 == message2 { return true }
            return false
        default:
            return false
        }
    }
    
}

