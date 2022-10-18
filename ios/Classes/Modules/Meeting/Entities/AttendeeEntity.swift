//
//  AttendeeEntity.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 13/10/22.
//

import Foundation


struct AttendeeEntity: Codable {
    let externalUserId: String
    let attendeeId: String
    let joinToken: String
}
