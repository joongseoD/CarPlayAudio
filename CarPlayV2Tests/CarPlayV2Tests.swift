//
//  CarPlayV2Tests.swift
//  CarPlayV2Tests
//
//  Created by Damor on 2022/06/01.
//

import XCTest
import RxSwift
@testable import CarPlayV2

class TestProvider: CarPlayProviding {
    var playListMenu: Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    func playlist(type: CarplayPlaylistMenu) -> Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    var chartMenu: Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    func chart(id: Int64) -> Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    func themeList() -> Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    func themeDetail(id: Int64) -> Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    func driveThemeList() -> Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    func driveDetail(id: Int64) -> Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    var cabinetMenu: Observable<[CarPlayMenu]> {
        return .empty()
    }
    
    func myList(id: Int64) -> Observable<[CarPlayMenu]> {
        return .empty()
    }
}

class CarPlayV2Tests: XCTestCase {

    var sut: CarPlayTemplateModel!
    var provider: TestProvider!
    
    override func setUpWithError() throws {
        provider = TestProvider()
        sut = CarPlayTemplateModel(
            provider: provider,
            mainScheduler: MainScheduler.instance
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let output = sut.transform(input: .init(refresh: .just(())))
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
