//
//  websocket.swift
//  lnGRPCWrapper
//
//  Created by Christian Moss on 2019/05/14.
//  Copyright © 2019 IndieSquare. All rights reserved.
//

import Foundation
import Starscream

@objc public class websocket: NSObject, WebSocketDelegate {
    
 var socket: WebSocket!;
    
    var webSocketCallback :(String?,String?) -> Void;
    
    public func websocketDidConnect(socket: WebSocketClient) {
        
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
    
    @objc public override init() {
        
        func dummyCallback(one:String?,two:String?)->Void{
            
        }
        webSocketCallback = dummyCallback;
        
        super.init();
    }
    
deinit {
    socket.disconnect(forceTimeout: 0)
    socket.delegate = nil
}
@objc public func startWebSocket(url:String, callback: @escaping (String?,String?) -> Void){
    
    webSocketCallback = callback;
    if(socket != nil){
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    socket = WebSocket(url: URL(string: url)!, protocols: ["chat"])
    socket.delegate = self
    
    socket.connect()
    
    
}

@objc public func sendWebSocketMessage(msg:String){
    socket.write(string: msg)
    
    
}
@objc public func closeWebSocket(){
    socket.disconnect(forceTimeout: 0)
    socket.delegate = nil
    
    
}

}
