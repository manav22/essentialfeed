//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Manav Pavitra Singh on 5/28/22.
//

import Foundation

public struct FeedItem {
    var id: UUID
    var imageURL: URL?
    var description: String?
    var location: String?
    var number: Int
}
