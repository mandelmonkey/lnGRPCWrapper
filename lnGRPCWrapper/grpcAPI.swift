//
//  grpcAPI.swift
//  lnGRPCWrapper
//
//  Created by Chris on 2018/07/26.
//  Copyright © 2018 IndieSquare. All rights reserved.
//

import UIKit
import Starscream

import Lndmobile
class RemoteRPCConfiguration {
    var url: String
    var certificate:String
    var macaroon:String
    
    init(url:String,certificate:String,macaroon:String){
        
        self.url = url;
        self.certificate = certificate;
        self.macaroon = macaroon;
        
    }
}
extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}



struct LNError : LocalizedError
{
    public var error : String
    
    init(_ description: String)
    {
        error = description
    }
    
    var errorDescription: String? {
        return error;
    }
    
}

private extension Lnrpc_LightningServiceClient {
    convenience init(configuration: RemoteRPCConfiguration) {
        
         setenv("GRPC_SSL_CIPHER_SUITES", "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384", 1)
        
        let cert = configuration.certificate
       
        if(cert == ""){
            
            self.init(address: configuration.url, secure: true, arguments: [])
            
        }else{
           
            self.init(address: configuration.url, certificates: configuration.certificate)
        }
        
        try? metadata.add(key: "macaroon", value: configuration.macaroon)
    }
}
@objc public class grpcAPI: NSObject, WebSocketDelegate {
    
    var config:RemoteRPCConfiguration;
    private let rpc: Lnrpc_LightningService
    var socket = WebSocket(url: URL(string: "ws://lit-castle-74426.herokuapp.com")!, protocols: ["chat"])
    
    var webSocketCallback :(String?,Error?) -> Void;
    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("ocnnect");
        webSocketCallback("connected",nil);
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
         webSocketCallback("disconnected",nil);
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
          webSocketCallback(text,nil);
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
  
    @objc public init(url:String,certificate:String,macaroon:String) {
    
        func dummyCallback(one:String?,two:Error?)->Void{
            
        }
        config = RemoteRPCConfiguration.init(url: url,certificate: certificate,macaroon: macaroon);
        rpc = Lnrpc_LightningServiceClient.init(configuration: config);
        webSocketCallback = dummyCallback;
        super.init();
    }
    
    @objc public func getInfo(callback: @escaping (String?,String?) -> Void) {
        do {
            
            _ = try rpc.getInfo(Lnrpc_GetInfoRequest()) { response, callResult in
            
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func getWalletBalance(callback: @escaping (String?,String?) -> Void) {
        do {
            _ = try rpc.walletBalance(Lnrpc_WalletBalanceRequest()) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue), callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func getChannelBalance(callback: @escaping (String?,String?) -> Void) {
        do {
            _ = try rpc.channelBalance(Lnrpc_ChannelBalanceRequest()) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func getTransactions(callback: @escaping (String?,String?) -> Void) {
        do {
            _ = try rpc.getTransactions(Lnrpc_GetTransactionsRequest()) { response, callResult in
                
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func listChannels(callback: @escaping (String?,String?) -> Void) {
        do {
            _ = try rpc.listChannels(Lnrpc_ListChannelsRequest()) { response, callResult in
                
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
         
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func listInvoices(callback: @escaping (String?,String?) -> Void) {
        do {
            
            var req = Lnrpc_ListInvoiceRequest();
            req.reversed = true;
            req.numMaxInvoices = 100;
            _ = try rpc.listInvoices(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func pendingChannels(callback: @escaping (String?,String?) -> Void) {
        do {
            _ = try rpc.pendingChannels(Lnrpc_PendingChannelsRequest()) { response, callResult in
                
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    
    @objc public func listPayments(callback: @escaping (String?,String?) -> Void) {
        do {
            _ = try rpc.listPayments(Lnrpc_ListPaymentsRequest()) { response, callResult in
                
              
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func sendPayment(paymentRequest:String, amount:Int64, callback: @escaping (String?,String?) -> Void) {
        
            var req = Lnrpc_SendRequest();
            req.paymentRequest = paymentRequest;
        if(amount != -1){
            req.amt = amount;
        }
            do {
                
            _ = try rpc.sendPaymentSync(req) { response, error in
                   do {
                if !error.success {
                   callback("error send",error.statusMessage)
                } else if let errorMessage = response?.paymentError,
                    !errorMessage.isEmpty {
                     callback("error send",errorMessage)
                } else if let sendResponse = response {
                    let res = try sendResponse.jsonString();
                    
                    callback(res,nil)
                } else if let statusMessage = error.statusMessage {
                    callback("error send",statusMessage)
                } else {
                    callback("error send","unknown error");
                }
                   }
                   catch{
                    
                }
            }
        }
            catch{
                
        }
            
            
        
    }
   
    @objc public func newAddress(addressType:String, callback: @escaping (String?,String?) -> Void) {
        do {
            var req = Lnrpc_NewAddressRequest();
            if(addressType == "np2wkh"){
                req.type = Lnrpc_AddressType.nestedPubkeyHash;
            }else {
                req.type =  Lnrpc_AddressType.witnessPubkeyHash;
            }
            
            
            _ = try rpc.newAddress(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    
    @objc public func decodePayReq(payReq:String, callback: @escaping (String?,String?) -> Void) {
        do {
            
            var req = Lnrpc_PayReqString()
            
            req.payReq = payReq;
            
            _ = try rpc.decodePayReq(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func addInvoice(amount:Int64, expiry:Int64, memo:String, callback: @escaping (String?,String?) -> Void) {
        do {
            
            var req = Lnrpc_Invoice();
            req.value = amount;
            req.memo = memo;
            req.expiry = expiry;
            
            
            _ = try rpc.addInvoice(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage)
                        
                    }else{
                        
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func lookUpInvoice(rhash:String, callback: @escaping (String?,String?) -> Void) {
        do {
            
            var req = Lnrpc_PaymentHash();
            req.rHashStr = rhash;
            
            
            _ = try rpc.lookupInvoice(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func connectPeer(host:String, pubkey:String, callback: @escaping (String?,String?) -> Void) {
        do {
            
            var req = Lnrpc_ConnectPeerRequest();
            var lnAddr =  Lnrpc_LightningAddress();
            lnAddr.host=host;
            lnAddr.pubkey = pubkey;
            req.addr = lnAddr;
            
            
            _ = try rpc.connectPeer(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    @objc public func openChannel(localFundingAmount:Int64, pubkey:String, callback: @escaping (String?,String?) -> Void) {
        do {
            
            var req = Lnrpc_OpenChannelRequest();
            req.localFundingAmount = localFundingAmount;
            req.nodePubkeyString = pubkey;
            
            _ = try rpc.openChannelSync(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue),callResult.statusMessage!)
                        
                    }else{
                        
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    private func receiveCloseChannelUpdate(call: Lnrpc_LightningCloseChannelCall, callback: @escaping (String?,String?) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                let json =  try? result.jsonString()
                callback(json,nil)
                
            } else if let error = $0.error {
                callback(nil,error.localizedDescription)
                return;//dont let the receiveCloseChannelUpdate fire if error because if it does the function iterates error forever, instead let the app re init the eubscribe function
            }
            try? self?.receiveCloseChannelUpdate(call: call,callback: callback)
        }
    }
    
    private func receiveInvoicesUpdate(call: Lnrpc_LightningSubscribeInvoicesCall, callback: @escaping (String?,String?) -> Void) throws {
        
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                let json =  try? result.jsonString()
                callback(json,nil)
                
                
                
                //callback(" result","")
            } else if let error = $0.error {
                 callback(nil,error.localizedDescription)
                return;//dont let the receiveInvoicesUpdate fire if error because if it does the function iterates error forever, instead let the app re init the eubscribe function
            }
            try? self?.receiveInvoicesUpdate(call: call,  callback: callback)
           
        }
        
        
    }
    
    private func receiveTransactionsUpdate(call: Lnrpc_LightningSubscribeTransactionsCall, callback: @escaping (String?,String?) -> Void) throws {
        
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                let json =  try? result.jsonString()
                callback(json,nil)
                
                
                
                //callback(" result","")
            } else if let error = $0.error {
                callback(nil,error.localizedDescription)
                return;//dont let the receiveInvoicesUpdate fire if error because if it does the function iterates error forever, instead let the app re init the eubscribe function
            }
            try? self?.receiveTransactionsUpdate(call: call,  callback: callback)
            
        }
        
        
    }
    
    @objc public func subscibeInvoices(callback: @escaping (String?,String?) -> Void) {
      
              do {
                    let call = try rpc.subscribeInvoices(Lnrpc_InvoiceSubscription(), completion: { print(#function, $0) })
                    try receiveInvoicesUpdate(call: call, callback: callback)
                } catch {
                   callback("error subscribe",error.localizedDescription)
                }
        
    }
    
    @objc public func subscibeTransactions(callback: @escaping (String?,String?) -> Void) {
        
        do {
            let call = try rpc.subscribeTransactions(Lnrpc_GetTransactionsRequest(), completion: { print(#function, $0) })
            try receiveTransactionsUpdate(call: call, callback: callback)
        } catch {
            callback("error subscribe",error.localizedDescription)
        }
        
    }
    
    
    
    func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
    
    @objc public func closeChannel(txid:String, output:Int64, force:Bool, callback: @escaping (String?,String?) -> Void) {
        
            
            
            var channelPoint = Lnrpc_ChannelPoint();
            channelPoint.fundingTxidStr = txid;
            channelPoint.outputIndex = UInt32(output);
        
            var req = Lnrpc_CloseChannelRequest();
            req.channelPoint = channelPoint;
            
            req.force = force;
        
        
        do {
                let call = try rpc.closeChannel(req, completion: {  print(#function, $0)  })
                
                try receiveCloseChannelUpdate(call: call, callback:callback)
            } catch {
                 callback(nil,error.localizedDescription)
            }
        
        
    }
    
    @objc public func getNodeInfo(pubkey:String, callback: @escaping (String?,String?) -> Void) {
        do {
            var req = Lnrpc_NodeInfoRequest();
            req.pubKey = pubkey;
            _ = try rpc.getNodeInfo(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue), callResult.statusMessage)
                        
                    }else{
                        
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
            
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
            
    
    @objc public func sendCoins(amount:Int64, address:String, fee:Int64, callback: @escaping (String?,String?) -> Void) {
        do {
            
            var req = Lnrpc_SendCoinsRequest()
            req.amount = amount;
            req.addr = address;
            req.satPerByte = fee;
            
            _ = try rpc.sendCoins(req) { response, callResult in
                
                do{
                    
                    if(response == nil){
                        callback(String(callResult.statusCode.rawValue), callResult.statusMessage)
                        
                    }else{
                        
                        let res = try response!.jsonString();
                        
                        callback(res,nil)
                    }
                    
                }
                catch{
                    
                    callback(nil,error.localizedDescription)
                }
                
                
                
            }
        } catch {
            
            callback(nil,error.localizedDescription)
        }
    }
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
      @objc public func startWebSocket(url:String, callback: @escaping (String?,Error?) -> Void){
        webSocketCallback = callback;
        socket = WebSocket(url: URL(string: url)!, protocols: ["chat"])
        socket.delegate = self
        
        socket.connect()

        
        
    }
    
    @objc public func sendWebSocketMessage(msg:String){
        socket.write(string: msg)
        
        
    }
    
    func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.characters.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }

    
    
    
    
    
}
