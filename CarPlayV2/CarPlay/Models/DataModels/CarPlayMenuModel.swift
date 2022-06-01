//
//  CarPlayMenuModel.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation

struct CarPlayMenuModel: CarPlayMenu {
    var id: Int64
    var title: String
    var subtitle: String?
    var imageUrl: String?
    var imageName: String?
}
