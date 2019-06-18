//
//  ConnectionsViewModel.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ConnectionsViewModel: NSObject {
    var sections = [SectionModel]()
    var totalRequestModel: TotalRequestModel?
    
    override init() {
        sections = []
        totalRequestModel = nil
    }
    
    func totalConected() -> String {
        guard let model = totalRequestModel else {
            return "-"
        }
        return model.connected == 0 ? "-" : String(model.connected)
    }
    
    func totalReceived() -> String {
        guard let model = totalRequestModel else {
            return "-"
        }
        return model.received == 0 ? "-" : String(model.received)
    }
    
    func totalRequest() -> String {
        guard let model = totalRequestModel else {
            return "-"
        }
        return (model.received + model.sent) == 0 ? "-" : String(model.received + model.sent)
    }
    
    func parseRequest(_ data: [RequestModel]) {
        sections.removeAll()
        let headerRequest = HeaderModel(title: "You have ".localized() +
            String(self.totalReceived()) +
            (self.totalReceived() == "1" ? " request".localized() :  " requests".localized()),
                                        identifier: HeaderSectionsConnections.nibName())
        var rows = [ConnectionsRowModel]()
        for item in data {
            rows.append(ConnectionsRowModel(item, type: .normal))
        }
        let requestSection = SectionModel(rows: rows, header: headerRequest)
        sections.append(requestSection)
    }
    
    func parseSuggesstion(_ data: [UserModel]) {
        let headerSuggestion = HeaderModel(title: "We found some suggestions for you".localized(),
                                           identifier: HeaderSectionsConnections.nibName())
        var rows = [ConnectionsRowModel]()
        for item in data {
            rows.append(ConnectionsRowModel(item, type: .normal))
        }
        let suggestionSection = SectionModel(rows: rows, header: headerSuggestion)
        sections.append(suggestionSection)
    }
    
    func doUpdateSuggesstion(_ data: [UserModel]) {
        for item in data {
            let rowModel = (ConnectionsRowModel(item, type: .normal))
            if sections.count == 2 {
                sections[1].rows.append(rowModel)
            }
        }
    }
    
}






