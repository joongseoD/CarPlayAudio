//
//  Array+extensions.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation
import CarPlay

extension Array {
    func mapToListTemplate() -> [CPListTemplate] where Element == CarPlayListModel {
        map { item -> CPListTemplate in
            return CPListTemplate(
                title: item.header.title,
                sections: item.sections.mapToListSection()
            )
        }
    }
    
    func mapToListSection() -> [CPListSection] where Element == CarPlayListSectionModel {
        map { section -> CPListSection in
            return CPListSection(
                items: section.items.mapToListItem(),
                header: section.title,
                sectionIndexTitle: section.indexTitle
            )
        }
    }
    
    func mapToListItem() -> [CPListItem] where Element == CarPlayListItemModel {
        map { model -> CPListItem in
            let item = CPListItem(
                text: model.text,
                detailText: model.detailText,
                image: model.image
            )
            item.handler = { _, completion in
                completion()
            }
            return item
        }
    }
}
