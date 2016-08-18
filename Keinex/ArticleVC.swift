//
//  ArticleVC.swift
//  Keinex
//
//  Created by Андрей on 9/16/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit
import Alamofire

class ArticleVC: UIViewController, UIWebViewDelegate {

    lazy var json : JSON = JSON.null
    lazy var jsonForComments: JSON = JSON.null
    lazy var scrollView : UIScrollView = UIScrollView()
    lazy var postTitle : UILabel = UILabel()
    lazy var featuredImage : UIImageView = UIImageView()
    lazy var postTime : UILabel = UILabel()
    lazy var postContent : UILabel = UILabel()
    lazy var postContentWeb : UIWebView = UIWebView()
    lazy var generalPadding : CGFloat = 10
    lazy var indexRow : Int = Int()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
                
        if let featured = json["better_featured_image"]["source_url"].string{
            
            featuredImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
            featuredImage.contentMode = .ScaleAspectFill
            featuredImage.clipsToBounds = true

            ImageLoader.sharedLoader.imageForUrl(featured, completionHandler:{(image: UIImage?, url: String) in
                self.featuredImage.image = image
            })
            
            self.scrollView.addSubview(featuredImage)
        }
        
        if let title = json["title"]["rendered"].string {
            
            postTitle.frame = CGRect(x: 10, y: (generalPadding * 2 + featuredImage.frame.height), width:self.view.frame.size.width - 20, height: 50)
            postTitle.textColor = UIColor.mainColor()
            postTitle.textAlignment = NSTextAlignment.Center
            postTitle.font = UIFont.systemFontOfSize(24.0)
            postTitle.numberOfLines = 2
            postTitle.adjustsFontSizeToFitWidth = true
            postTitle.baselineAdjustment = .AlignCenters
            postTitle.minimumScaleFactor = 0.5
            postTitle.text = String(htmlEncodedString:  title)

            self.scrollView.addSubview(postTitle)
        }
        
        if let date = json["date"].string{
            
            postTime.frame = CGRect(x: 0, y: (generalPadding * 3 + postTitle.frame.height + featuredImage.frame.height), width: self.view.frame.size.width, height: 20)
            postTime.textColor = UIColor.grayColor()
            postTime.font = UIFont(name: postTime.font.fontName, size: 12)
            postTime.textAlignment = NSTextAlignment.Center
            postTime.text = date.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)

            self.scrollView.addSubview(postTime)
        }
        
        if let content = json["content"]["rendered"].string{
    
            let webContent : String = "<!DOCTYPE HTML><html><head><title></title><link rel='stylesheet' href='appStyles.css'></head><body>" + content + "</body></html>"
            let mainbundle = NSBundle.mainBundle().bundlePath
            let bundleURL = NSURL(fileURLWithPath: mainbundle)
            
            postContentWeb.loadHTMLString(webContent, baseURL: bundleURL)
            postContentWeb.frame = CGRect(x: 10, y: (generalPadding * 3 + postTitle.frame.height + featuredImage.frame.height + postTime.frame.height), width: self.view.frame.size.width - 20, height: 10)
            postContentWeb.delegate = self
            self.scrollView.addSubview(postContentWeb)
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(ArticleVC.ShareLink))
        self.navigationItem.rightBarButtonItem = shareButton
    }

    func wightValue() -> CGFloat {
        var wightValue = 0.0
        if isiPad {
            wightValue = 1.15
        } else {
            wightValue = 1.25
        }
        return CGFloat(wightValue)
    }
   
    func webViewDidFinishLoad(webView: UIWebView) {
    
        postContentWeb.frame = CGRect(x: 10, y: (generalPadding * 4 + postTitle.frame.height + featuredImage.frame.height + postTime.frame.height), width: self.view.frame.size.width - 20, height: postContentWeb.scrollView.contentSize.height + 100)
        
        var finalHeight : CGFloat = 0
        self.scrollView.subviews.forEach { (subview) -> () in
            finalHeight += subview.frame.height
        }
        self.scrollView.contentSize.height = finalHeight
        
        showCommentsButton()
    }
 
    func showCommentsButton() {
        let commentsButton = UIButton(frame: CGRect(x: self.view.frame.size.width / wightValue(), y: self.view.frame.size.height / 3.15, width: 50, height: 50))
        commentsButton.backgroundColor = UIColor.mainColor()
        commentsButton.setImage(UIImage(named: "Messages.png"), forState: .Normal)
        commentsButton.layer.cornerRadius = 25
        commentsButton.layer.shadowOffset = CGSizeMake(1, 0)
        commentsButton.layer.shadowOpacity = 1.0
        commentsButton.layer.shadowColor = UIColor.mainColor().CGColor
        commentsButton.addTarget(self, action: #selector(commentsButtonAction), forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(commentsButton)
        
        commentsButton.transform = CGAffineTransformMakeScale(0.0, 0.0)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            commentsButton.transform = CGAffineTransformMakeScale(1,1)
        })
    }
    
    func commentsButtonAction(sender: UIButton!) {
        let CommentsVC : ArticleCommentsVC = storyboard!.instantiateViewControllerWithIdentifier("ArticleCommentsVC") as! ArticleCommentsVC
        CommentsVC.indexRow = indexRow
        self.navigationController?.pushViewController(CommentsVC, animated: true)

    }
    
    func ShareLink() {
        let textToShare = json["title"]["rendered"].string! + " "
        
        if let KeinexWebsite = NSURL(string: json["link"].string!) {
            let objectsToShare = [String(htmlEncodedString:  textToShare), KeinexWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height, width: 0, height: 0)
                
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

