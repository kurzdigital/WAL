//
//  WebRTCConnection.swift
//  WAL
//
//  Created by Christian Braun on 20.08.18.
//  Copyright © 2018 KURZ Digital Solutions GmbH & Co. KG. All rights reserved.
//

import Foundation

public class WebRTCConnection {
    let config: Config
    fileprivate var spreedClient: SpreedClient?

    public init(with config: Config) {
        self.config = config
    }

    public func connect() {
        spreedClient = SpreedClient(with: config.signalingServerUrl)
    }
}
