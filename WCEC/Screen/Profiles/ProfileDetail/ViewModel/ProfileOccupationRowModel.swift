//
//  ProfileOccupationRowModel.swift
//  WCEC
//
//  Created by GEM on 6/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

class ProfileOccupationRowModel: PBaseRowModel {
    var objectID: String
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var note: String
    var time: String
    
    init(_ data: OccupationModel, identifier: String) {
        self.objectID = String(data.id)
        self.title = data.job_title
        self.desc = data.company_name
        self.image = ""
        self.identifier = identifier
        self.note = ""
        self.time = "\(data.begin_date) - \(data.end_date == "" ? "Present".localized() : data.end_date)"
    }
}
