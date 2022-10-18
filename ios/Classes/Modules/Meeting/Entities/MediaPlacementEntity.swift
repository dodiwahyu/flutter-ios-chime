//
//  MediaPlacementEntity.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation
import AmazonChimeSDK

struct MediaPlacementEntity: Codable {
    let audioHostUrl: String?
    let audioFallbackUrl: String?
    let screenDataUrl: String?
    let screenSharingUrl: String?
    let screenViewingUrl: String?
    let signalingUrl: String?
    let turnControlUrl: String?
    let eventIngestionUrl: String?
    
    var mediaPlacement: MediaPlacement? {
        get {
            guard let audioHostUrl = audioHostUrl,
                  let audioFallbackUrl = audioFallbackUrl,
                  // let screenSharingUrl = screenSharingUrl,
                  // let screenViewingUrl = screenViewingUrl,
                  let signalingUrl = signalingUrl,
                  let turnControlUrl = turnControlUrl
                  // let eventIngestionUrl = eventIngestionUrl
            else { return nil }
            
            return MediaPlacement(audioFallbackUrl: audioFallbackUrl, audioHostUrl: audioHostUrl, signalingUrl: signalingUrl, turnControlUrl: turnControlUrl)
        }
    }
}
