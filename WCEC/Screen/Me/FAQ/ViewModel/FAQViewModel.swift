//
//  FAQViewModel.swift
//  WCEC
//
//  Created by GEM on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class FAQViewModel: NSObject {
    var sections = [FAQSection]()
    
    func parseData(_ data: [FAQModel]) {
        sections.removeAll()
        data.forEach({
            let header = HeaderModel(title: $0.title, identifier: HeaderSectionFAQ.nibName())
            let row = FAQRowModel($0)
            sections.append(FAQSection(section: SectionModel(rows: [row], header: header)))
        })
    }
    
    func doUpdateData(_ data: [FAQModel]) {
        data.forEach({
            let header = HeaderModel(title: $0.title, identifier: HeaderSectionFAQ.nibName())
            let row = FAQRowModel($0)
            sections.append(FAQSection(section: SectionModel(rows: [row], header: header)))
        })
    }
    
    func didSelectSection(_ index: Int) {
        sections[index].isCollapse = !sections[index].isCollapse
    }
}

class FAQSection: NSObject {
    var section: SectionModel
    var isCollapse = true
    
    init(section: SectionModel) {
        self.section = section
    }
}
