// Copyright 2015 IBM Corp. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let backend_GUID = NSBundle.mainBundle().objectForInfoDictionaryKey("Backend_GUID") as! String
        let backend_Route = NSBundle.mainBundle().objectForInfoDictionaryKey("Backend_Route") as! String
        IMFClient.sharedInstance().initializeWithBackendRoute(backend_Route, backendGUID: backend_GUID)
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        IMFLogger.send() 
        IMFAnalytics.sharedInstance().sendPersistedLogs()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    var topic:String = "bluemix"
    
    func application(application: UIApplication!, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]!, reply: (([NSObject : AnyObject]?) -> Void)) {
        
        let sentimentObject: AnyObject? = userInfo["sentiment"]
        let topicObject: AnyObject? = userInfo["topic"]
        if sentimentObject != nil {
            let sentimentString = sentimentObject as! String
            let viewModel = ViewModel()
            viewModel.sentiment = sentimentString
            viewModel.topic = self.topic
            
            viewModel.fetchTweets {
                dispatch_async(dispatch_get_main_queue()) {
                    var output = Dictionary<String,String>()
                    let tweets:[Tweet]? = viewModel.tweetsData
                    
                    if (tweets != nil) {
                        var tweetsData:[Tweet] = tweets!
                        for (var i = 0; i < tweetsData.count; i++) {
                            let number = i as NSNumber
                            output["tweet" + number.stringValue + ".authorName"] = tweetsData[i].authorName
                            
                            var message = tweetsData[i].message
                            if message.lowercaseString.rangeOfString("http") != nil {
                                let index = message.rangeOfString("http")?.startIndex
                                message = message.substringToIndex(index!)
                            }
                            if message.lowercaseString.rangeOfString("https") != nil {
                                let index = message.rangeOfString("https")?.startIndex
                                message = message.substringToIndex(index!)
                            }
                            output["tweet" + number.stringValue + ".message"] = message
                        }
                    }
                    output["topic"] = self.topic
                    reply(output)
                }
            }
        }
        if topicObject != nil {
            var output = Dictionary<String,String>()
            output["topic"] = self.topic
            reply(output)
        }
    }
}
