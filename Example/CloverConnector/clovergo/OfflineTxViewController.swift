//
//  OfflineTxViewController.swift
//  CloverConnector_Example
//
//  Created by Deshmukh, Harish (Non-Employee) on 12/20/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import GoConnector

let offlineNotificationKey = "com.connector.offline"


class OfflineTxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var statsTableView: UITableView?
    var offlinePaymentStatsArray: [NSAttributedString] = []
    let name = Notification.Name(rawValue: offlineNotificationKey)
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.tintColor = UIColor.darkGray
        let refreshTextAttributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)
            ] as [NSAttributedStringKey : Any]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Offline Transactions", attributes: refreshTextAttributes)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            statsTableView?.refreshControl = refreshControl
        } else {
            statsTableView?.addSubview(refreshControl)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(proceedAfterRetrievePendingPaymentInfo), name: name, object: nil)
        
        ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.retrievePendingPayments()
        ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.retrievePendingPaymentStats()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        refreshControl.endRefreshing()
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 1 {
            return 100
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return offlinePaymentStatsArray.count
        }
        else{
            return ((OFFLINETX.retrievePendingPaymentsResponseObj?.pendingPayments)?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return "Offline Stats"
        } else {
            return "Offline Transactions"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        if indexPath.section == 0
        {
            cell?.textLabel?.attributedText = offlinePaymentStatsArray[indexPath.row]
        }
        else
        {
            let goPendingPayments = OFFLINETX.retrievePendingPaymentsResponseObj?.pendingPayments as! [GoPendingPaymentEntry]
            
            let txAmount = goPendingPayments[indexPath.row].amount ?? 0
            let txAmountDollar: Double = CDouble(txAmount) / 100
            let formattedString = NSMutableAttributedString()
            formattedString.normal("Amount : ")
            formattedString.bold("$\(String(format: "%.2f", txAmountDollar))")
            cell?.textLabel?.attributedText = formattedString
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy, HH:mm:ss"
            let myString = dateFormatterGet.string(from: goPendingPayments[indexPath.row].createdTime)
            let date: Date? = dateFormatterGet.date(from: myString)
            
            var stateString = goPendingPayments[indexPath.row].state.toString()
            if stateString == "FAILED"
            {
                stateString += "; "
                stateString += goPendingPayments[indexPath.row].failureReason ?? ""
            }
            
            cell?.detailTextLabel?.textColor = UIColor.blue
            cell?.detailTextLabel?.numberOfLines = 4
            cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell?.detailTextLabel?.text = "Payment Id : \(goPendingPayments[indexPath.row].paymentId ?? "NA") \nCreated : \(dateFormatter.string(from: date!)) \nState : \(stateString)"
        }
        return cell!
    }
    
    @objc func proceedAfterRetrievePendingPaymentInfo() {
        
        let totalAmount = OFFLINETX.retrievePendingPaymentsStatsObj?.totalPaymentAmount ?? 0
        let totalAmountDollar: Double = CDouble(totalAmount) / 100
        
        offlinePaymentStatsArray.removeAll()
        var formattedString = NSMutableAttributedString()
        formattedString.normal("Total Payment Amount :  ")
        formattedString.bold("$\(String(format: "%.2f", totalAmountDollar))")
        offlinePaymentStatsArray.append(formattedString)
        formattedString = NSMutableAttributedString()
        formattedString.normal("No. of days Offline     :  ")
        formattedString.bold("\(String(OFFLINETX.retrievePendingPaymentsStatsObj?.noOfDaysOffline ?? 0))")
        offlinePaymentStatsArray.append(formattedString)
        formattedString = NSMutableAttributedString()
        formattedString.normal("Total Payment Count  :    ")
        formattedString.bold("\(String(OFFLINETX.retrievePendingPaymentsStatsObj?.totalPaymentCount ?? 0))")
        offlinePaymentStatsArray.append(formattedString)
        formattedString = NSMutableAttributedString()
        formattedString.normal("Pending Payment Count:  ")
        formattedString.bold("\(String(OFFLINETX.retrievePendingPaymentsStatsObj?.pendingPaymentCount ?? 0))")
        offlinePaymentStatsArray.append(formattedString)
        formattedString = NSMutableAttributedString()
        formattedString.normal("Failed Payment Count   :  ")
        formattedString.bold("\(String(OFFLINETX.retrievePendingPaymentsStatsObj?.failedPaymentCount ?? 0))")
        offlinePaymentStatsArray.append(formattedString)
        formattedString = NSMutableAttributedString()
        
        statsTableView?.reloadData()
    }
    
    @objc private func refresh(_ sender: Any)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(proceedAfterRetrievePendingPaymentInfo), name: name, object: nil)
        
        ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.retrievePendingPayments()
        ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.retrievePendingPaymentStats()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        let normalString = NSMutableAttributedString(string:text, attributes: attrs)
        append(normalString)
        return self
    }
}
