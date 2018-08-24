//
//  WebRTCConnection.swift
//  WAL
//
//  Created by Christian Braun on 20.08.18.
//  Copyright © 2018 KURZ Digital Solutions GmbH & Co. KG. All rights reserved.
//

import Foundation
import WebRTC

public class WebRTCConnection: NSObject {
    let config: Config
    fileprivate var spreedClient: SpreedClient?
    fileprivate let peerConnectionFactory = RTCPeerConnectionFactory()
    fileprivate var peerConnection: RTCPeerConnection?

    public init(with config: Config) {
        self.config = config
    }

    public func connect(roomName: String) {
        spreedClient = SpreedClient(
            with: config.signalingServerUrl,
            roomName: roomName,
            delegate: self)

        peerConnection = peerConnectionFactory
            .peerConnection(
                with: RTCConfiguration(),
                constraints: RTCMediaConstraints(
                    mandatoryConstraints: nil,
                    optionalConstraints: nil),
                delegate: self)
    }

    fileprivate func createMediaTracks() {
        let audioSource = peerConnectionFactory.audioSource(
            with: RTCMediaConstraints(
                mandatoryConstraints: nil,
                optionalConstraints: nil))
        let audioTrack = peerConnectionFactory.audioTrack(
            with: audioSource,
            trackId: "WaleAS01")

        // TODO: Here mediatrack id should be defined as property
    }
}

extension WebRTCConnection: SpreedClientDelegate {
    // MARK: - SpreedClientDelegate
    func isReadyToConnectToRoom(_ sender: SpreedClient) {
        spreedClient?.connect()
    }

    func spreedClient(_ sender: SpreedClient, userDidJoin userId: String) {
        print(userId)
    }
}

extension WebRTCConnection: RTCPeerConnectionDelegate {
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
    }

    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
    }
}
