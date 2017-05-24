//
//  MainViewController.swift
//  onlinecounter
//
//  Created by Neo Ighodaro on 23/05/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import Alamofire
import PusherSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var webview: UIWebView!
    
    var endpoint: String = "http://localhost:4000/update_counter"
    
    var pusher : Pusher!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadYoutube(videoID:"xDQ8vzD0lzw")
        sendViewCount()
        updateViewCount()
    }
    
    func sendViewCount() {
        Alamofire.request(endpoint, method: .post).validate().responseJSON { response in
            switch response.result {
                
            case .success:
                if let result = response.result.value {
                    let data = result as! NSDictionary
                    let viewCount = data["count"] as! NSNumber
                    self.count.text = "\(viewCount)" as String!
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateViewCount() {
        let options = PusherClientOptions(
            host: .cluster("PUSHER_CLUSTER")
        )
        
        pusher = Pusher(key: "PUSHER_KEY", options: options)
        
        let channel = pusher.subscribe("counter")
        let _ = channel.bind(eventName: "new_user", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                let viewCount = data["count"] as! NSNumber
                self.count.text = "\(viewCount)" as String!
            }
        })
        pusher.connect()
    }
    
    func loadYoutube(videoID:String) {
        self.automaticallyAdjustsScrollViewInsets = false
        webview.allowsInlineMediaPlayback = true
        webview.mediaPlaybackRequiresUserAction = false
        let embedHTML = getEmbedHTML(id:videoID);
        
        let url: NSURL = NSURL(string: "https://www.youtube.com/embed/\(videoID)")!
        webview.loadHTMLString(embedHTML as String, baseURL:url as URL )
    }
    
    private func getEmbedHTML(id: String) -> String {
        return "<html><head><style type=\"text/css\">body {background-color: transparent;color: white;}</style></head><body style=\"margin:0\"> <iframe webkit-playsinline width=\"100%\" height=\"100%\" src=\"https://www.youtube.com/embed/\(id)?feature=player_detailpage&playsinline=1\" frameborder=\"0\"></iframe>";
    }
}
