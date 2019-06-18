//
//  SimpleTableViewModel.swift
//  MyClip
//
//  Created by Huy Nguyen on 6/13/17.
//  Copyright © 2017 Huy Nguyen. All rights reserved.
//

import Foundation

protocol SimpleTableViewModelProtocol {
    var data: [PBaseRowModel] {set get}
}

struct SimpleTableViewModel: SimpleTableViewModelProtocol {
    var data: [PBaseRowModel]
    init() {
        data = [PBaseRowModel]()
    }
}

