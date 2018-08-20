//
//  WebRTCConnectionConfig+TurnServer.swift
//  WAL
//
//  Created by Christian Braun on 20.08.18.
//  Copyright © 2018 KURZ Digital Solutions GmbH & Co. KG. All rights reserved.
//

import Foundation

extension WebRTCConnection {
    struct Config {
        let signalingServerUrl: URL
        let turnServer: TurnServer?
        let stunServerUrl: URL?
    }

    struct TurnServer {
        let url: URL
        let username: String
        let password: String
    }
}
