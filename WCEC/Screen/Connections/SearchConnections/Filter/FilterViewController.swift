//
//  FilterViewController.swift
//  WCEC
//
//  Created by GEM on 5/16/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate: NSObjectProtocol {
    func didApplyFilter(listIndustriesSelected: [SubCategoryModel],
                        listInterestsSelected: [SubCategoryModel],
                        listLocationSelected: [rowModelLocation])
}

class FilterViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel =  FilterViewModel()
    weak var delegate: FilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupUI() {
        self.view.backgroundColor = AppColor.colorCellBgBlack()
        tableView.register(UINib(nibName: FilterTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: FilterTableViewCell.nibName())
        tableView.register(UINib(nibName: FilterHeader.nibName(),bundle: nil),
                           forHeaderFooterViewReuseIdentifier: FilterHeader.nibName())
    }
    
    override func setupLocalized() {
        self.btnApply.setTitle("Apply Filters".localized(), for: .normal)
        self.btnClear.setTitle("Clear All".localized(), for: .normal)
        self.navigationItem.title = "Filter".localized()
        self.titleLabel.text = "Filter".localized()
    }
    
    @IBAction func onApply(_ sender: Any) {
        delegate?.didApplyFilter(listIndustriesSelected: self.viewModel.listIndustriesSelected,
                                 listInterestsSelected: self.viewModel.listInterestsSelected,
                                 listLocationSelected: self.viewModel.listLocationSelected)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClear(_ sender: Any) {
        viewModel =  FilterViewModel()
        tableView.reloadData()
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FilterViewController: UITableViewDataSource {
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
        cell.selectionStyle = .none
        cell.bindingWithModel(rowModel)
        if let cell = cell as? FilterTableViewCell {
            cell.delegate = self
        }
        return cell
    }
    
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = FilterHeader.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: FilterHeader.nibName())
        view.bindingWithModel(viewModel.sections[section].header, section: section)
        view.delegate = self
        return view
    }
    
}

extension FilterViewController: FilterHeaderDelegate {
    func filterHeader(index: Int) {
        switch index {
        case 0:
            let vc = FilterLocationViewController()
            vc.dataSelected = viewModel.listLocationSelected
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
            break;
        case 1:
            let vc = MyIndustryViewController()
            vc.isFromSearch = true
            vc.delegate = self
            if viewModel.listIndustriesSelected.count > 0 {
                vc.searchCategoriesSelected = self.viewModel.listIndustriesSelected
            }
            self.present(vc, animated: true, completion: nil)
        case 2:
            let vc = MyInterestsViewController()
            vc.isFromSearch = true
            vc.delegate = self
            if viewModel.listInterestsSelected.count > 0 {
                vc.searchCategoriesSelected = self.viewModel.listInterestsSelected
            }
            self.present(vc, animated: true, completion: nil)
            break;
        default:
            break;
        }
    }
}

extension FilterViewController: FilterTableViewCellDelegate {
    func didDelete(_ cell: FilterTableViewCell, didSelectActionButton sender: UIButton) {
        if let indexPath = tableView?.indexPath(for: cell) {
            self.viewModel.didDeleteItemRow(section: indexPath.section, row: indexPath.row)
            self.tableView.reloadData()
        }
    }
}

extension FilterViewController: MyIndustryDelegate {
    func didDoneChoseIndutry(listIndustriesSelected: [SubCategoryModel]) {
        viewModel.doUpdateIndustrie(listIndustriesSelected)
        tableView.reloadData()
    }
}

extension FilterViewController: MyInterestsDelegate {
    func didDoneChoseInterests(listInterestSelected: [SubCategoryModel]) {
        viewModel.doUpdateInterests(listInterestSelected)
        tableView.reloadData()
    }
}

extension FilterViewController: FilterLocationViewControllerDelegate {
    func didDoneChooseLocation(_ data: [rowModelLocation]) {
        viewModel.doUpdateLocation(data)
        tableView.reloadData()
    }
}










