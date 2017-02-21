//
//  ViewController.swift
//  SharingTutorial Swift
//
//  Created by KyuJin Kim on 2017. 2. 17..
//  Copyright © 2017년 KyuJin Kim. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var check = Array(arrayLiteral: false, false, false, false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        if selectedCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
            selectedCell?.accessoryType = .none
            
            if indexPath.section == 0 {
                check[indexPath.row] = false
            }
        }
        else {
            selectedCell?.accessoryType = .checkmark
            
            if indexPath.section == 0 {
                check[indexPath.row] = true
            }
        }
    }
    
    func sharingItems() -> Array<Any>? {
        var datas = Array<Any>(arrayLiteral:"TEXT", URL(string: "http://www.naver.com")!)
        
        if let imagePath = Bundle.main.path(forResource: "mercury_450_ko", ofType: "jpg") {
            datas.append(URL(fileURLWithPath: imagePath))
        }
        
        if let videoPath = Bundle.main.path(forResource: "mp4sample", ofType: "mp4") {
            datas.append(URL(fileURLWithPath: videoPath))
        }
        
        var items = Array<Any>()
        
        for i in 0..<datas.count {
            if check[i] {
                items.append(datas[i])
            }
        }

        return items.count > 0 ? items : nil
    }
    
    func excludedActivities() -> Array<UIActivityType>? {
        let shares = Dictionary(dictionaryLiteral: ("Facebook", UIActivityType.postToFacebook), ("Twitter", UIActivityType.postToTwitter), ("SinaWeibo", UIActivityType.postToWeibo), ("iMessage", UIActivityType.message), ("Mail", UIActivityType.mail), ("Flicker", UIActivityType.postToFlickr), ("AirDrop", UIActivityType.airDrop))
        
        let actions = Dictionary(dictionaryLiteral: ("Print", UIActivityType.print), ("Copy", UIActivityType.copyToPasteboard), ("Contact", UIActivityType.assignToContact), ("Save to CameraRoll", UIActivityType.saveToCameraRoll))
        
        var activities = Array<UIActivityType>()
        
        // check shares
        for i in 0..<shares.count {
            let indexPath = IndexPath(row: i, section: 1)
            if let cell = self.tableView.cellForRow(at: indexPath) {
                if cell.accessoryType != UITableViewCellAccessoryType.checkmark {
                    if let type = shares[(cell.textLabel?.text)!] {
                        activities.append(type)
                    }
                }
            }
        }
        
        // check actions
        for i in 0..<actions.count {
            let indexPath = IndexPath(row: i, section: 2)
            if let cell = self.tableView.cellForRow(at: indexPath) {
                if cell.accessoryType != UITableViewCellAccessoryType.checkmark {
                    if let type = actions[(cell.textLabel?.text)!] {
                        activities.append(type)
                    }
                }
            }
        }
        
        return activities.count > 0 ? activities : nil
    }
    
    @IBAction func share(sender : NSObject) {
        // Present logic start
        let items = self.sharingItems()
        
        guard items != nil else {
            let alert = UIAlertView(title: "Warning", message: "Empty items", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        
        let activityController = UIActivityViewController(activityItems: items!, applicationActivities: nil)
        activityController.excludedActivityTypes = self.excludedActivities()
        
        // Sharing result handler
        if #available(iOS 8.0, *) {
            func handlerWithItem (type : UIActivityType?, success : Bool, items : [Any]?, error : Error?) -> Swift.Void {
                print("Handler call over iOS 8.0")
            }
            
            activityController.completionWithItemsHandler = handlerWithItem
        } else {
            // Fallback on earlier versions
            func handler (type : UIActivityType?, success : Bool) -> Void {
                print("Handler call under iOS 8.0")
            }
            
            activityController.completionHandler = handler
        }
        
        // Presentation Start
        if UIDevice.current.userInterfaceIdiom == .pad {
            // for iPad
            if #available(iOS 8.0, *) {
                let popoverController = activityController.popoverPresentationController
                
                if let barButtonItem = sender as? UIBarButtonItem {
                    // UIBarButtonItem
                    popoverController?.barButtonItem = barButtonItem
                }
                else if let view = sender as? UIView {
                    // for UIView (UIButton etc...)
                    popoverController?.sourceView = view;
                    popoverController?.sourceRect = view.bounds;
                }
                else {
                    // No arrow, center position
                    let topView = (UIApplication.shared.keyWindow?.rootViewController?.view)!
                    
                    popoverController?.permittedArrowDirections = .init(rawValue: 0)
                    
                    popoverController?.sourceView = topView
                    popoverController?.sourceRect = CGRect(origin: CGPoint(x : topView.bounds.midX, y : topView.bounds.midY), size: CGSize(width : 0, height : 0))
                }
                
                self.present(activityController, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let popoverController = UIPopoverController(contentViewController: activityController)
                
                // for UIBarButtonItem
                if let barButtonItem = sender as? UIBarButtonItem {
                    // UIBarButtonItem
                    popoverController.present(from: barButtonItem, permittedArrowDirections: .any, animated: true)
                } else if let view = sender as? UIView {
                    // UIButton
                    popoverController.present(from: CGRect(origin: CGPoint(x : view.bounds.midX, y : view.bounds.midY), size: CGSize(width : 0, height : 0)), in: view, permittedArrowDirections: .any, animated: true)
                } else {
                    let topView = (UIApplication.shared.keyWindow?.rootViewController?.view)!
                    
                    popoverController.present(from: CGRect(origin: CGPoint(x : topView.bounds.midX, y : topView.bounds.midY), size: CGSize(width : 0, height : 0)), in: topView, permittedArrowDirections: .init(rawValue: 0), animated: true)
                }
            }
        }
        else {
            // for iPhone
            self.present(activityController, animated: true, completion: nil)
        }
    }
}
