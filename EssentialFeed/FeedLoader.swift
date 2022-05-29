//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Manav Pavitra Singh on 5/28/22.
//

import Foundation

enum LoadFeedResult {
    case success ([FeedItem])
    case error (Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
