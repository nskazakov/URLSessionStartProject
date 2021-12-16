//
//  EndpointClient.swift
//  URLSessionStartProject
//
//  Created by Alexey Pavlov on 29/11/21.
//

import Foundation

public enum ResponseResult<Data, Response: HTTPURLResponse, Error> {
    case success(Data, Response)
    case failure(Error)
}

public enum PureResult<E> {
    case success
    case failure(E)
}


public final class EndpointClient {

    // MARK: - Types

    public typealias ObjectEndpointCompletion<Object: Decodable> = (Result<Object, Error>, HTTPURLResponse?) -> ()
    public typealias SuccessEndpointCompletion = (PureResult<Error>) -> ()

    // MARK: - Private Properties

    private let applicationSettings: ApplicationSettingsService
    private var masterServerURL: String { "https://api.magicthegathering.io" }
//    private var masterServerURL: String { "http://localhost:5055" }

    // MARK: - Initialization

    public init(applicationSettings: ApplicationSettingsService) {
        self.applicationSettings = applicationSettings
    }

    // MARK: - Public Methods

    public func executeRequest<Object: Decodable>(_ endpoint: ObjectResponseEndpoint<Object>,
                                           completion: @escaping ObjectEndpointCompletion<Object>) {
        guard let requestURL = makeRequestUrl(path: endpoint.path, queryItems: endpoint.queryItems) else {
            completion(.failure(EndpointClientError.wrongURL), nil)
            return
        }
        var body: String?

        if let endpointParameters = endpoint.parameters {
            let jsonData = try? JSONSerialization.data(withJSONObject: endpointParameters)
            if let data = jsonData {
                body = String(data: data, encoding: .utf8)
            }
        }

        var urlSession: URLSession?
        if let requestTimeout = endpoint.timeout {
            urlSession = makeUrlSessionWithTimeout(requestTimeout)
        }

        let completionHandler = objectResponseCompletionHandler(completion: completion)

        executeRequest(method: endpoint.method,
                       requestUrl: requestURL,
                       headers: endpoint.httpHeaders,
                       body: body,
                       urlSession: urlSession,
                       completionHandler: completionHandler)
    }

    public func executeRequest(_ endpoint: EmptyResponseEndpoint, completion: @escaping SuccessEndpointCompletion) {
        guard let requestURL = makeRequestUrl(path: endpoint.path, queryItems: endpoint.queryItems) else {
            completion(.failure(EndpointClientError.wrongURL))
            return
        }
        var body: String?

        if let endpointParameters = endpoint.parameters {
            let jsonData = try? JSONSerialization.data(withJSONObject: endpointParameters)
            if let data = jsonData {
                body =  String(data: data, encoding: .utf8)
            }
        }

        var urlSession: URLSession?
        if let requestTimeout = endpoint.timeout {
            urlSession = makeUrlSessionWithTimeout(requestTimeout)
        }

        let completionHandler = emptyResponseCompletionHandler(completion: completion)
        executeRequest(method: endpoint.method,
                       requestUrl: requestURL,
                       headers: endpoint.httpHeaders,
                       body: body,
                       urlSession: urlSession,
                       completionHandler: completionHandler)
    }

    // MARK: - Private

    private func makeRequestUrl(path: String, queryItems: [URLQueryItem]?) -> URL? {
        guard let baseURL = URL(string: masterServerURL) else {
            return nil
        }
        let requestURL: URL
        if path.isEmpty {
            requestURL = baseURL
        } else {
            requestURL = baseURL.appendingPathComponent(path)
        }
        if let queryItems = queryItems {
            var urlComponents = URLComponents(string: requestURL.absoluteString) // "https://api.magicthegathering.io/v1/cards?name=Black%20Lotus"
            urlComponents?.queryItems = queryItems
            guard let newRequestURL = urlComponents?.url else {
                return nil
            }
            return newRequestURL
        }
        
        return requestURL
    }

    private func makeUrlSessionWithTimeout(_ timeout: TimeInterval) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true // Разрешать доступ с мобильной связи
        configuration.waitsForConnectivity = true // Должны ли ждать подключение если в момент оно не доступно (например впн нужен)
        configuration.timeoutIntervalForRequest = timeout // Таймаут запроса
        configuration.httpMaximumConnectionsPerHost = 100 // Максимальное количество подключений одновременно к хосту
        configuration.urlCache = URLCache() // Кэш URL для предоставления кэшированных ответов на запросы в рамках сеанса.
        return URLSession(configuration: configuration)
    }

    private func objectResponseCompletionHandler<Object: Decodable>(
        completion: @escaping ObjectEndpointCompletion<Object>
        ) -> RESTClient.ResultCompletionHandler {
        return { result in
            switch result {
            case .success(let data, let response):
                do {
                    let objects = try self.map(Object.self, data: data)
                    mainAsync {
                        completion(.success(objects), response)
                    }
                } catch {
                    mainAsync {
                        completion(.failure(EndpointClientError.parsingError), response)
                    }
                }
            case .failure(let error):
                mainAsync {
                    completion(.failure(EndpointClientError.serverError(error)), nil)
                }
            }
        }
    }

    private func emptyResponseCompletionHandler(
        completion: @escaping SuccessEndpointCompletion
        ) -> RESTClient.ResultCompletionHandler {
        return { result in
            switch result {
            case .success:
                mainAsync {
                    completion(.success)
                }
            case .failure(let error):
                mainAsync {
                    completion(.failure(EndpointClientError.serverError(error)))
                }
            }
        }
    }

    private func executeRequest(method: RESTClient.RequestType,
                                requestUrl: URL,
                                headers: [String: String]?,
                                body: String?,
                                urlSession: URLSession?,
                                completionHandler: @escaping RESTClient.ResultCompletionHandler) {
        let request = makeRequest(method: method, url: requestUrl, headers: headers, body: body)
        RESTClient.call(request: request, session: urlSession, completion: completionHandler)
    }

    private func makeRequest(
        method: RESTClient.RequestType,
        url: URL,
        headers: [String: String]?,
        body: String?
        ) -> URLRequest {
        var request = URLRequest(url: url) // уже содержит query items
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body?.data(using: String.Encoding.utf8)
        return request
    }

    private func map<D: Decodable>(_ type: D.Type,
                                   data: Data?,
                                   using decoder: JSONDecoder = .webApiDecoder()) throws -> D
    {
        guard let data = data else { throw EndpointClientError.noParsingData }
        do {
            print("data = \(String(describing: (String(data: data, encoding: .utf8))))")
            return try decoder.decode(D.self, from: data)
        } catch {
            throw error
        }
    }
}

func mainAsync(block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

extension JSONDecoder {
    
    class func webApiDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .webApiCustomDateDecodingStrategy
        
        return decoder
    }
}

extension JSONDecoder.DateDecodingStrategy {
    
    /// Переменная хранит в себе политику распознавания дат, которые приходят от WebApi
    /// - "yyyy-MM-dd HH:mm:ssZ" - полный формат даты (с часовым поясом)
    static var webApiCustomDateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return JSONDecoder.DateDecodingStrategy.custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            
            guard let date = dateFormatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            
            return date
        }
    }
}

