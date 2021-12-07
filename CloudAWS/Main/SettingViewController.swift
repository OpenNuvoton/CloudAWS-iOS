//
//  SettingViewController.swift
//
//  Created by MS70WPHU on 2021/3/8.
//  Copyright © 2021 nuvoton. All rights reserved.
//

import UIKit
import AWSCore

class SettingViewController: UIViewController {
    //AWS
    @IBOutlet weak var _AWS_HostRegion_Text: UITextField!
    @IBOutlet weak var _AWS_CognitoIdentityPoolID_Text: UITextField!
    @IBOutlet weak var _AWS_IOTEndpoint_Text: UITextField!
    @IBOutlet weak var _AWS_IOTThingName_Text: UITextField!

    let RegionTypeList = ["Unknown","USEast1","USEast2","USWest1","USWest2","EUWest1","EUWest2","EUCentral1","APSoutheast1","APNortheast1","APNortheast2","APSoutheast2","APSouth1","SAEast1","CNNorth1","CACentral1","USGovWest1","CNNorthWest1","EUWest3","USGovEast1","EUNorth1","APEast1","MESouth1","AFSouth1","EUSouth1"]
    var RegionIndex = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.LoadSetting()
        
        //點擊空白處，隱藏鍵盤
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func BackButton(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("onBack"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    private func LoadSetting() {
        let userDefault = UserDefaults()
        
        if let info = userDefault.object(forKey: "_AWS_HostRegion_Text") as? Int {
            _AWS_HostRegion_Text.text = RegionTypeList[info]
        }
        if let info = userDefault.object(forKey: "_AWS_CognitoIdentityPoolID_Text") as? String {
            _AWS_CognitoIdentityPoolID_Text.text = info
        }
        if let info = userDefault.object(forKey: "_AWS_IOTEndpoint_Text") as? String {
            _AWS_IOTEndpoint_Text.text = info
        }
        if let info = userDefault.object(forKey: "_AWS_IOTThingName_Text") as? String {
            _AWS_IOTThingName_Text.text = info
        }
        
    }
    
    @IBAction func SaveButton(_ sender: UIButton) {
        
        let userDefault = UserDefaults()
        userDefault.set(RegionIndex, forKey: "_AWS_HostRegion_Text")
        userDefault.set(_AWS_CognitoIdentityPoolID_Text.text, forKey: "_AWS_CognitoIdentityPoolID_Text")
        userDefault.set(_AWS_IOTEndpoint_Text.text, forKey: "_AWS_IOTEndpoint_Text")
        userDefault.set(_AWS_IOTThingName_Text.text, forKey: "_AWS_IOTThingName_Text")

        userDefault.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name("onSave"), object: nil)
        
        dismiss(animated: true)
    }
    
    @IBAction func SelectRegionButton(_ sender: UIButton) {
        
        let controller = UIAlertController(title: "Select", message: "Region", preferredStyle: .actionSheet)

        let names = RegionTypeList
        
        for name in names {
           let action = UIAlertAction(title: name, style: .default) { action in
               self._AWS_HostRegion_Text.text = name
               self.RegionIndex = self.RegionTypeList.firstIndex(of: name)!
    
           }
           controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    

    
}

extension UIViewController{
    //隱藏鍵盤
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

