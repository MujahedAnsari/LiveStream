//
//  Video.swift
//  LiveStream
//
//  Created by Mujahed Ansari on 17/12/24.
//

import Foundation

struct Video: Codable {
    let id: Int
    let userID: Int
    let username: String
    let profilePicURL: String
    let description: String
    let topic: String
    let viewers: Int
    let likes: Int
    let video: String
    let thumbnail: String
}

struct  Videos: Codable {
    let videos: [Video]
}

struct Comment: Codable {
    let id: Int
    let username: String
    let picURL: String
    let comment: String
}

struct Comments: Codable {
    let comments: [Comment]
}
