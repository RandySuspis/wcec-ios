//
//  FilterViewModel.swift
//  WCEC
//
//  Created by GEM on 5/16/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class FilterViewModel: NSObject {
    var sections = [SectionModel]()
    var listIndustriesSelected = [SubCategoryModel]()
    var listInterestsSelected = [SubCategoryModel]()
    var listLocationSelected = [rowModelLocation]()
    
    override init() {
        let headerLocation = HeaderModel(title: "Locations".localized(),
                                           identifier: FilterHeader.nibName())
        let rowsLocation = [FilterRowModel]()
        let locationSection = SectionModel(rows: rowsLocation, header: headerLocation)
        sections.append(locationSection)
        
        let industriesLocation = HeaderModel(title: "Industries".localized(),
                                         identifier: FilterHeader.nibName())
        let rowsIndustrie = [FilterRowModel]()
        let industriesSection = SectionModel(rows: rowsIndustrie, header: industriesLocation)
        sections.append(industriesSection)
        
        let interestsLocation = HeaderModel(title: "Interests".localized(),
                                         identifier: FilterHeader.nibName())
        let rowsInterests = [FilterRowModel]()
        let interestsSection = SectionModel(rows: rowsInterests, header: interestsLocation)
        sections.append(interestsSection)
    }
    
    func doUpdateLocation(_ data: [rowModelLocation]) {
        self.listLocationSelected = data
        guard sections.count == 3 else {
            return
        }
        sections[0].rows.removeAll()
        for item in data {
            sections[0].rows.append(FilterRowModel(item))
        }
    }
    
    func doUpdateIndustrie(_ listIndustriesSelected: [SubCategoryModel]) {
        self.listIndustriesSelected = listIndustriesSelected
        guard sections.count == 3 else {
            return
        }
        sections[1].rows.removeAll()
        for item in listIndustriesSelected {
            sections[1].rows.append(FilterRowModel(item))
        }
    }
    
    func doUpdateInterests(_ data: [SubCategoryModel]) {
        self.listInterestsSelected = data
        guard sections.count == 3 else {
            return
        }
        sections[2].rows.removeAll()
        for item in data {
            sections[2].rows.append(FilterRowModel(item))
        }
    }
    
    func didDeleteItemRow(section: Int, row: Int) {
        if sections.count >= section {
            sections[section].rows.remove(at: row)
        }
        switch section {
        case 0:
            self.listLocationSelected.remove(at: row)
            break
        case 1:
            self.listIndustriesSelected.remove(at: row)
            break
        case 2:
            self.listInterestsSelected.remove(at: row)
            break
        default:
            break
        }
    }
}









