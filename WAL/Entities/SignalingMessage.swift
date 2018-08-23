//
//  SignalingMessage.swift
//  WAL
//
//  Created by Christian Braun on 22.08.18.
//

import Foundation

enum SignalingMessageType: String, Codable {
    case error = "Error"
    case me = "Self"
    case hello = "Hello"
    case welcome = "Welcome"
    case joined = "Joined"
    case bye = "Bye"
    case offer = "Offer"
    case answer = "Answer"
    case candidate = "Candidate"
}

protocol SignalingMessage: Codable {
    var type: SignalingMessageType { get }
}

struct ErrorSignalingMessage: SignalingMessage {
    var type = SignalingMessageType.error

    let code: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case code = "Code"
        case message = "Message"
    }
}

struct MeSignalingMessage: SignalingMessage {
    var type = SignalingMessageType.me

    let token: String

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case token = "Token"
    }

    init(token: String) {
        self.token = token
    }
}

struct HelloSignalingMessage: SignalingMessage {
    struct Hello: Codable {
        let version: String
        let userAgent: String
        let roomName: String
        let type = ""

        enum CodingKeys: String, CodingKey {
            case version = "Version"
            case userAgent = "Ua"
            case roomName = "Name"
            case type = "Type"
        }
    }

    var type = SignalingMessageType.hello
    var hello: Hello

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case hello = "Hello"
    }

    init(hello: Hello) {
        self.hello = hello
    }
}

struct WelcomeSignalingMessage: SignalingMessage {
    struct Welcome: Codable {
        let room: String
        let users: [String]

        enum CodingKeys: String, CodingKey {
            case room = "Room"
            case users = "Users"
        }
    }

    var type = SignalingMessageType.welcome

    var welcome: Welcome

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case welcome = "Welcome"
    }
}

struct JoinedSignalingMessage: SignalingMessage {
    var type = SignalingMessageType.joined

    let id: String
    let userAgent: String

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case id = "Id"
        case userAgent = "Ua"
    }
}

struct ByeSignalingMessage: SignalingMessage {
    struct Bye: Codable {
        let to: String
        let type: String

        enum CodingKeys: String, CodingKey {
            case to = "To"
            case type = "Type"
        }
    }

    var type = SignalingMessageType.bye

    let bye: Bye

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case bye = "Bye"
    }
}

struct OfferSignalingMessage: SignalingMessage {
    struct OfferContainer: Codable {
        let to: String
        let type: String
        let offer: SessionDescription

        enum CodingKeys: String, CodingKey {
            case to = "To"
            case type = "Type"
            case offer = "Offer"
        }
    }

    var type = SignalingMessageType.offer

    var offer: OfferContainer

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case offer = "Offer"
    }
}

struct AnswerSignalingMessage: SignalingMessage {
    struct AnswerContainer: Codable {
        let to: String
        let type: String
        let answer: SessionDescription

        enum CodingKeys: String, CodingKey {
            case to = "To"
            case type = "Type"
            case answer = "Answer"
        }
    }

    var type = SignalingMessageType.answer

    var answer: AnswerContainer

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case answer = "Answer"
    }
}

struct CandidateSignalingMessage: SignalingMessage {
    struct CandidateContainer: Codable {
        let to: String
        let type: String
        let candidate: Candidate

        enum CodingKeys: String, CodingKey {
            case to = "To"
            case type = "Type"
            case candidate = "Candidate"
        }
    }

    var type = SignalingMessageType.answer

    var candidate: CandidateContainer

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case candidate = "Candidate"
    }
}
