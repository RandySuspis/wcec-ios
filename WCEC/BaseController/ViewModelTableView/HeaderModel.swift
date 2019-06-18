//
//  HeaderModel
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
struct HeaderModel: PBaseHeaderModel {
    var title: String
    var identifier: String?
    init(title: String = "", identifier: String? = nil) {
        self.title = title
        self.identifier = identifier
    }
}

