//
//  AWSRepo.swift
//  CloudAWS
//
//  Created by MS70WPHU on 2021/11/29.
//

import UIKit
import AWSCore
import AWSCognito
import AWSIoT

import SwiftyJSON

class AWSRepo {
    
    static let sharedInstance = AWSRepo()
    private var mIoTData: AWSIoTData!

//    private var mIoTThingName: String = "Nuvoton-RTOS-D002"
//    private var mIoTEndPoint = "a1fljoeglhtf61-ats.iot.us-east-1.amazonaws.com"
//    private var mCognitoIdentityPoolId = "us-east-1:9e41d4ca-03a7-4af0-a6ec-0bc5b5814781"
//    private var mRegion = AWSRegionType.USEast1

    private var mIoTThingName: String = ""
    private var mIoTEndPoint = ""
    private var mCognitoIdentityPoolId = ""
    private var mRegion = AWSRegionType.USEast1
    
    private var mAWSCognitoCredentialsProvider :AWSCognitoCredentialsProvider? = nil
    private var mAWSEndpoint :AWSEndpoint? = nil
    private var mAWSServiceConfiguration: AWSServiceConfiguration? = nil
    
    private var mTimer = Timer()
    private var LoopIndex = 0
    
    private var mShadowJsonListeners : ((JSON?) ->())? = nil
    
    
    public func initAWS(poolId :String , region :AWSRegionType){
                                                                                                                                                    
        if(poolId == "") {
            return
        }
        
        self.LoopIndex = 0

        mCognitoIdentityPoolId = poolId
        mRegion = region

        mAWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: mRegion, identityPoolId: mCognitoIdentityPoolId)
        print("init AWSCognitoCredentialsProvider:\(mAWSCognitoCredentialsProvider?.getIdentityId())")
                                                               
    }
    
    func  setIotThing(endPoint:String,thingName:String) {
        
        mIoTEndPoint = endPoint
        mIoTThingName = thingName
        
        mAWSEndpoint = AWSEndpoint(urlString: "https://\(mIoTEndPoint)")
        mAWSServiceConfiguration = AWSServiceConfiguration(region: mRegion, endpoint: mAWSEndpoint, credentialsProvider: mAWSCognitoCredentialsProvider)

        print("init AWSServiceConfiguration:\(mAWSServiceConfiguration?.description)")
        AWSServiceManager.default()?.defaultServiceConfiguration = mAWSServiceConfiguration
        AWSIoTData.register(with: mAWSServiceConfiguration!, forKey: mIoTThingName)
        mIoTData = AWSIoTData.default()
        print("init IoTData:\(mIoTData)")
     }
    
    func StartGetShadow(loopTime:Int,shadowJsonListeners:@escaping (JSON?) ->()){

        mShadowJsonListeners = shadowJsonListeners
        mTimer.invalidate()
        mTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(loopTime), repeats: true, block: { Timer in
            
            let request = AWSIoTDataGetThingShadowRequest.init()
            request?.thingName = self.mIoTThingName
        
            self.LoopIndex = self.LoopIndex + 1
            if(self.LoopIndex >= 5){
                self.mShadowJsonListeners!(nil)
            }
            
            self.mIoTData.getThingShadow(request!).continueOnSuccessWith{ (awsTask: AWSTask<AWSIoTDataGetThingShadowResponse>!) in
                    
                if let error = awsTask.error {
                    print("failed: [\(error)]")
                }
                
                self.LoopIndex = 0
                    
                let resultData = awsTask.result?.payload as! Data
                let json = try? JSON(data: resultData)
                
                if (json?.dictionary != nil) {       //解析json的地方
//                    print("json:\(json)")
                    guard let reported = json?.dictionary?["state"]?["reported"] else {
                        print("get repoted dic failed")
                        return awsTask
                    }
              
                    var dic: [String: Double] = ["temperature": reported["temperature"].numberValue.doubleValue]
//                    print("json:\(dic["temperature"])")
//                    dic["timestamp"] = Double(self.getTimeSecond())
                    self.mShadowJsonListeners!(json!)
                }
                return awsTask
            }
            
        })

    }
    
}

