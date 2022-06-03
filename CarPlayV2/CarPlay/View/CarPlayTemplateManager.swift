//
//  CarPlayTemplateManager.swift
//  CarPlayV2
//
//  Created by Damor on 2022/05/31.
//

import Foundation
import CarPlay
import MediaPlayer
import RxSwift
import RxCocoa

typealias ConfigureListItem = ((_ section: inout CarPlayListSectionModel, _ item: CarPlayListItemModel) -> CPListItem)

@available(iOS 14.0, *)
final class CarPlayTemplateManager: NSObject {
    private let model: CarPlayTemplateModel
    private var bag = DisposeBag()
    private var rootTemplate = CPTabBarTemplate(templates: [])
    private weak var interfaceController: CPInterfaceController?
    
    /// The observer of the Now Playing item changes.
    var nowPlayingItemObserver: NSObjectProtocol?
    
    /// The observer of the playback state changes.
    var playbackObserver: NSObjectProtocol?
    
    private lazy var configureListItem: ConfigureListItem = {
        return { section, itemModel in
            let item = CPListItem(
                text: itemModel.text,
                detailText: itemModel.detailText,
                image: itemModel.image
            )
            item.setImage(url: itemModel.imageUrl)
            item.handler = { [weak self] _, completion in
                itemModel.didTapItem?()
                completion()
            }
            return item
        }
    }()
    
    init(model: CarPlayTemplateModel) {
        self.model = model
        super.init()
        
        printDebug()
    }
    
    private func printDebug() {
        // TODO: - Paging 처리 필요
        print("# maximumSectionCount", CPListTemplate.maximumSectionCount)
        print("# maximumItemCount", CPListTemplate.maximumItemCount)
        print("# maximumTabCount", CPTabBarTemplate.maximumTabCount)
    }
    
    func connect(_ interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        self.interfaceController?.delegate = self

        setupTemplate()
        addObservers()
        bind()
    }
    
    private func setupTemplate() {
        interfaceController?.setRootTemplate(rootTemplate, animated: true, completion: nil)
    }
    
    private func addObservers() {
        CPNowPlayingTemplate.shared.add(self)
        playbackObserver = NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil,
            queue: .main
        ) { notification in
            print("## Playback state changed", notification)
        }
        
        nowPlayingItemObserver = NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil,
            queue: .main
        ) { notification in
            print("## NowPlayingItem changed", notification)
        }
    }
    
    private func bind() {
        let output = model.transform(
            input: .init(
                refresh: .just(())
            )
        )
        
        output.tabBarModel
            .bind(to: rootTemplate, configure: configureListItem)
            .disposed(by: bag)
        
        output.push
            .mapToListTemplate(configure: configureListItem)
            .subscribe(onNext: { [weak self] templateToPush in
                self?.interfaceController?.pushTemplate(templateToPush, animated: true, completion: nil)
            })
            .disposed(by: bag)
        
        output.play
            .subscribe(onNext: { _ in
                // 재생 후 UI 처리
            })
            .disposed(by: bag)
    }
    
    func disconnect() {
        nowPlayingItemObserver = nil
        playbackObserver = nil
        MPMusicPlayerController.applicationQueuePlayer.pause()
    }
}

extension CarPlayTemplateManager: CPInterfaceControllerDelegate {
    func templateWillAppear(_ aTemplate: CPTemplate, animated: Bool) {
        print("\(aTemplate) wiilAppear")
    }
    
    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        print("\(aTemplate) didAppear")
    }
    
    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        print("\(aTemplate) templateWillDisappear")
    }
    
    func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        print("\(aTemplate) templateDidDisappear")
    }
}

extension CarPlayTemplateManager: CPNowPlayingTemplateObserver {
    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
//        The user has selected the Up Next button on the now playing template. Your application
//        should push a new template displaying the list of upcoming or queued content.
    }
    
    func nowPlayingTemplateAlbumArtistButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
//        let _ = MPMusicPlayerController.applicationQueuePlayer.nowPlayingItem?.albumArtist
//        The user has selected the album/artist button on the now playing template. Your application
//        should push a new template displaying the content appearing in this container (album, playlist, or show).
    }
}
