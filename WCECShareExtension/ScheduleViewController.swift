//
//  ScheduleViewController.swift
//  Social Manager
//
//  Created by Tomasz Baranowicz on 05/03/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit

protocol DateSelector {
    func selectorSelectedDate(date: Date)
}
@objc (ScheduleViewController)
class ScheduleViewController: UIViewController {

    var selectedDate: Date?
    var dateSelector : DateSelector?
    var datepicker : UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logout = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ScheduleViewController.done))
        self.navigationItem.setRightBarButton(logout, animated: true)
        
        self.navigationItem.hidesBackButton = true
        
//        self.title = "Schedule Post"
        
        self.view.backgroundColor = UIColor.white
        datepicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 220));
        datepicker!.datePickerMode = UIDatePickerMode.dateAndTime;
        datepicker!.minimumDate = Date()
        self.view.addSubview(datepicker!);
        
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.selectedDate != nil {
            datepicker?.date = self.selectedDate! as Date
        }
    }
    
    @objc func done() {
        
        if let sel = dateSelector {
            sel.selectorSelectedDate(date: self.datepicker!.date)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
