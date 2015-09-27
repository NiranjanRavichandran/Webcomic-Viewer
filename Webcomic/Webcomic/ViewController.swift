//
//  ViewController.swift
//  Webcomic
//
//  Created by Niranjan Ravichandran on 22/09/15.
//  Copyright © 2015 Adavers. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var comicImageView: UIImageView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var comicTitle: UILabel!
    @IBOutlet var nextStrip: UIButton!
    @IBOutlet var prevStrip: UIButton!
    @IBOutlet var randomStrip: UIButton!
    var comicStrip: ComicStrip?
    var urlIndex: Int = 100
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 10
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("nextAction:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("prevAction:"))
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
        
        if Reachability.isConnectedToNetwork(){
            
            let url = NSURL(string: "http://xkcd.com/100/info.0.json")
            restAPICall(url!)
            showActivityIndicator()
        }
        
        
    }
    
    func restAPICall(url: NSURL){
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, response, error) -> Void in
            
            if error != nil{
                if error?.code == -1009{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayErrorPage()
                    })
                }else{
                    print(error?.localizedDescription)
                }
                
            }else{
                let jsonResponse = try! NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                self.comicStrip = ComicStrip(jsonResponse: jsonResponse)
                NSURLSession.sharedSession().dataTaskWithURL(self.comicStrip!.imgURL!, completionHandler: { (imageData, imageResponse, imageError) -> Void in
                    if imageData != nil{
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            UIView.animateWithDuration(0.4, animations: { () -> Void in
                                self.actInd.stopAnimating()
                                self.comicImageView.image = UIImage(data: imageData!)
                                self.comicImageView.alpha = 1
                                self.comicTitle.text = self.comicStrip!.title
                                print(self.comicStrip!.transcript!)
                            })
                            
                        })
                    }
                }).resume()
                
            }
            }.resume()
        
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        
        fadeAnimation()
        urlIndex++
        restAPICall(NSURL(string: "http://xkcd.com/\(urlIndex)/info.0.json")!)
        
    }
    
    
    func tryAgainAction(){
        
        for subview in self.view.subviews{
            if subview.tag == 100{
                subview.removeFromSuperview()
            }
        }
        nextAction(self)
    }
    
    @IBAction func prevAction(sender: AnyObject) {
        fadeAnimation()
        self.urlIndex--
        self.restAPICall(NSURL(string: "http://xkcd.com/\(self.urlIndex)/info.0.json")!)
        
    }
    
    @IBAction func loadRandomAction(sender: AnyObject) {
        
        restAPICall(NSURL(string: "http://xkcd.com/\(Int(arc4random_uniform(1000)))/info.0.json")!)
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    func fadeAnimation(){
        
        UIView.animateWithDuration(0.4) { () -> Void in
            self.comicImageView.alpha = 0.3
            self.showActivityIndicator()
        }
    }
    
    func displayErrorPage(){
        
        let blurredeffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurredView = UIVisualEffectView(effect: blurredeffect)
        let errorMessage: UILabel = UILabel(frame: CGRectMake(0, 0, 320, 50))
        let errorImage = UIImageView(image: UIImage(named: "sad.png"))
        let tryAgain = UIButton(frame: CGRectMake(0, 0, 80, 30))
        
        UIView.animateWithDuration(0.8, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            blurredView.bounds = UIScreen.mainScreen().bounds
            blurredView.center = self.view.center
            blurredView.backgroundColor = UIColor.redColor()
            blurredView.tag = 100
            
            errorMessage.numberOfLines = 2
            errorMessage.text = "Oops! Please check your internet connection and try again."
            errorMessage.textColor = UIColor.whiteColor()
            errorMessage.textAlignment = NSTextAlignment.Center
            errorMessage.center = blurredView.center
            errorImage.center = blurredView.center
            errorImage.center.y = blurredView.center.y - 80
            errorImage.alpha = 0
            
            tryAgain.setTitle("Try Again", forState: UIControlState.Normal)
            tryAgain.center = blurredView.center
            tryAgain.center.y = blurredView.center.y + 50
            tryAgain.addTarget(self, action: "tryAgainAction", forControlEvents: .TouchUpInside)
            self.view.addSubview(blurredView)
            blurredView.addSubview(tryAgain)
            blurredView.addSubview(errorMessage)
            
            }) { (Bool) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    blurredView.addSubview(errorImage)
                    errorImage.alpha = 1
                })
        }
        
    }
    
    func showActivityIndicator(){
        
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(actInd)
        actInd.startAnimating()
    }
    
    @IBAction func openInBrowser(sender: AnyObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Open comic in browser?", preferredStyle: .Alert)
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        //Create and an open action
        actionSheetController.addAction(UIAlertAction(title: "Open", style: .Default) { action -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "http://xkcd.com/\(self.urlIndex)")!)
            })
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
}
