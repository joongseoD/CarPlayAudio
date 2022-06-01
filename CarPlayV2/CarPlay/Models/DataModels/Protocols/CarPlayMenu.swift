//
//  CarPlayMenu.swift
//  CarPlayV2
//
//  Created by Damor on 2022/06/01.
//

import Foundation

protocol CarPlayMenu {
    var id: Int64 { get }
    
    var title: String { get }
    
    var subtitle: String? { get }
    
    var imageUrl: String? { get }
    
    var imageName: String? { get }
}

extension CarPlayMenu {
    var subtitle: String? { nil }
    
    var imageUrl: String? { nil }
    
    var imageName: String? { nil }
}
