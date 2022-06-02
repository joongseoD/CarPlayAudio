//
//  Publisher+extensions.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation
import Combine
import CarPlay
import RxSwift
import RxCocoa

extension ObservableType where Element == [CarPlayListModel] {
    func bind(to tabBarTemplate: CPTabBarTemplate, configure: @escaping ConfigureListItem) -> Disposable {
        map { listModel -> [CPListTemplate] in
            return listModel.map { listModel -> CPListTemplate in
                return listModel.mapToListTemplate(configure: configure)
            }
        }
        .subscribe(onNext: { listTemplates in
            tabBarTemplate.updateTemplates(listTemplates)
            
        })
    }
}

extension ObservableType where Element == CarPlayListModel {
    func mapToListTemplate(configure: @escaping ConfigureListItem) -> Observable<CPListTemplate> {
        return map { listModel -> CPListTemplate in
            return listModel.mapToListTemplate(configure: configure)
        }
    }
}

extension ObservableType where Element == [CarPlayMenu] {
    func sectionBuilder(onTap handler: ((_ menu: CarPlayMenu) -> Void)?) -> Observable<CarPlayListSectionModel> {
        return map { menu in
            CarPlayListSectionModel(
                items: menu.map { menu in
                    CarPlayListItemModel(
                        id: "\(menu.id)",
                        text: menu.title,
                        detailText: nil,
                        image: nil,
                        imageUrl: nil,
                        didTapItem: { handler?(menu) }
                    )
                }
            )
        }
    }
    
    func listBuilder(header: CarPlayListModel.Header, onTap handler: ((_ model: CarPlayMenu) -> Void)?) -> Observable<CarPlayListModel> {
        return sectionBuilder(onTap: handler)
            .map { CarPlayListModel(header: header, sections: [$0]) }
    }
}

fileprivate extension CarPlayListModel {
    func mapToListTemplate(configure: @escaping ConfigureListItem) -> CPListTemplate {
        let sections = sections.map { section -> CPListSection in
            var section = section
            let items = section.items.map { item in
                configure(&section, item)
            }
            
            if #available(iOS 15.0, *), let control = section.control {
                return CPListSection(
                    items: items,
                    header: section.title ?? "",
                    headerSubtitle: control.subtitle,
                    headerImage: UIImage(systemName: control.headerImageName),
                    headerButton: CPButton(
                        image: UIImage(systemName: control.headerButtonImageName)!,
                        handler: control.headerButtonHandler
                    ),
                    sectionIndexTitle: section.indexTitle
                )
            } else {
                return CPListSection(
                    items: items,
                    header: section.title,
                    sectionIndexTitle: section.indexTitle
                )
            }
        }
        
        let listTemplate = CPListTemplate(
            title: header.title,
            sections: sections
        )
        listTemplate.tabTitle = header.title
        listTemplate.tabImage = UIImage(systemName: header.titleImageName)

        return listTemplate
    }
}
