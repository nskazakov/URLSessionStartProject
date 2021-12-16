//
//  Endpoint.swift
//  URLSessionStartProject
//
//  Created by Alexey Pavlov on 29/11/21.
//

import Foundation

// Класс описывающий Endpoint

public class Endpoint {
    public var method: RESTClient.RequestType { fatalError() }
    public var path: String { fatalError() }
    public var httpHeaders: [String: String] {
        switch method {
        case .get:
            return ["Cache-Control": "no-cache"]
            
        case .post, .put:
            return ["Content-Type": "application/json", // тип отправляемых данных {json/form-data/html} для post / put
                    "Accept": "application/json", // какой тип данных сервер сможет принять
                    "Cache-Control": "no-cache"] // инструкции кеширования
        }
    }

    public var parameters: [String: Any]?
    public var timeout: TimeInterval?
    public var queryItems: [URLQueryItem]?
    
    public init() {
        
    }
}

// Класс описывающий Endpoint, который в response ожидает получить какие-то объекты
public class ObjectResponseEndpoint<T: Decodable>: Endpoint { }

// Класс описывающий Endpoint, который подразумевает пустой response
public class EmptyResponseEndpoint: Endpoint { }
