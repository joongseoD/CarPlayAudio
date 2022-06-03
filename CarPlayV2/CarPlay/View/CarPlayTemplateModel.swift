//
//  CarPlayTemplateModel.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import UIKit
import RxSwift
import RxCocoa

protocol CarPlayTemplateModelDependency {
    var provider: CarPlayProviding { get }
    var mainScheduler: SchedulerType { get }
    var maximumTabCount: Int { get }
    var maximumItemCount: Int { get }
    var maximumSectionCount: Int { get }
}

final class CarPlayTemplateModel {
    private let action = PublishSubject<Action>()
    private let provider: CarPlayProviding
    private let mainScheduler: SchedulerType
    
    // TODO: - List Paging
    // TODO: - Tab count 5이하만 가능한 경우 어떻게 할지
    private let maximumTabCount: Int
    private let maximumItemCount: Int
    private let maximumSectionCount: Int
    
    init(dependency: CarPlayTemplateModelDependency) {
        self.provider = dependency.provider
        self.mainScheduler = dependency.mainScheduler
        self.maximumTabCount = dependency.maximumTabCount
        self.maximumItemCount = dependency.maximumItemCount
        self.maximumSectionCount = dependency.maximumSectionCount
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
            .flatMap { [weak self] _ -> Observable<[CarPlayMenu]> in
                guard let self = self else { return .empty() }
                return self.request(scene: .playlistMenu)
            }
            .listBuilder(header: .playlist, onTap: { [weak self] model in
                guard let type = model as? CarplayPlaylistMenu else { return }
                self?.action.onNext(.push(.playList(type: type)))
            })
            
        let chartMenu = input.refresh
            .flatMap { [weak self] _ -> Observable<[CarPlayMenu]> in
                guard let self = self else { return .empty() }
                return self.request(scene: .chartMenu)
            }
            .listBuilder(header: .chart, onTap: { [weak self] model in
                self?.action.onNext(.push(.chart(id: model.id)))
            })
        
        let themeMenu = input.refresh
            .flatMap { [weak self] _ -> Observable<[CarPlayMenu]> in
                guard let self = self else { return .empty() }
                return self.request(scene: .themeList)
            }
            .listBuilder(header: .theme) { [weak self] model in
                self?.action.onNext(.push(.themeDetail(id: model.id)))
            }
        
        let driveMenu = input.refresh
            .flatMap { [weak self] _ -> Observable<[CarPlayMenu]> in
                guard let self = self else { return .empty() }
                return self.request(scene: .driveThemeList)
            }
            .listBuilder(header: .theme) { [weak self] model in
                self?.action.onNext(.push(.driveDetail(id: model.id)))
            }
        
        let cabinetMenu = input.refresh
            .flatMap { [weak self] _ -> Observable<[CarPlayMenu]> in
                guard let self = self else { return .empty() }
                return self.request(scene: .cabinetMenu)
            }
            .listBuilder(header: .cabinet) { [weak self] model in
                guard let type = model as? CabinetMenu else { return }
                switch type {
                case .myList:
                    self?.action.onNext(.push(.myList(id: model.id)))
                case .likeMusicList:
                    self?.action.onNext(.play(.likeMusicList(id: model.id)))
                case .likeAudioList:
                    self?.action.onNext(.push(.myList(id: model.id)))
                case .likeAlbum:
                    self?.action.onNext(.push(.myList(id: model.id)))
                case .likeThemeList:
                    self?.action.onNext(.push(.myList(id: model.id)))
                }
            }
            
        let tabBarModel = Observable.combineLatest(
            playList,
            chartMenu,
            themeMenu,
//            driveMenu,
            cabinetMenu,
            resultSelector: { [$0, $1, $2, $3] }
        )
            .observe(on: mainScheduler)
        
        let push = action
            .compactMap { action -> Action.CarPlayScene? in
                guard case let .push(scene) = action else { return nil }
                return scene
            }
            .flatMap { [weak self] scene -> Observable<CarPlayListModel> in
                guard let self = self else { return .empty() }
                let model = self.request(scene: scene)
                switch scene {
                case .playList:
                    return model
                        .listBuilder(header: .playlist) { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        }
                case .chart:
                    return model
                        .listBuilder(header: .chart, onTap: { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        })
                case .themeDetail:
                    return model
                        .listBuilder(header: .playlist) { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        }
                case .driveDetail:
                    return model
                        .listBuilder(header: .pop) { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        }
                case .myList:
                    return model
                        .listBuilder(header: .cabinet) { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        }
                case .likeAudios:
                    return model
                        .listBuilder(header: .cabinet) { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        }
                case .likeAlbums:
                    return model
                        .listBuilder(header: .cabinet) { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        }
                case .likeThemeList:
                    return model
                        .listBuilder(header: .cabinet) { model in
                            self.action.onNext(.play(.track(id: model.id)))
                        }
                default:
                    return .empty()
                }
            }
            .observe(on: mainScheduler)
        
        let play = action
            .compactMap { action -> Action.CarPlayTrack? in
                guard case let .play(track) = action else { return nil }
                return track
            }
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
            .observe(on: mainScheduler)

        return Output(
            tabBarModel: tabBarModel,
            push: push,
            play: play
        )
    }
    
    private func request(scene: Action.CarPlayScene) -> Observable<[CarPlayMenu]> {
        switch scene {
        case .playlistMenu:
            return provider.playListMenu
        case .chartMenu:
            return provider.chartMenu
        case .themeList:
            return provider.themeList()
        case .driveThemeList:
            return provider.driveThemeList()
        case .driveDetail(let id):
            return provider.driveDetail(id: id)
        case .cabinetMenu:
            return provider.cabinetMenu
        case .playList(let type):
            return provider.playlist(type: type)
        case .chart(let id):
            return provider.chart(id: id)
        case .themeDetail(let id):
            return provider.themeDetail(id: id)
        case .myList(let id):
            return provider.myList(id: id)
        case .likeAudios:
            return provider.likeAudios()
        case .likeAlbums:
            return provider.likeAlbums()
        case .likeThemeList:
            return provider.likeThemeList()
        }
    }
}

extension CarPlayTemplateModel {
    enum Action {
        case push(CarPlayScene)
        case play(CarPlayTrack)
        
        enum CarPlayScene {
            case playlistMenu
            case chartMenu
            case themeList
            case driveThemeList
            case cabinetMenu
            case playList(type: CarplayPlaylistMenu)
            case chart(id: Int64)
            case themeDetail(id: Int64)
            case driveDetail(id: Int64)
            case myList(id: Int64)
            case likeAudios
            case likeAlbums
            case likeThemeList
            
            static var rootMenu: [CarPlayScene] {
                return [.playlistMenu, chartMenu, themeList, cabinetMenu]
            }
        }

        enum CarPlayTrack {
            case likeMusicList(id: Int64)
            case track(id: Int64)
            case audio(id: Int64)
        }
    }
}
