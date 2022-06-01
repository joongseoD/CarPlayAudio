//
//  CarPlayProvider.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation
import RxSwift

protocol CarPlayProviding: AnyObject {
    var playListMenu: Observable<[CarPlayMenu]> { get }
    
    func playlist(type: CarplayPlaylistMenu) -> Observable<[CarPlayMenu]>
    
    var chartMenu: Observable<[CarPlayMenu]> { get }
    
    func chart(id: Int64) -> Observable<[CarPlayMenu]>
    
    func themeList() -> Observable<[CarPlayMenu]>
    
    func themeDetail(id: Int64) -> Observable<[CarPlayMenu]>
    
    func driveThemeList() -> Observable<[CarPlayMenu]>
    
    func driveDetail(id: Int64) -> Observable<[CarPlayMenu]>
                                                
    var cabinetMenu: Observable<[CarPlayMenu]> { get }
    
    func myList(id: Int64) -> Observable<[CarPlayMenu]>
    
    //.....
}

final class CarPlayProvider: CarPlayProviding {
    var playListMenu: Observable<[CarPlayMenu]> {
        return .just(CarplayPlaylistMenu.allCases)
    }
    
    func playlist(type: CarplayPlaylistMenu) -> Observable<[CarPlayMenu]> {
        if type == .music {
            return musicPlayListMenu
        } else {
            return audioPlayListMenu
        }
    }
    
    private var musicPlayListMenu: Observable<[CarPlayMenu]> {
        return .just([
            CarPlayMenuModel(id: 0, title: "음악1"),
            CarPlayMenuModel(id: 1, title: "음악2")
        ])
    }
    
    private var audioPlayListMenu: Observable<[CarPlayMenu]> {
        return .just([
            CarPlayMenuModel(id: 0, title: "오디오1"),
            CarPlayMenuModel(id: 1, title: "오디오2")
        ])
    }
    
    var chartMenu: Observable<[CarPlayMenu]> {
        return .just(ChartMenu.allCases)
    }
    
    func chart(id: Int64) -> Observable<[CarPlayMenu]> {
        return .just([])
    }
    
    func themeList() -> Observable<[CarPlayMenu]> {
        return .just([
            CarPlayMenuModel(id: 0, title: "기분좋을떄 듣는 음악 목록"),
            CarPlayMenuModel(id: 1, title: "힙합 리스트"),
        ])
    }
    
    func themeDetail(id: Int64) -> Observable<[CarPlayMenu]> {
        return .just([
            CarPlayMenuModel(id: 1, title: "힙합1"),
            CarPlayMenuModel(id: 1, title: "힙합2"),
            CarPlayMenuModel(id: 1, title: "힙합3"),
        ])
    }
    
    func driveThemeList() -> Observable<[CarPlayMenu]> {
        return .just([])
    }
    
    func driveDetail(id: Int64) -> Observable<[CarPlayMenu]> {
        return .just([])
    }
                                                
    var cabinetMenu: Observable<[CarPlayMenu]> {
        return .just(CabinetMenu.allCases)
    }
    
    func myList(id: Int64) -> Observable<[CarPlayMenu]> {
        return .just([
            CarPlayMenuModel(id: 1, title: "힙합1"),
            CarPlayMenuModel(id: 1, title: "힙합2"),
            CarPlayMenuModel(id: 1, title: "힙합3"),
        ])
    }
}
