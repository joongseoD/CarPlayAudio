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
        return .just([
            CarPlayMenuModel(id: 0, title: "1위 곡")
        ])
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
            CarPlayMenuModel(id: 1, title: "오디오1")
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

    func testCreatingTabBarTemplateModels() {
        // given & when
        let output = sut.transform(input: .init(refresh: .just(())))
        var result: [CarPlayListModel] = []
        output.tabBarModel
            .subscribe(onNext: { result = $0 })
            .disposed(by: bag)
        
        // then
        scheduler.start()
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].header, .playlist)
        XCTAssertEqual(result[1].header, .chart)
        XCTAssertEqual(result[2].header, .theme)
        XCTAssertEqual(result[3].header, .cabinet)
        XCTAssertEqual(result[0].sections.count, 1)
        XCTAssertEqual(result[0].sections[0].items.count, 2)
        XCTAssertEqual(result[0].sections[0].items[1].text, "오디오 재생목록")
        XCTAssertEqual(result[2].sections[0].items[1].text, "힙합 리스트")
        scheduler.stop()
    }
    
    func testPushDetailWhenTappedPlaylistMenu() {
        // given
        let refresh = scheduler.createColdObservable([.next(0, ())])
        let output = sut.transform(input: .init(refresh: refresh.asObservable()))
        
        var musicPlaylistMenu: CarPlayListItemModel?
        var audioPlaylistMenu: CarPlayListItemModel?
        let expectation = scheduler.createObserver(CarPlayListModel.self)
        
        output.tabBarModel
            .subscribe(onNext: {
                musicPlaylistMenu = $0[0].sections[0].items[0]
                audioPlaylistMenu = $0[0].sections[0].items[1]
            })
            .disposed(by: bag)
        
        output.push
            .bind(to: expectation)
            .disposed(by: bag)
        
        // when
        scheduler.scheduleAt(10) { musicPlaylistMenu?.didTapItem?() }
        scheduler.scheduleAt(20) { audioPlaylistMenu?.didTapItem?() }
        
        // then
        scheduler.start()
        let results = expectation.events.compactMap { $0.value.element?.sections[0].items }
        let result1 = results[0]
        let result2 = results[1]
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(result1[0].text, "음악1")
        XCTAssertEqual(result1[1].text, "음악2")
        XCTAssertEqual(result2[0].text, "오디오1")
        XCTAssertEqual(result2[1].text, "오디오2")
        scheduler.stop()
    }
    
    func testPushDetailWhenTappedCabinetMenu() {
        // given
        let refresh = scheduler.createColdObservable([.next(0, ())])
        let output = sut.transform(input: .init(refresh: refresh.asObservable()))
        
        var myList: CarPlayListItemModel?
        var lieAudioList: CarPlayListItemModel?
        let expectation = scheduler.createObserver(CarPlayListModel.self)
        
        output.tabBarModel
            .subscribe(onNext: {
                myList = $0[3].sections[0].items[0]
                lieAudioList = $0[3].sections[0].items[2]
            })
            .disposed(by: bag)
        
        output.push
            .bind(to: expectation)
            .disposed(by: bag)
        
        // when
        scheduler.scheduleAt(10) { myList?.didTapItem?() }
        scheduler.scheduleAt(20) { lieAudioList?.didTapItem?() }
        
        // then
        scheduler.start()
        let results = expectation.events.compactMap { $0.value.element?.sections[0].items }
        let result1 = results[0]
        let result2 = results[1]
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(result1[0].text, "힙합1")
        XCTAssertEqual(result1[1].text, "힙합2")
        XCTAssertEqual(result1[2].text, "힙합3")
        XCTAssertEqual(result2[0].text, "오디오1")
        scheduler.stop()
    }
    
    func testPlayTrackWhenTappedChartItem() {
        // given
        let refresh = scheduler.createColdObservable([.next(0, ())])
        let output = sut.transform(input: .init(refresh: refresh.asObservable()))
        
        var chartMenu: CarPlayListItemModel?
        var chartTrackItem: CarPlayListItemModel?
        let expectation = scheduler.createObserver(String.self)
        
        output.tabBarModel
            .subscribe(onNext: { chartMenu = $0[1].sections[0].items[1] })
            .disposed(by: bag)
        
        output.push
            .subscribe(onNext: { chartTrackItem = $0.sections[0].items[0] })
            .disposed(by: bag)
        
        output.play
            .bind(to: expectation)
            .disposed(by: bag)
        
        // when
        scheduler.scheduleAt(10) { chartMenu?.didTapItem?() }
        scheduler.scheduleAt(20) { chartTrackItem?.didTapItem?() }
        
        // then
        scheduler.start()
        let result = expectation.events.compactMap { $0.value.element }.first
        XCTAssertEqual(chartTrackItem?.text, "1위 곡")
        XCTAssertEqual(result, "트랙 재생 \(chartTrackItem?.id ?? "")")
        scheduler.stop()
    }
}
