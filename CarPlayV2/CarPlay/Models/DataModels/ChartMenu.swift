//
//  ChartMenu.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation

enum ChartMenu: CarPlayMenu, CaseIterable {
    case flo
    case pop
    case kids
    case new
    
    var title: String {
        switch self {
        case .flo:
            return "FLO차트"
        case .pop:
            return "해외 소셜 차트"
        case .kids:
            return "키즈 차트"
        case .new:
            return "최신앨범"
        }
    }
    
    var id: Int64 {
        switch self {
        case .flo:
            return 0
        case .pop:
            return 1
        case .kids:
            return 2
        case .new:
            return 3
        }
    }
}
