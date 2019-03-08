//
//  OAuthViewController.swift
//  CloverConnector_Example
//
//  Created by Deshmukh, Harish (Non-Employee) on 11/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class OAuthViewController: UIViewController, UIWebViewDelegate {
    
    // Check with CloverGo Integration team for demo credentials
    let CLIENT_ID = ""
    let CLIENT_SECRET = ""
    
    @IBOutlet weak var webViewForOAuth: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAuthorizationRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAuthorizationRequest()
    {
        let responseType = "code"
        let redirectURL = "clovergooauth://oauthresult"
        
        var authorizationURL = "https://dev14.dev.clover.com/oauth/authorize?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(CLIENT_ID)&"
        authorizationURL += "redirect_uri=\(redirectURL)"
        
        let request = URLRequest(url: NSURL(string: authorizationURL)! as URL)
        webViewForOAuth.loadRequest(request)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (request.url?.host == "oauthresult") {
            extractParametersForRestCall(url: (request.url)!)
        }
        return true
    }
    
    func extractParametersForRestCall(url: URL)
    {
        let codeFromRecievedUrl = url.query?.components(separatedBy: "code=").last
        print("codeFromRecievedUrl: \(String(describing: codeFromRecievedUrl))")
        
        restCallToGetToken(code: codeFromRecievedUrl!)
    }
    
    /// Make a rest call to get the access token
    ///
    /// - Parameters:
    ///   - code: received from redirect Url
    func restCallToGetToken(code: String)
    {
        var urlString = NSString(format: "https://dev14.dev.clover.com/oauth/token?")
        urlString = "\(urlString)&client_id=" as NSString
        urlString = "\(urlString)\(CLIENT_ID)" as NSString
        urlString = "\(urlString)&client_secret=" as NSString
        urlString = "\(urlString)\(CLIENT_SECRET)" as NSString
        urlString = "\(urlString)&code=" as NSString
        urlString = "\(urlString)\(code)" as NSString
        print("urlString: \(urlString)")
        
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = NSURL(string: NSString(format: "%@", urlString) as String) as URL?
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request as URLRequest) {
            ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                let response = NSString (data: receivedData, encoding: String.Encoding.utf8.rawValue)
                print("response is \(String(describing: response))")
                do {
                    let getResponse = try JSONSerialization.jsonObject(with: receivedData, options: .allowFragments)  as! [String:Any]
                    print("getResponse is \(getResponse)")
                    
                    if let accessToken = getResponse["access_token"] as? String {
                        self.initSDKWithOAuth(accessTokenReceived: accessToken)
                    } else {
                        
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                }
                break
                
            case 400:
                break
                
            default:
                print("GET request got response \(httpResponse.statusCode)")
            }
        }
        dataTask.resume()
    }
    
    /// Used to extract a substring from the URL
    ///
    /// - Parameter url: URL from which the string is extracted
    /// - Returns: extracted string
    func extractStringFromURL(url: String) -> String
    {
        if let startRange = url.range(of: "="), let endRange = url.range(of: "&"), startRange.upperBound <= endRange.lowerBound {
            let extractedString = url[startRange.upperBound..<endRange.lowerBound]
            return String(extractedString)
        }
        else {
            print("invalid string")
            return ""
        }
    }
    
    
    /// Initializes the SDK with access token received after entering the credentials for OAuth
    ///
    /// - Parameter accessTokenReceived: access token received from the OAuth request
    func initSDKWithOAuth(accessTokenReceived: String)
    {
        // MARK: Note
        // Reach out to the CloverGo team for getting apiKey: and secret: for Sandbox env and set the values of kApiKey and kSecret constants respectively
        SHARED.workingQueue.async() {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.async {
                self.showMessage("Received Access Token \n to \n initalize the SDK")
            }
        }
        SHARED.workingQueue.async() {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.async {
                PARAMETERS.accessToken = accessTokenReceived
                self.showNextVC(storyboardID: "readerSetUpViewControllerID")
            }
        }
    }
    
    func showNextVC(storyboardID:String)
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: storyboardID)
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    private func showMessage(_ message:String, duration:Int = 3) {
        
        DispatchQueue.main.async {
            let alertView:UIAlertView = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
            alertView.show()
            self.perform(#selector(self.dismissMessage), with: alertView, afterDelay: TimeInterval(duration))
        }
        
    }
    
    @objc private func dismissMessage(_ view:UIAlertView) {
        view.dismiss( withClickedButtonIndex: -1, animated: true);
    }
    
    @IBAction func backButton(_ sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
        
    }
}
