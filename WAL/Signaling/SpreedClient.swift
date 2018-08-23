//
//  SpreedClient.swift
//  WAL
//
//  Created by Christian Braun on 21.08.18.
//

import Foundation
import Starscream
import WebRTC

protocol SpreedClientDelegate {
    func isReadyToConnectToRoom(_ sender: SpreedClient)
    func spreedClient(_ sender: SpreedClient, userDidJoin userId: String)
}

class SpreedClient: WebSocketDelegate {
    fileprivate let ws: WebSocket
    fileprivate var me: MeSignalingMessage?

    fileprivate var delegate: SpreedClientDelegate?
    fileprivate var roomName: String

    init(with url: String, roomName: String, delegate: SpreedClientDelegate) {
        self.delegate = delegate
        self.roomName = roomName
        ws = WebSocket(url: URL(string: url)!)
        ws.delegate = self
        ws.connect()
    }

    func connect() {
        guard me != nil else {
            return
        }
        let hello = HelloSignalingMessage(
            hello: HelloSignalingMessage.Hello(
                version: "1.0.0",
                userAgent: "iOS",
                roomName: roomName))

        guard let data = try? JSONEncoder().encode(hello) else {
            fatalError("Unable to encode HelloSignalingMessage")
        }

        ws.write(string: String(data: data, encoding: .utf8)!)
    }

    func send(offer: RTCSessionDescription, to userId: String) {

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

        guard let data = text.data(using: .utf8) else {
            fatalError("Wrong encoding for received message")
        }

        if let meCarrier = try? JSONDecoder().decode(
            Carrier<MeSignalingMessage>.self,
            from: data) {
            me = meCarrier.data
            delegate?.isReadyToConnectToRoom(self)
        } else if let welcomeCarrier = try? JSONDecoder().decode(
            Carrier<WelcomeSignalingMessage>.self,
            from: data) {
            print(welcomeCarrier.data.welcome)
        } else if let joinedCarrier = try? JSONDecoder().decode(
            Carrier<JoinedSignalingMessage>.self,
            from: data) {
            delegate?.spreedClient(self, userDidJoin: joinedCarrier.data.id)
        }
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Websocket data")
    }
}
