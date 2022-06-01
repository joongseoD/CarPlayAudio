//
//  CarPlaylistType.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation

enum CarplayPlaylistMenu: CarPlayMenu, CaseIterable {
    case music
    case audio
    
    var id: Int64 { 0 }
    
    var title: String {
        switch self {
        case .music:
            return "음악 재생목록"
        case .audio:
            return "오디오 재생목록"
        }
    }
}
