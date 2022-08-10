//
//  File.swift
//  EssentialFeedTests
//
//  Created by Manav Pavitra Singh on 6/16/22.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")
        let (sut, client) = makeSUT(url: url!)
        sut.load(){ _ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURl() {
        let url = URL(string: "https://a-given-url.com")
        let (sut, client) = makeSUT(url: url!)
        sut.load(){ _ in}
        sut.load(completion: { _ in})
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithError: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let invalidDataCodeSamples =  [199, 201, 300, 400, 500]
        
        invalidDataCodeSamples.enumerated().forEach({index, code in
            expect(sut, toCompleteWithError: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        })
    }
    
    func test_load_invalidJsonDataOn200HTTPURLResponse() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .failure(.invalidData), when: {
            let invalidJSON = Data( "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
        
    }
    
    func test_load_deliverNotItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .success([]), when: {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliverItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeFeedItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let item1JSON = item1.json
        
        let item2 = makeFeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://a-another-url.com"))
        let item2JSON = item2.json
    
        let items = [item1.model, item2.model]
    
        expect(sut, toCompleteWithError: .success(items), when: {
            let json = makeItemsJSON([item1JSON, item2JSON])
            client.complete(withStatusCode: 200, data: json )
        })
    }
    //MARK:- Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load{capturedResults.append($0)}
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func makeFeedItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL?) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, imageURL: imageURL, description: description, location: location)
        let itemJSON = [
            "id" : id.uuidString,
            "location": location,
            "description": description,
            "image": imageURL?.absoluteString
        ].reduce(into: [String: Any]()) { acc, e in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        return (item, itemJSON)
    }
    
    private func makeItemsJSON(_ items: [[String:Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    private class HTTPCLientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var completions = [(Error) -> Void]()
        var requestedURLs: [URL] {
            return messages.map{$0.url}
        }
        
        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    
    }
}
