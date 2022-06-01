//
//  CabinetMenu.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation

enum CabinetMenu: CarPlayMenu, CaseIterable {
    case myList
    case likeMusicList
    case likeAudioList
    case likeAlbum
    case likeThemeList
    
    var id: Int64 {
        switch self {
        case .myList:
            return 0
        case .likeMusicList:
            return 1
        case .likeAudioList:
            return 2
        case .likeAlbum:
            return 3
        case .likeThemeList:
            return 4
        }
    }
    
    var title: String {
        switch self {
        case .myList:
            return "내 리스트"
        case .likeMusicList:
            return "좋아요 한 곡"
        case .likeAudioList:
            return "좋아요 한 오디오"
        case .likeAlbum:
            return "좋아요 한 앨범"
        case .likeThemeList:
            return "좋아요 한 테마리스트"
        }
    }
}
