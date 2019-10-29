//
//  ViewController.swift
//  Zeus
//
//  Created by Archer Gardiner-Sheridan on 29/10/19.
//  Copyright © 2019 Archer Gardiner-Sheridan. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, NSTextFieldDelegate {
    
    // MARK: UI Outlets
    @IBOutlet weak var urlBar: NSTextField!
    @IBOutlet weak var goBtn: NSButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var forwardBtn: NSButton!
    @IBOutlet weak var backBtn: NSButton!
    
    // MARK: INIT
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup text field (url bar)
        urlBar.delegate = self
        
        // Setup webview
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.layer?.cornerRadius = 6
        
        // Load DuckDuckGo as the initial search engine
        webView.load("https://www.duck.com")
    }

    // Dunno what this does :)
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: Misc.
    // enables or disables the backwards and forwards buttons, depending if forwards and backwards websites are available
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.canGoForward{
            forwardBtn.isEnabled = true
        } else {
            forwardBtn.isEnabled = false
        }
        
        if webView.canGoBack{
            backBtn.isEnabled = true
        } else {
            backBtn.isEnabled = false
        }
    }
    
    // when finished editing the url bar, visually deselect it
   func controlTextDidEndEditing(_ obj: Notification) {
        urlBar.focusRingType = .none
    }
    
    // MARK: Back + Forwards
    @IBAction func goForward(_ sender: Any) {
        // if the web view can go forward, go forward
        if webView.canGoForward{
            webView.goForward()
        }
    }
    @IBAction func goBack(_ sender: Any) {
        // if the web view can go back, go back
        if webView.canGoBack{
            webView.goBack()
        }
    }
    
    // MARK: Load Webpage
    @IBAction func urlBarAction(_ sender: NSTextField) {
        let query = urlBar.stringValue
        formatInput(query: query)
    }
    @IBAction func goBtnAction(_ sender: Any) {
        let query = urlBar.stringValue
        formatInput(query: query)
    }
    
    // Formats the input from the url bar
    func formatInput(query: String){
        // if the query contains a space, the user wants to search
        if query.contains(" "){
            // TODO: search
        }
        // if it doesn't have a space, it is a URL. however, it needs to be determined if it is HTTP or HTTPS
        else {
            // the query contains either http or https, so try and load the site
            if query.contains("https://") || query.contains("http://"){
                webView.load(query)
            }
            // the query doesnt contain http or https, so try and determine which one it is by sending a test https request. if the response is anything thats not 404, then we will load the site. if it is 404, we will try http instead
            else {
                httpsTestRequest(urlString: query)
            }
        }
    }
    
    func httpsTestRequest(urlString: String){
        // create a string for the url, the make a url from the string and a request from the url
        let fullURL = "https://\(urlString)"
        let url = URL(string: fullURL)
        let request = URLRequest(url: url!)
        
        // setup an async URLSession to make the test request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (response as? HTTPURLResponse)?.statusCode == 404{
                // status code was 404, attempt http
                self.webView.load("http:\(urlString)")
                
                // set url bar to url. since it is a UI operation, it is done on the main thread
                DispatchQueue.main.async{
                    self.urlBar.stringValue = "http:\(urlString)"
                }

            } else {
                // status code wasn't 404, try and load site
                self.webView.load(fullURL)
                
                // set url bar to url. since it is a UI operation, it is done on the main thread
                DispatchQueue.main.async{
                    self.urlBar.stringValue = fullURL
                }
            }
        }.resume()
    }
}

extension WKWebView {
    // Quick and easy function for loading a webpage given a string. Thanks StackOverflow :D
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            // run on main thread, since it us a UI operation
            DispatchQueue.main.async{
                self.load(request)
                self.allowsBackForwardNavigationGestures = true
            }
        }
    }
}

