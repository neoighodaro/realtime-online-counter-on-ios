# Build a realtime counter for iOS using Pusher

One of the most common elements on applications (web or otherwise) is counters. YouTube, for instance, uses counters to see how many people have viewed a particular video. Facebook also does the same for videos on their platform.

Most of the counters on these sites however, only update the count when you have refreshed the page. This leaves more to be desired, as sometimes, you just want to see the number increase in realtime. This gives you the impression that the item is being viewed by many people at the moment.

In this article, we are going to explore how we can leverage the realtime nature of Pusher, to create a counter that is updated in realtime. We will be creating a video viewer iOS application with a realtime counter on how many people have viewed the video.

![Build a realtime counter for iOS using Pusher](https://dl.dropbox.com/s/skft6umr9kvt12l/realtime-online-counter-on-ios-1.gif)

To follow along, you will need basic knowledge of Swift, Xcode and command line. You will also need to set up a Pusher account, and create an application. You can do so [here](https://pusher.com).

## Creating our realtime counter app using Pusher

To get started you will need Cocoapods installed on your machine. Cocoapods is a package manager and we will be using this to manage the dependencies on the application. To install Cocoapods, type this in your command line:

```shell
$ gem install cocoapods
```

After you are done installing that, launch Xcode and create a new single page application project. Follow the set up wizard, and then once the Xcode project editor is open, close Xcode. `cd` to the root directory of your project and run the command 

```shell
$ pod init
```

This should create a `Podfile` in the root of your project. Open this file in your favorite editor and then update the contents of the file to the following:

```
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'counter' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for counter
  pod 'Alamofire'
  pod 'PusherSwift'

end
```

In the file above we have specified two dependencies: `PusherSwift` and `Alamofire`. These would be useful later in the project. Now to install these dependencies run this comand from your terminal:

```shell
$ pod install
```

After this is complete, you should now have a `.xcworkspace` file in the root directory of your project. Open this file and it should launch Xcode, make sure you don't have any instance of Xcode running for this project before opening the file or you will get an error.

### Creating the views for our realtime application

Now that the project is open, we will create some views for our application. Open the `Main.storyboard` file and in there we will create the views.

We want to create a navigation controller that will have a `ViewController` as the root controller of the navigation controller. Then in the new view controller, we will add a webview; this is where we will be embedding the video we want people to view. We will also add two labels, one for the counter and the other will just be a plain immutable message.

After we are done, this is what we have so far:

![Build a realtime counter for iOS using Pusher](https://dl.dropbox.com/s/mkjjqr1xdv3ske4/realtime-online-counter-on-ios-2.png)

### Adding our realtime feature to our application

Now that we have created the application, we can now add the code that will interact with the views and add the realtime support and the video also.

Create a new `MainViewController` class and link it to the view controller we created above. Then create a split view in Xcode and ctrl+drag from the `webview` to the view controller. This should create an `@IBOutlet` in the controller; do the same for the counter label so it creates another `@IBOutlet`. Our controller should now have two `@IBOutlet`s one for the webview and one for the counter label. Great.

Now we are going to add the code to load our video. We are going to be using a YouTube video of a Pusher tutorial for this exercise. In the `viewDidLoad` method add the following:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    loadYoutube(videoID:"xDQ8vzD0lzw")
}
```

Now lets create the `loadYoutube` method and the other dependent methods:

```swift
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
```

Now we have instructed the application to load a YouTube video automatically. However, the counter functionality does not function yet. Lets fix that. 

Add a new method to update the counter using Pusher:

```Swift
func updateViewCount() {
    let options = PusherClientOptions(
        host: .cluster("PUSHER_CLUSTER")
    )
    
    pusher = Pusher(key: "PUSHER_KEY", options: options)
    
    let channel = pusher.subscribe("counter")
    let _ = channel.bind(eventName: "new_user", callback: { (data: Any?) -> Void in
        if let data = data as? [String: AnyObject] {
            let viewCount = data["count"] as! String
            self.count.text = viewCount
        }
    })
    pusher.connect()
}
```

>  Note: Where it says `PUSHER_CLUSTER` and `PUSHER_KEY`, you should replace with your actual Pusher cluster and key. You'll also need to import 

Now you can just call the `updateViewCount` from the `viewDidLoad` method so it is called when the view is loaded.

After everything, your `MainViewController` should now look a little like this:

```swift
import UIKit
import PusherSwift

class MainViewController: UIViewController {

    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var webview: UIWebView!

    var pusher : Pusher!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadYoutube(videoID:"xDQ8vzD0lzw")
        updateViewCount()
    }
    
    func updateViewCount() {
        let options = PusherClientOptions(
            host: .cluster("PUSHER_CLUSTER")
        )
        
        pusher = Pusher(key: "PUSHER_KEY", options: options)
        
        let channel = pusher.subscribe("counter")
        let _ = channel.bind(eventName: "new_user", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                let viewCount = data["count"] as! String
                self.count.text = viewCount
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
```





