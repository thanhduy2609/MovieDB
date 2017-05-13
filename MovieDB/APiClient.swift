//
//  ApiClient.swift
//  MovieDB
//
//  Created by Duy Bùi on 5/12/17.
//  Copyright © 2017 Duy Bùi. All rights reserved.
//

import Foundation

class ApiClient {
    static let scheme = "https"
    static let host = "api.themoviedb.org"
    static let apiKeyParam = "api_key"
    static var apiKey: String = "4e0199d54b4c63aa2369c7ccc78436e4"
    
    //move paths
    static let nowPlayingPath = "/now_playing"
   
    class func createUrl(queryParams: [URLQueryItem]?) -> URL? {
        var urlComponent = URLComponents()
        
        urlComponent.scheme = scheme
        urlComponent.host = host
        urlComponent.path = "/3/movie"+nowPlayingPath
        urlComponent.queryItems = [apiKeyQueryParam()]
        
        if let queryParams = queryParams {
            urlComponent.queryItems?.append(contentsOf: queryParams)
        }
        return urlComponent.url
    }
    
   
    class func apiKeyQueryParam() -> URLQueryItem {
        return URLQueryItem(name: apiKeyParam, value: apiKey)
    }
}
