//
//  FilterLocationViewController.swift
//  WCEC
//
//  Created by GEM on 5/25/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol FilterLocationViewControllerDelegate: NSObjectProtocol {
    func didDoneChooseLocation(_ data: [rowModelLocation])
}

class FilterLocationViewController: BaseViewController {

    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FilterLocationViewControllerDelegate?
    let userService = UserService()
    let viewModel = FilterLocationViewModel()
    var dataSelected = [rowModelLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getCoutries()
    }
    
    override func setupLocalized() {
        btnDone.setTitle("Done".localized(), for: .normal)
        tfSearch.attributedPlaceholder = NSAttributedString(string: "Search".localized(),
                                                            attributes: [NSAttributedStringKey.foregroundColor: AppColor.colorTitleTextField()])
    }
    
    func setupUI() {
        self.viewModel.dataLocationSelected = dataSelected
        tfSearch.borderStyle = .none
        tfSearch.delegate = self
        tableView.register(UINib.init(nibName: ChildTagTableViewCell.classString(), bundle: nil), forCellReuseIdentifier: ChildTagTableViewCell.classString())
    }
    
    func getCoutries() {
        self.showHud()
        userService.doSearchCountry(searchText: tfSearch.text!) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.viewModel.parseData(response.data, dataSelected: self.viewModel.dataLocationSelected)
                self.tableView.reloadData()
                break
            case .failure( let error):
                self.alertWithError(error)
                break
            }
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didDoneChooseLocation(self.viewModel.dataLocationSelected)
        }
    }
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FilterLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfSearch.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        getCoutries()
    }
}

extension FilterLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataLocation.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChildTagTableViewCell.classString(), for: indexPath) as! ChildTagTableViewCell
        let item = self.viewModel.dataLocation[indexPath.row]
        cell.titleLabel.text = item.data.name
        cell.selected(item.isSelected)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelected(indexPath.row)
//        viewModel.dataLocation[indexPath.row].isSelected = !viewModel.dataLocation[indexPath.row].isSelected
        tableView.reloadData()
    }
}











