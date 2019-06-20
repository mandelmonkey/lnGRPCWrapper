//
//  utils.swift
//  lnGRPCWrapper
//
//  Created by Christian Moss on 2019/04/25.
//  Copyright © 2019 IndieSquare. All rights reserved.
//

import UIKit
import Foundation
  
@objc public class utils: NSObject {
    
    public override init() {
        
        currentCallback = {(res, error) in}
        
        oauthVC = OAuthViewController(log: currentLog, clientID: "", folderName: "", fileName: "",passphraseHash:"", callback:currentCallback)
    }
    
    @objc public func getFreeDiskSpace()->Int64{
    do {
    let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
    let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
    return freeSpace!
    } catch {
    return 0
    }
    }
    
    public var currentCallback:((String?,String?) -> (Void));
    
    
    public var currentLog:((String?) -> (Void)) = {(log) in}
    var oauthVC:OAuthViewController
    
    @objc public func setLog(callback: @escaping (String?) -> Void) {
        
        self.currentLog = callback;
    }
    @objc public func uploadFile(vc:UIViewController,clientID:String,folderName:String,fileName:String,passphraseHash:String,callback: @escaping (String?,String?) -> Void) {
        self.currentLog("starting drive");
        oauthVC = OAuthViewController(log: currentLog, clientID:clientID, folderName: folderName, fileName: fileName,passphraseHash:passphraseHash, callback:callback);
        oauthVC.setMode(theMode: "upload");
        self.currentLog("starting drive1");
        oauthVC.view.backgroundColor = .blue
        self.currentLog("starting drive2");
        vc.present(oauthVC, animated: true, completion: nil)
        self.currentLog("starting drive3");
    }
    
    @objc public func linkGoogleDrive(vc:UIViewController,clientID:String,callback: @escaping (String?,String?) -> Void) {
        self.currentLog("starting drive");
        oauthVC = OAuthViewController(log: currentLog, clientID:clientID, folderName: "", fileName: "",passphraseHash:"", callback:callback);
        oauthVC.setMode(theMode: "link");
        self.currentLog("starting drive1");
        oauthVC.view.backgroundColor = .blue
        self.currentLog("starting drive2");
        vc.present(oauthVC, animated: true, completion: nil)
        self.currentLog("starting drive3");
    }
    
    @objc public func downloadFile(vc:UIViewController,clientID:String,folderName:String,fileName:String, passphraseHash:String, callback: @escaping (String?,String?) -> Void) {
        self.currentLog("starting drive");
        oauthVC = OAuthViewController(log: currentLog, clientID:clientID, folderName: folderName, fileName: fileName, passphraseHash:passphraseHash, callback:callback);
        oauthVC.setMode(theMode: "download");
        self.currentLog("starting drive1");
        oauthVC.view.backgroundColor = .blue
        self.currentLog("starting drive2");
        vc.present(oauthVC, animated: true, completion: nil)
        self.currentLog("starting drive3");
    }
    
    @objc public func signOut() {
        self.currentLog("signing out");
       oauthVC.signOut()
    }


}
