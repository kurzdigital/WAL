//
//  SessionDescription.swift
//  WAL
//
//  Created by Christian Braun on 23.08.18.
//

import Foundation
import WebRTC

enum SdpType: String, Codable {
    case offer
    case answer
    case pranswer
}
struct SessionDescription: Codable {
    let type: SdpType
    let sdp: String

    func toRTCSessionDescription() -> RTCSessionDescription {
        let rtcSdpType: RTCSdpType

        switch type {
        case .offer:
            rtcSdpType = .offer
        case .answer:
            rtcSdpType = .answer
        case .pranswer:
            rtcSdpType = .prAnswer
        }
        return RTCSessionDescription(type: rtcSdpType, sdp: sdp)
    }
}
