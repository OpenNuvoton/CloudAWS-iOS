//
//  ViewController.swift
//  CloudAWS
//
//  Created by MS70WPHU on 2021/11/15.
//

import UIKit
import Charts
import AWSCore
import AWSCognito
import AWSIoT

class ViewController: UIViewController {
    
    @IBOutlet weak var _LineChartView: LineChartView!
    
    @IBOutlet weak var Load_Label: UILabel!
    
    private var mIoTThingName: String = "Nuvoton-Mbed-D001"
    private var mIoTEndPoint = "a1fljoeglhtf61-ats.iot.us-east-2.amazonaws.com"
    private var mCognitoIdentityPoolId = "us-east-2:f7c9d0c0-2d71-4395-902d-6e0679af3d09"
    private var mRegion = AWSRegionType.USEast2
    private var mIndex = 0
    private var mMPCM : MPChartManager? = nil
    private var mAWS:AWSRepo?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mMPCM = MPChartManager(lc: _LineChartView)
        //新增監聽
        NotificationCenter.default.addObserver(self, selector: #selector(onSave), name:NSNotification.Name(rawValue: "onSave"), object: nil)
        
        //讀取資料
        self.getSetting()
        
        self.startAWS()
        
        
    }
    
    @objc func onSave() {
        print("onSave")
        
        self.getSetting()
        
        self.startAWS()
        
    }
    
    @IBAction func SelectButton(_ sender: UIButton) {
        
        let controller = UIAlertController(title: "Select", message: "", preferredStyle: .actionSheet)
        
        var list = Array<String>()
        list.append("ALL")
        list = list + (self.mMPCM!.getLineLabelNameArray())
        let names = list
        
        for name in names {
           let action = UIAlertAction(title: name, style: .default) { action in
              print(action.title)
               self.mMPCM!.setDisplayLine(labelName: action.title!)
           }
           controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    func getSetting(){
        print("getSetting")
        
        let userDefault = UserDefaults()
        if let info = userDefault.object(forKey: "_AWS_HostRegion_Text") as? Int {
            mRegion = AWSRegionType.init(rawValue: info)!
        }
        if let info = userDefault.object(forKey: "_AWS_CognitoIdentityPoolID_Text") as? String {
            mCognitoIdentityPoolId = info
        }
        if let info = userDefault.object(forKey: "_AWS_IOTEndpoint_Text") as? String {
            mIoTEndPoint = info
        }
        if let info = userDefault.object(forKey: "_AWS_IOTThingName_Text") as? String {
            mIoTThingName = info
        }
        
    }
    
    func startAWS(){
        print("startAWS")
        DispatchQueue.main.async {
            self.Load_Label.text = "Loading..."
        }
        
        mAWS = AWSRepo.sharedInstance
        mAWS?.initAWS(poolId: mCognitoIdentityPoolId, region: mRegion)
        
        mAWS!.setIotThing(endPoint: mIoTEndPoint, thingName: mIoTThingName)
        print("\(mCognitoIdentityPoolId)  \(mRegion.rawValue)  \(mIoTEndPoint)  \(mIoTThingName)")
        mAWS!.StartGetShadow(loopTime: 2) { json in
            
            if(json == nil){
                DispatchQueue.main.async {
                self.Load_Label.text = "Failed. Please check setting."
                }
                return
            }
            
            if (json?.dictionary != nil) {

                guard let reported = json?.dictionary?["state"]?["reported"] else {
                    print("get repoted dic failed")
                    return
                }
                
                DispatchQueue.main.async {
                    self.Load_Label.text = ""
                }

                let dic: [String: Double] = ["temperature": reported["temperature"].numberValue.doubleValue]
//                print("main json:\(dic["temperature"])")

                let name = reported["clientName"].stringValue
                let value = dic["temperature"]
                
                print("AWS Name:\(name)    value:\(value!)")
                
                let lastValue = self.mMPCM!.getLastValue()
                if(lastValue.name == name && self.mIndex < 5){
                    self.mIndex = self.mIndex + 1
                    return
                }
                
                DispatchQueue.main.async() {
                    self.mMPCM!.addChartDataSet(name: name)
                    self.mMPCM!.addEntry(name: name,value: value!)
                    self.mIndex = 0
                }
            
            }
        }
    }
    
    
    
}

