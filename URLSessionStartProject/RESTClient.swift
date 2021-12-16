//
//  RESTClient.swift
//  URLSessionStartProject
//
//  Created by Alexey Pavlov on 29/11/21.
//

import Foundation

/// Запрашивает данные с наших серверов
public final class RESTClient {
    
    // MARK: - Types
    
    public enum RequestType: String {
        case put = "PUT"
        case get = "GET"
        case post = "POST"
    }

    // MARK: - Typealiases
    
    public typealias SessionCompletionHandler = (Data?, URLResponse?, Error?) -> Void
    public typealias ResultCompletionHandler = (ResponseResult<Data?, HTTPURLResponse, ServerError>) -> Void
    
    // MARK: - Public methods

    public static func call(request: URLRequest, session: URLSession?, completion handler: @escaping ResultCompletionHandler) {
        
        
        
        let completionHandler: SessionCompletionHandler = { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                handler(ResponseResult.failure(ServerError.networkProblem))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:   // по документации - 200 единственный статус, при котором ответ считается успешным
                handler(ResponseResult.success(data, httpResponse))
            case 500:
                handler(ResponseResult.failure(ServerError.serverFail))
            default:
                if let error = error as NSError? {
                    let errorTuple = (error.code, error.localizedDescription)
                    handler(ResponseResult.failure(ServerError.invalidRequest(errorTuple)))
                }
                if let data = data {
                    // handle data
                } else {
                    handler(ResponseResult.failure(ServerError.serverFail))
                }
            }
        }
        
        
        
        
        self.resumeDataTask(with: request, session: session, completionHandler: completionHandler)
    }
    
    public static func resumeDataTask(with request: URLRequest,
                               session: URLSession?,
                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        (session ?? URLSession.shared)
            .dataTask(with: request, completionHandler: completionHandler).resume()

//        URLSession.shared.uploadTask(with: request, from: Data()) // POST, PUT
//        (session ?? URLSession.shared).downloadTask(with: request, completionHandler: completionHandler).resume()
    }
}

