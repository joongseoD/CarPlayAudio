//
//  CarPlayV2Tests.swift
//  CarPlayV2Tests
//
//  Created by Damor on 2022/06/01.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import CarPlayV2

class TestProvider: CarPlayProviding {
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
    
    func likeMusicIds() -> Observable<[String]> {
        return .just(["1", "2", "3"])
    }
    
    func likeAudios() -> Observable<[CarPlayMenu]> {
        return .just([
            CarPlayMenuModel(id: 1, title: "힙합1"),
            CarPlayMenuModel(id: 1, title: "힙합2"),
            CarPlayMenuModel(id: 1, title: "힙합3"),
        ])
    }
    
    func likeAlbums() -> Observable<[CarPlayMenu]> {
        return .just([
            CarPlayMenuModel(id: 1, title: "힙합1"),
            CarPlayMenuModel(id: 1, title: "힙합2"),
            CarPlayMenuModel(id: 1, title: "힙합3"),
        ])
    }
    
    func likeThemeList() -> Observable<[CarPlayMenu]>{
        return .just([
            CarPlayMenuModel(id: 1, title: "힙합1"),
            CarPlayMenuModel(id: 1, title: "힙합2"),
            CarPlayMenuModel(id: 1, title: "힙합3"),
        ])
    }
}

class TestDependency: CarPlayTemplateModelDependency {
    var provider: CarPlayProviding
    var mainScheduler: SchedulerType
    var maximumTabCount: Int
    var maximumItemCount: Int
    var maximumSectionCount: Int
    
    init(
        provider: CarPlayProviding,
        mainScheduler: SchedulerType,
        maximumTabCount: Int,
        maximumItemCount: Int,
        maximumSectionCount: Int
    ) {
        self.provider = provider
        self.mainScheduler = mainScheduler
        self.maximumTabCount = maximumTabCount
        self.maximumItemCount = maximumItemCount
        self.maximumSectionCount = maximumSectionCount
    }
}

class CarPlayV2Tests: XCTestCase {
    var sut: CarPlayTemplateModel!
    var dependency: TestDependency!
    var provider: TestProvider!
    var bag: DisposeBag!
    var scheduler: TestScheduler!
    
    override func setUpWithError() throws {
        provider = TestProvider()
        scheduler = TestScheduler(initialClock: .zero)
        dependency = TestDependency(
            provider: TestProvider(),
            mainScheduler: scheduler,
            maximumTabCount: 3,
            maximumItemCount: 10,
            maximumSectionCount: 10
        )
        sut = CarPlayTemplateModel(dependency: dependency)
        bag = DisposeBag()
    }

    override func tearDownWithError() throws {
        sut = nil
        provider = nil
    }

    func testTabBarList() {
        // given
        
        // when
        let output = sut.transform(input: .init(refresh: .just(())))
        let result = scheduler.createObserver([CarPlayListModel].self)
        output.tabBarModel
            .debug()
            .bind(to: result)
            .disposed(by: bag)
        
        // then
    }
}
