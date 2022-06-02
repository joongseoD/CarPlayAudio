//
//  SectionModel.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import UIKit
import CarPlay

struct CarPlayListModel {
    enum Header {
        case playlist
        case chart
        case theme
        case pop
        case cabinet
        
        var title: String {
            switch self {
            case .playlist:
                return "재생목록"
            case .chart:
                return "FLO 차트"
            case .theme:
                return "테마"
            case .pop:
                return "드라이브 인기곡"
            case .cabinet:
                return "보관함"
            }
        }
        
        var titleImageName: String {
            switch self {
            case .playlist:
                return "music.note.list"
            case .chart:
                return "music.note.list"
            case .theme:
                return "music.note.list"
            case .pop:
                return "music.note.list"
            case .cabinet:
                return "music.note.list"
            }
        }
    }
    
    var header: Header
    var sections: [CarPlayListSectionModel]
}

struct CarPlayListSectionModel {
    var title: String?
    var indexTitle: String?
    var items: [CarPlayListItemModel]
    
    // iOS 15 이상 지원
    var control: Control?
    
    struct Control {
        var subtitle: String
        var headerImageName: String
        var headerButtonImageName: String
        var headerButtonHandler: (CPButton) -> Void
    }
}

struct CarPlayListItemModel {
    var id: String?
    var text: String?
    var detailText: String?
    var image: UIImage?
    var imageUrl: String?
    var didTapItem: (() -> Void)?
}
