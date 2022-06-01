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
    private weak var controller: CPInterfaceController?
    
    private lazy var configureListItem: ConfigureListItem = {
        return { section, itemModel in
            print("## configure")
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
            section.control?.headerButtonHandler = {
                print("## ", $0)
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
        self.controller = interfaceController

        interfaceController.setRootTemplate(rootTemplate, animated: true, completion: nil)
        
        bind()
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
                self?.controller?.pushTemplate(templateToPush, animated: true, completion: nil)
            })
            .disposed(by: bag)
        
        output.play
            .subscribe(onNext: {
                print("## ", $0)
            })
            .disposed(by: bag)
    }
}
