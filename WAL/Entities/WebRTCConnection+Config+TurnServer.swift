//
//  WebRTCConnection+Config+TurnServer.swift
//  Pods-Whale
//
//  Created by Christian Braun on 21.08.18.
//

import Foundation

public extension WebRTCConnection {
    public struct Config {
        public let signalingServerUrl: String
        public let turnServer: TurnServer?
        public let stunServerUrl: String?

        public init(signalingServerUrl: String, turnServer: TurnServer?, stunServerUrl: String?) {
            self.signalingServerUrl = signalingServerUrl
            self.turnServer = turnServer
            self.stunServerUrl = stunServerUrl
        }
    }

    public struct TurnServer {
        public let url: String
        public let username: String
        public let password: String

        public init(url: String, username: String, password: String) {
            self.url = url
            self.username = username
            self.password = password
        }
    }
}
