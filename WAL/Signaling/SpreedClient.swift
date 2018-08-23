//
//  SpreedClient.swift
//  WAL
//
//  Created by Christian Braun on 21.08.18.
//

import Foundation
import Starscream

class SpreedClient: WebSocketDelegate {

    fileprivate let ws: WebSocket

    init(with url: String) {
        ws = WebSocket(url: URL(string: "ws://localhost:8080/ws")!)
        ws.delegate = self
    }

    func connect() {
        ws.connect()
    }

    // MARK: - WebSocketDelegate
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected")
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Websocket disconnected")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Websocket message \(text)")
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Websocket data")
    }
}
