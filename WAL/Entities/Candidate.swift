//
//  Candidate.swift
//  WAL
//
//  Created by Christian Braun on 23.08.18.
//

import Foundation
import WebRTC

struct Candidate: Codable {
    let type: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    let candidate: String


    func toRtcCandidate() -> RTCIceCandidate  {
        return RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }
}
