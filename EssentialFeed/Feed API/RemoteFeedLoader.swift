//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Manav Pavitra Singh on 7/14/22.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL, completion: @escaping(Error) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void = { _ in}) {
        client.get(url: url) { error in
            completion(.connectivity)
        }
    }
}

