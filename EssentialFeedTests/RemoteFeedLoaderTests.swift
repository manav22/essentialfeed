//
//  File.swift
//  EssentialFeedTests
//
//  Created by Manav Pavitra Singh on 6/16/22.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}
class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {
    }
}

class HTTPCLientSpy: HTTPClient {
    var requestedURL: URL?
    override func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let client = HTTPCLientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestedDataFromURL() {
        let client = HTTPCLientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
}
