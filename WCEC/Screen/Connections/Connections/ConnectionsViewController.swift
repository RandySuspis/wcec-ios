//
//  ConnectionsViewController.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ConnectionsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel = ConnectionsViewModel()
    let connectionsService = ConnectionsService()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }

    func setupUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.customBarItem(image: "search",
                                                                               target: self,
                                                                               btnAction: #selector(btnSearchAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.customBarItem(image: "activeWhite",
                                                                              target: self,
                                                                              btnAction: #selector(btnPlusAction))
        self.title = "Connections".localized()
        
        tableView.register(UINib(nibName: ConnectionsTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ConnectionsTableViewCell.nibName())
        tableView.register(UINib(nibName: HeaderSectionsConnections.nibName(), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: HeaderSectionsConnections.nibName())
    }
    
    func getData() {
        self.showHud()
        connectionsService.getListRequests { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseRequest(response.data)
                self.getDataSuggesstion()
            case .failure( let error):
                self.getDataSuggesstion()
                print(error.localizedDescription)
            }
        }
    }
    
    func getDataSuggesstion() {
        connectionsService.getListSuggestions { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseSuggesstion(response.data)
                self.hideHude()
                self.tableView.reloadData()
            case .failure( let error):
                print(error.localizedDescription)
                self.hideHude()
            }
        }
    }
    
    @objc func btnSearchAction() {
        
    }
    
    @objc func btnPlusAction() {
        
    }
    
    @IBAction func btnConnectedAction(_ sender: Any) {
        let conectedVC = ConnectedViewController()
        self.navigationController?.pushViewController(conectedVC, animated: true)
    }
    
    @IBAction func btnRequestsAction(_ sender: Any) {
    }
    
}

extension ConnectionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! BaseTableViewCell
        cell.bindingWithModel(rowModel)
        if let cell = cell as? ConnectionsTableViewCell {
            cell.delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = AppColor.colorPinkLow()
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}

extension ConnectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionModel = viewModel.sections[indexPath.section]
        self.tableView.deselectRow(at: indexPath, animated: true)
        let detail = ProfileDetailViewController()
        detail.userId = sectionModel.rows[indexPath.row].objectID
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionModel = viewModel.sections[section]
        if sectionModel.header.identifier != nil && !sectionModel.rows.isEmpty {
            return 72
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionModel = viewModel.sections[section]
        if sectionModel.header.identifier != nil && !sectionModel.rows.isEmpty {
            if sectionModel.header.title == "requestConnections" {
                let view = HeaderSectionsConnections.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: HeaderSectionsConnections.nibName())
                view.titleLabel?.text = "You have 4 requests"
                return view
            } else if sectionModel.header.title == "suggestionConnections" {
                let view = HeaderSectionsConnections.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: HeaderSectionsConnections.nibName())
                view.titleLabel?.text = "We found some suggestions for you"
                view.imgHeader.isHidden = true
                return view
            }
        }
        return nil
    }
    
}

extension ConnectionsViewController: ConnectionsTableViewCellDelegate {
    func connectionsTableViewCell(_ cell: ConnectionsTableViewCell, didSelectActionButton sender: UIButton) {
        if let titleBtn = sender.titleLabel?.text {
            if titleBtn == "Add" {
                let popupRequest = PopupSendRequest.init()
                if let rowModel = cell.rowModel as? ConnectionsRowModel {
                    popupRequest.receiverId = (cell.rowModel?.objectID)!
                    popupRequest.connectionRowModel = rowModel
                    Constants.appDelegate.tabbarController.present(popupRequest, animated: true, completion: nil)
                }
            }
        }
    }
}


















