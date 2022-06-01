//
//  CarPlayTemplateModel.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import UIKit
import RxSwift
import RxCocoa

protocol CarPlayTemplateModeling: AnyObject {
    var provider: CarPlayProviding { get }
}

final class CarPlayTemplateModel: CarPlayTemplateModeling {
    private let menuBuilderSubject = PublishSubject<Action.Push>()
    private let playSubject = PublishSubject<Action.Play>()
    
    var provider: CarPlayProviding
    var mainScheduler: SchedulerType
    
    init(provider: CarPlayProviding = CarPlayProvider(), mainScheduler: SchedulerType = MainScheduler.instance) {
        self.provider = provider
        self.mainScheduler = mainScheduler
    }
    
    struct Input {
        let refresh: Observable<Void>
    }
    
    struct Output {
        let tabBarModel: Observable<[CarPlayListModel]>
        let push: Observable<CarPlayListModel>
        let play: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        
        let playList = input.refresh
            .flatMap {
                return self.provider.playListMenu
            }
            .listBuilder(header: .playlist, onTap: { menu in
                guard let type = menu as? CarplayPlaylistMenu else { return }
                self.menuBuilderSubject.onNext(.playlist(type: type))
            })
            
        let chartMenu = input.refresh
            .flatMap {
                return self.provider.chartMenu
            }
            .listBuilder(header: .chart, onTap: { menu in
                self.menuBuilderSubject.onNext(.chart(id: menu.id))
            })
        
        let themeMenu = input.refresh
            .flatMap {
                return self.provider.themeList()
            }
            .listBuilder(header: .theme) { menu in
                self.menuBuilderSubject.onNext(.themeDetail(id: menu.id))
            }
        
        let cabinetMenu = input.refresh
            .flatMap {
                return self.provider.cabinetMenu
            }
            .listBuilder(header: .cabinet) { menu in
                guard let type = menu as? CabinetMenu else { return }
                if type == .likeMusicList {
                    self.playSubject.onNext(.likeMusicList(id: menu.id))
                } else {
                    self.menuBuilderSubject.onNext(.cabinet(type: type))
                }
            }
            
        let tabBarModel = Observable.combineLatest(
            playList,
            chartMenu,
            themeMenu,
            cabinetMenu,
            resultSelector: { [$0, $1, $2, $3] }
        )
            .observe(on: mainScheduler)

        let push = menuBuilderSubject
            .flatMap { menu -> Observable<CarPlayListModel> in
                switch menu {
                case let .playlist(type):
                    return self.provider.playlist(type: type)
                        .listBuilder(header: .playlist) { menu in
                            self.playSubject.onNext(.track(id: menu.id))
                        }
                case let .chart(id):
                    return self.provider.chart(id: id)
                        .listBuilder(header: .chart, onTap: { menu in
                            self.playSubject.onNext(.track(id: menu.id))
                        })
                case let .themeDetail(id):
                    return self.provider.themeDetail(id: id)
                        .listBuilder(header: .playlist) { menu in
                            self.playSubject.onNext(.track(id: menu.id))
                        }
                case let .cabinet(type):
                    switch type {
                    case .myList, .likeAlbum, .likeThemeList:
                        return self.provider.myList(id: type.id)
                            .listBuilder(header: .cabinet) { menu in
                                // play
                                // 한뎁스 더 들어갈 경우
                                self.menuBuilderSubject.onNext(.cabinet(type: .likeAudioList))
                            }
                    case .likeAudioList:
                        return self.provider.myList(id: type.id)
                            .listBuilder(header: .cabinet) { menu in
                                self.playSubject.onNext(.audio(id: menu.id))
                            }
                    case .likeMusicList:
                        return .empty()
                    }
                }
            }
        
        let play = playSubject
            .flatMap { action -> Observable<String> in
                switch action {
                case let .likeMusicList(id):
                    return .just("좋아요 한 곡 재생합니다 \(id)")
                case let .audio(id):
                    return .just("오디오 재생 \(id)")
                case let .track(id):
                    return .just("트랙 재생 \(id)")
                }
            }
        
        return Output(
            tabBarModel: tabBarModel,
            push: push,
            play: play
        )
    }
}

extension CarPlayTemplateModel {
    struct Action {
        enum Push {
            case playlist(type: CarplayPlaylistMenu)
            case chart(id: Int64)
            case themeDetail(id: Int64)
            case cabinet(type: CabinetMenu)
        }
        
        enum Play {
            case likeMusicList(id: Int64)
            case track(id: Int64)
            case audio(id: Int64)
        }
    }
}
