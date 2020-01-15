//
//  ViewController.swift
//  WebViewDemo
//
//  Created by jenniffer peng on 2020/1/7.
//  Copyright © 2020年 jenniffer peng. All rights reserved.
//

import UIKit
import WebKit

// implement WKNavigationDelegate and WKScriptMessageHandler
class ViewController: UIViewController,WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet var containerView: UIView? = nil
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.add(self, name: "ios")  //名字自訂

        var webView = WKWebView(frame: self.view.frame, configuration: configuration)
        //只允許webview上下捲動
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        return webView
    }()
    
    override func loadView() {
        super.loadView()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        
        let webURL : NSURL = NSURL(string: "http://211.22.86.124/testweb/webviewjs/jsontest.html")!
        let webRequest:NSURLRequest = NSURLRequest(url: webURL as URL)
        self.webView.load(webRequest as URLRequest)
        
        print("webview loaded")
    }
    
    //called when the navigation is complete(測試webView.evaluateJavaScript)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("func webView")
        
        //swift call javascript
        webView.evaluateJavaScript("setResultText('WebView你好！')") { (result, err) in
            print("result: \(result as Any)", err as Any)
        }
    }

    //Invoked when a script message is received from a webpage.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        print(message.body)
//        print("userContentController message.name: \(message.name)")
        
        if (message.name == "ios") {
            print("from javascript: \(message.body)")
            //取出funcName 呼叫對應的function  再呼叫js回傳結果
            // check if the obj is a string
            if let objStr=message.body as? String{
                let data:Data = objStr.data(using: .utf8)!
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        // try to read out a string array
                        let temp = json["funcName"]
                        let funcName = temp as! String
                        print("funcName:\(funcName)")
                        if funcName=="doSign" { //簽章
                            let idno = json["idno"]
                            print("idno:\(idno!)")
                            // if ((idno as? [String]) != nil) {
                            //  print("idno\(String(describing: idno))")
                            // } else{
                            //  print("not String \(String(describing: idno))")
                            // }
                                                    
                            let toSign = json["toSign"]
                            print("toSign:\(toSign!)")
                            
                            let resstr = doSign(idno: idno as! String, toSign: toSign as! String)
                            
                            //傳回doSign的結果給web
                            callJavascript(funcName: "doSignIosRes",data: resstr)

                        } else if funcName=="sendToServer" {
                            let idno = json["idno"]
                            print("idno:\(idno!)")
                            let tr = json["tr"]
                            print("tr:\(tr!)")
                            let session = json["session"]
                            print("session:\(session!)")
                            let userkey = json["userkey"]
                            print("userkey:\(userkey!)")
                            let midData = json["midData"]
                            print("midData:\(midData!)")
                            
                            //傳回server回的資料給web
                            callJavascript(funcName: "sendToServerIosRes",data: "test")
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            } else{
                print("message.body is not a String")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //簽章
    func doSign(idno:String, toSign: String) -> String {
        print("func doSign idno:\(idno)  toSign:\(toSign)")
        let resstr: String = "resstr"
        return resstr
    }
    
    //呼叫javascript的function
    func callJavascript(funcName: String, data: String) {
        print("func callJavascript")
        webView.evaluateJavaScript(""+funcName+"('"+data+"')", completionHandler: {(result, err) in
            print("completed with result: \(String(describing: result as? String))")
            print("completed with err: \(err as Any)")
        })
    }
}

