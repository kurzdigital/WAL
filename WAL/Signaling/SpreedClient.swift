//
//  SpreedClient.swift
//  WAL
//
//  Created by Christian Braun on 21.08.18.
//

import Foundation
import SwiftWebSocket

class SpreedClient {

    fileprivate let ws: WebSocket

    init(with url: String) {
        ws = WebSocket(url)
        setupWebSocketEventHandlers()
    }

    func setupWebSocketEventHandlers() {
        ws.event.open = {
            print("WebSocket opened")
        }

        ws.event.close = {_, _, _ in
            print("WebSocket closed")
        }

        ws.event.error = {error in
            print("Error: \(error)")
        }

        ws.event.message = { message in
            guard let payload = message as? String else {
                fatalError("Only expect messages as string from Signaling Server")
            }
            print(payload)
        }
    }
}
