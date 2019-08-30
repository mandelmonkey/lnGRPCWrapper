//
//  OAuthViewController.swift
//  lnGRPCWrapper
//
//  Created by Christian Moss on 2019/04/26.
//  Copyright © 2019 IndieSquare. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

import GTMSessionFetcher
class TouchDelegatingView: UIView {
    weak var touchDelegate: UIView? = nil
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        
        guard view === self, let point = touchDelegate?.convert(point, from: self) else {
            return view
        }
        
        return touchDelegate?.hitTest(point, with: event)
    }
}
extension OAuthViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // A nil error indicates a successful login
        if error == nil {
             self.currentLog("did sign in google");
            // Include authorization headers/values with each Drive API request.
             self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
             self.googleUser = user
            
            if(self.mode == "link"){
                self.currentCallback("linked",nil);
                self.dismiss(animated: true) {
                    
                }
            }
            else{
             populateFolderID()
            }
            
        } else {
            
             self.currentLog("google sign in error"+error.localizedDescription);
             self.googleDriveService.authorizer = nil
             self.googleUser = nil
            self.currentCallback(nil,"file upload error");
            self.dismiss(animated: true) {
                
            }
            
        }
        // ...
    }
}
class OAuthViewController: UIViewController {
    
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    var uploadFolderID: String?
    var fileName: String?
    var folderName: String?
    var clientID:String?
    var passphraseHash:String?
    var mode:String?
    
    public func signOut(){
    
    GIDSignIn.sharedInstance()?.signOut();
    
    }
    public var currentLog:((String?) -> (Void)) = {(log) in}
    
    public var currentCallback:((String?,String?) -> (Void));
    
    init(log:@escaping ((String?) -> (Void)),clientID:String,folderName:String,fileName:String,passphraseHash:String, callback: @escaping (String?,String?) -> Void) {
        self.currentLog = log;
         self.currentLog("init log");
        self.fileName = fileName;
        self.folderName = folderName;
        self.clientID = clientID;
         self.currentLog("init log 2");
        self.currentCallback = callback;
        self.passphraseHash = passphraseHash;
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCallback = {(res, error) in}
        super.init(coder: aDecoder)
        self.view.isHidden = true;
    }
    
    func setMode(theMode:String){
        self.mode = theMode;
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentLog("loaded VC");
        GIDSignIn.sharedInstance()?.delegate = self;
        GIDSignIn.sharedInstance()?.uiDelegate = self;
        GIDSignIn.sharedInstance()?.clientID = self.clientID
        GIDSignIn.sharedInstance()?.scopes =
            [kGTLRAuthScopeDriveFile]
        self.currentLog("start sign in");
        GIDSignIn.sharedInstance()?.signIn()
        
        self.currentLog("got past here");
        
        if let delegatingView = view as? TouchDelegatingView {
            delegatingView.touchDelegate = presentingViewController?.view
        }
        self.dismiss(animated: true) {
            
        }
    }
    func populateFolderID() {
         self.currentLog("starting folder "+self.folderName!);
        
        getFolderID(
            name: self.folderName!,
            service: googleDriveService,
            user:  self.googleUser!) { folderID in
                if folderID == nil {
                    
                    if(self.mode == "download"){
                         self.currentCallback(nil,"file not found");
                        self.dismiss(animated: true) {
                            
                        }
                    }
                    else if(self.mode == "upload"){
                    self.createFolder(
                        name: self.folderName!,
                        service: self.googleDriveService) {
                            self.currentLog("folder did not exist created");
                            
                            self.uploadFolderID = $0
                            if(self.mode == "upload"){
                                self.uploadFile();
                            }
                            
                    }
                    }
                } else {
                    // Folder already exists
                    self.currentLog("folder exists created"+folderID!);
                    
                    self.uploadFolderID = folderID!
                    
                    if(self.mode == "upload"){
                     self.uploadFile();
                    }
                    else if(self.mode == "download"){
                        self.downloadFile();
                    }
                }
        }
    }
    
    func uploadFile() {
        self.currentLog("uploading file "+self.fileName!);
        
        do {
            
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                // process files
                for case let ff in fileURLs {
                   self.currentLog("files list "+ff.absoluteString);
                }
                //self.currentLog("files "+fileURLs);
            } catch {
                 self.currentLog("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
            
            
            let documentsFolderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
             let fileURL = documentsFolderURL.appendingPathComponent(self.fileName!)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                
            
            
            self.currentLog("continue uploading file "+fileURL.path);
            
            uploadFileGD(
                name: self.fileName!,
                folderID: self.uploadFolderID!,
                fileURL: fileURL,
                mimeType: "text/plain",
                service: googleDriveService)
                
            } else {
                self.currentLog("google drive file does not exist "+fileURL.path);
                  self.currentCallback(nil,"file upload error");
               
                self.dismiss(animated: true) {
                    
                }
            }
            
            
            
        } catch {
            self.currentLog("google drive error");
              self.currentCallback(nil,"file upload error");
            self.dismiss(animated: true) {
                
            }
        }
        
    }
    
    public func search(_ fileName: String, service: GTLRDriveService, onCompleted: @escaping (String?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 1
        query.q = "name contains '\(fileName)'"
        
        service.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files?.first?.identifier, error)
        }
    }
    
    
    public func listFilesInFolder(_ folder: String, service: GTLRDriveService, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        search(folder, service: service) { (folderID, error) in
            guard let ID = folderID else {
                onCompleted(nil, error)
                return
            }
            self.listFiles(ID, service: service, onCompleted: onCompleted)
        }
    }
    
    private func listFiles(_ folderID: String,service: GTLRDriveService, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents"
        
        service.executeQuery(query) { (ticket, result, error) in
            onCompleted(result as? GTLRDrive_FileList, error)
        }
    }
    
    func deleteFile(_ fileId: String, service: GTLRDriveService,name: String,
                    folderID: String,
                    fileURL: URL,
                    mimeType: String) {
        
        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileId)
        
        service.executeQuery(query) { (ticket: GTLRServiceTicket?, updatedFile: Any?, error: Error?) in
            if let error = error {
                self.currentLog("delete channel backup error "+error.localizedDescription);
                self.currentCallback(nil,"file upload error");
                self.dismiss(animated: true) {
                    
                }
                return
            }
            
            self.uploadFileGD(name: name, folderID: folderID, fileURL: fileURL, mimeType: mimeType, service: service);
            
        }
    }
 
    
    func getFolderID(
        name: String,
        service: GTLRDriveService,
        user: GIDGoogleUser,
        completion: @escaping (String?) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()
        
        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"
        
        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
        
        let withName = "name = '\(name)'" // Case insensitive!
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                
                self.currentLog("channel backup error "+error!.localizedDescription);
                 self.currentCallback(nil,"file upload error");
                self.dismiss(animated: true) {
                    
                }
                return;
                //fatalError(error!.localizedDescription)
            }
            
            let folderList = result as! GTLRDrive_FileList
            
            // For brevity, assumes only one folder is returned.
            completion(folderList.files?.first?.identifier)
        }
    }
    
    
    func createFolder(
        name: String,
        service: GTLRDriveService,
        completion: @escaping (String) -> Void) {
        
        let folder = GTLRDrive_File()
        folder.mimeType = "application/vnd.google-apps.folder"
        folder.name = name
        
        // Google Drive folders are files with a special MIME-type.
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        self.googleDriveService.executeQuery(query) { (_, file, error) in
            guard error == nil else {
                self.currentLog("channel backup error "+error!.localizedDescription);
                 self.currentCallback(nil,"file upload error");
                self.dismiss(animated: true) {
                    
                }
                return;
               // fatalError(error!.localizedDescription)
            }
            
            let folder = file as! GTLRDrive_File
            completion(folder.identifier!)
        }
    }
    
    func downloadFile(){
        
        listFiles(self.uploadFolderID!, service: self.googleDriveService) { (files, error) in
            
            
            for file in files!.files! {
                if let fname = file.name{
                    
                    if(fname.contains(self.passphraseHash!)){
                        self.currentLog("found file "+fname);
                        
                        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: file.identifier!)
                        self.googleDriveService.executeQuery(query) { (ticket, dfile, error) in
                            if(error != nil){
                                self.currentCallback(nil,"file download error");
                                self.dismiss(animated: true) {
                                    
                                }
                                
                                return;
                            }
                            do{
                                
                                
                            let documentsFolderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                let fileURL = documentsFolderURL.appendingPathComponent(self.passphraseHash!+".txt")
                            
                            let data = (dfile as? GTLRDataObject)?.data;
                              
                            try data!.write(to: fileURL, options: .atomic)
                                 self.currentLog("saving to "+fileURL.absoluteString);
                               
                                    let text = try String(contentsOf: fileURL, encoding: .utf8)
                               
                                
                                self.currentCallback(text,nil);
                                self.dismiss(animated: true) {
                                    
                                }
                                
                                
                            
                                
                            }
                            catch{
                                self.currentCallback(nil,error.localizedDescription);
                                self.dismiss(animated: true) {
                                    
                                }
                                
                                
                            
                            }
                        }
                        
                        
                        return;
                    }
                    
                }
                
            }
            
            self.currentCallback(nil,"file not found");
            self.dismiss(animated: true) {
                
            }
            
        }
        
        
    }
    func uploadFileGD(
        name: String,
        folderID: String,
        fileURL: URL,
        mimeType: String,
        service: GTLRDriveService) {
        
        listFiles(folderID, service: service) { (files, error) in
            
            
            for file in files!.files! {
                if let fname = file.name{
                    
                    if(name == fname){
                        self.currentLog("deleting old file "+fname);
                        
                        self.deleteFile(file.identifier!, service: service, name: name,folderID: folderID,fileURL: fileURL,mimeType: mimeType);
                    
                        return;
                    }
                    
                }
                
            }
            
            self.currentLog("uploading file "+name);
            
            let file = GTLRDrive_File()
            file.name = name
            file.parents = [folderID]
            
            // Optionally, GTLRUploadParameters can also be created with a Data object.
            let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
            
            let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
            
            service.uploadProgressBlock = { _, totalBytesUploaded, totalBytesExpectedToUpload in
                self.currentLog("uploading "+String(totalBytesUploaded));
                
                // This block is called multiple times during upload and can
                // be used to update a progress indicator visible to the user.
            }
            
            service.executeQuery(query) { (_, result, error) in
                guard error == nil else {
                    self.currentLog("channel backup error"+error!.localizedDescription);
                    self.currentCallback(nil,"file upload error");
                    self.dismiss(animated: true) {
                        
                    }
                    //fatalError(error!.localizedDescription)
                    return;
                }
                
                self.currentLog("channel backup success");
                self.currentCallback("file uploaded",nil);
                self.dismiss(animated: true) {
                    
                }
                
                // Successful upload if no error is returned.
            }
        }
        
    }
}
