//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Manav Pavitra Singh on 5/28/22.
//

import Foundation

public struct FeedItem: Equatable {
    var id: UUID
    var imageURL: URL?
    var description: String?
    var location: String?
    
    public init(id: UUID, imageURL: URL?, description: String?, location: String?) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
