//
//  WebRTCConnection.swift
//  WAL
//
//  Created by Christian Braun on 20.08.18.
//  Copyright © 2018 KURZ Digital Solutions GmbH & Co. KG. All rights reserved.
//

import Foundation
import WebRTC

fileprivate let audioTrackId = "WaleAS01"
fileprivate let videoTrackId = "WaleVS01"
fileprivate let mediaStreamId = "WaleMS"

public protocol WebRTCConnectionDelegate: class {
    func webRTCConnection(_ sender: WebRTCConnection, didReceiveLocalCapturer localCapturer: RTCCameraVideoCapturer)
    func webRTCConnection(_ sender: WebRTCConnection, didReceiveRemoteVideoTrack remoteTrack: RTCVideoTrack)
    func webRTCConnection(_ sender: WebRTCConnection, userDidJoin userId: String)
    func webRTCConnection(_ sender: WebRTCConnection, didChange state: WebRTCConnection.State)
    func didOpenDataChannel(_ sender: WebRTCConnection)
    func webRTCConnection(_ sender: WebRTCConnection, didReceiveDataChanelData data: Data)
    func didDisconnect(_ sender: WebRTCConnection)
    func didReceiveIncomingCall(_ sender: WebRTCConnection, from userId: String)
}

public class WebRTCConnection: NSObject {
    public enum State {
        case disconnected
        case connectingToSignalingServer
        case connectingWithPartner
        case connectedWithPartner
    }

    public var state = WebRTCConnection.State.disconnected {
        didSet {
            if oldValue != state {
                delegate?.webRTCConnection(self, didChange: state)
            }
        }
    }
    let config: Config
    fileprivate(set) var localCapturer: RTCCameraVideoCapturer?


    fileprivate weak var delegate: WebRTCConnectionDelegate?
    fileprivate var spreedClient: SpreedClient?
    fileprivate let peerConnectionFactory = RTCPeerConnectionFactory()
    fileprivate var peerConnection: RTCPeerConnection?
    fileprivate var partnerId: String?
    fileprivate var remoteVideoTrack: RTCVideoTrack?
    fileprivate var datachannel: RTCDataChannel?

    fileprivate let mandatorySdpConstraints = RTCMediaConstraints(
        mandatoryConstraints:["OfferToReceiveAudio": "true",
                              "OfferToReceiveVideo": "true"],
        optionalConstraints: nil)

    public init(with config: Config, delegate: WebRTCConnectionDelegate) {
        self.config = config
        self.delegate = delegate
    }

    public func join(roomName: String) {
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

        createMediaTracks()
        state = .connectingToSignalingServer
    }

    public func connect(toUserId userId: String) {
        partnerId = userId
        createDataChannel()
        peerConnection?.offer(
        for: mandatorySdpConstraints) {sessionDescription, error in
            if let error = error {
                print(error)
                return
            }
            guard let sessionDescription = sessionDescription else {
                fatalError("Session Description empty")
            }

            self.peerConnection?.setLocalDescription(
                sessionDescription,
                completionHandler: { (error) in
                    if let error = error {
                        fatalError("Unable to set local description \(error)")
                    }
            })
            self.spreedClient?.send(
                offer: sessionDescription,
                to: userId)
        }
    }

    public func answerIncomingCall(userId: String) {
        partnerId = userId
        peerConnection?.answer(for: mandatorySdpConstraints) { sessionDescription, error in
            if let error = error {
                print(error)
                return
            }
            guard let sessionDescription = sessionDescription else {
                fatalError("Session Description empty")
            }

            self.peerConnection?.setLocalDescription(
                sessionDescription,
                completionHandler: { (error) in
                    if let error = error {
                        fatalError("Unable to set local description \(error)")
                    }
                    self.spreedClient?.send(
                        answer: sessionDescription,
                        to: userId)
            })
        }
    }

    public func disconnect() {
        spreedClient?.disconnect()
        peerConnection?.close()
        peerConnection = nil
        datachannel = nil
        localCapturer = nil
        remoteVideoTrack = nil
        partnerId = nil
    }

    public func send(data: Data) {
       datachannel?.sendData(RTCDataBuffer(data: data, isBinary: false))
    }

    fileprivate func createDataChannel() {
        let dataChannelConfig = RTCDataChannelConfiguration()
        dataChannelConfig.isOrdered = true
        dataChannelConfig.channelId = 12
        dataChannelConfig.protocol = "WhaleDataChannelProtocol"

        datachannel = peerConnection?.dataChannel(
            forLabel: "WhaleDataChannel",
            configuration: dataChannelConfig)

        datachannel?.delegate = self
    }

    fileprivate func createMediaTracks() {
        let audioSource = peerConnectionFactory.audioSource(
            with: RTCMediaConstraints(
                mandatoryConstraints: nil,
                optionalConstraints: nil))
        let audioTrack = peerConnectionFactory.audioTrack(
            with: audioSource,
            trackId: audioTrackId)
        let videoSource = peerConnectionFactory.videoSource()
        let videoTrack = peerConnectionFactory.videoTrack(
            with: videoSource,
            trackId: videoTrackId)
        localCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        guard let device = RTCCameraVideoCapturer
            .captureDevices()
            .first(where: {$0.position == .front}) else {
                fatalError()
        }

        let mediaStream = peerConnectionFactory.mediaStream(withStreamId: mediaStreamId)
        mediaStream.addAudioTrack(audioTrack)
        mediaStream.addVideoTrack(videoTrack)
        peerConnection?.add(mediaStream)

        let format = RTCCameraVideoCapturer.format(for: device, constraints: config.formatConstraints)
        localCapturer?.startCapture(
            with: device,
            format: format,
            fps: RTCCameraVideoCapturer.fps(for: format))
        delegate?.webRTCConnection(self, didReceiveLocalCapturer: localCapturer!)
    }
}

extension WebRTCConnection: SpreedClientDelegate {
    func connectionDidClose(_ sender: SpreedClient) {
        // Do nothing
    }

    // MARK: - SpreedClientDelegate
    func isReadyToConnectToRoom(_ sender: SpreedClient) {
        spreedClient?.connect()
    }

    func spreedClient(_ sender: SpreedClient, userDidLeave userId: String) {
        spreedClient?.disconnect()
        peerConnection?.close()
    }

    func spreedClient(_ sender: SpreedClient, userDidJoin userId: String) {
        delegate?.webRTCConnection(self, userDidJoin: userId)
    }

    func spreedClient(_ sender: SpreedClient,
                      didReceiveOffer offer: RTCSessionDescription,
                      from userId: String) {
        self.peerConnection?.setRemoteDescription(offer, completionHandler: { error in
            if let error = error {
                fatalError("Unable to set remote description \(error)")
            }
        })
        delegate?.didReceiveIncomingCall(self, from: userId)

    }

    func spreedClient(_ sender: SpreedClient,
                      didReceiveAnswer answer: RTCSessionDescription,
                      from userId: String) {
        peerConnection?.setRemoteDescription(answer, completionHandler: { error in
            if let error = error {
                fatalError("Unable to set remote description \(error)")
            }
        })
    }

    func spreedClient(_ sender: SpreedClient, didReceiveCandidate candidate: RTCIceCandidate, from userId: String) {
        peerConnection?.add(candidate)
    }
}

extension WebRTCConnection: RTCPeerConnectionDelegate {
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print(#function)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print(#function)
        guard let remoteVideoTrack = stream.videoTracks.first else {
            print("No Video Tracks")
            return
        }
        self.remoteVideoTrack = remoteVideoTrack
        delegate?.webRTCConnection(self, didReceiveRemoteVideoTrack: remoteVideoTrack)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print(#function)
    }

    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print(#function)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print(#function)
        switch newState {
        case .new:
            print("New")
        case .checking:
            state = .connectingWithPartner
        case .connected:
            state = .connectedWithPartner
        case .completed:
            print("Completed")
        case .failed:
            state = .disconnected
            print("Failed")
        case .disconnected:
            state = .disconnected
            print("Disconnected")
        case .closed:
            print("Closed")
            state = .disconnected
            delegate?.didDisconnect(self)
        case .count:
            print("Count")
        }
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print(#function)

        switch newState {
        case .new:
            print("new ice gathering")
        case .gathering:
            print("gathering")
        case .complete:
            print("complete ice gathering")
        }
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print(#function)
        guard let partnerId = partnerId else {
            fatalError("Can't send candidate without partner")
        }
        spreedClient?.send(candidate, to: partnerId)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print(#function)
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print(#function)
        print("DataChannel opened")
        delegate?.didOpenDataChannel(self)
    }
}

extension WebRTCConnection: RTCDataChannelDelegate {
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        print(#function)
    }

    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        delegate?.webRTCConnection(self, didReceiveDataChanelData: buffer.data)
    }
}
