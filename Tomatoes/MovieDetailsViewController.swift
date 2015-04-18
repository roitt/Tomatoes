//
//  MovieDetailsViewController.swift
//  Tomatoes
//
//  Created by Rohit Bhoompally on 4/17/15.
//  Copyright (c) 2015 Rohit Bhoompally. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailPosterView: UIImageView!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize back button
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]


        // Load low-res image immediately
        var urlString = movie.valueForKeyPath("posters.thumbnail") as? String
        detailPosterView.setImageWithURL(NSURL(string: urlString!))
        
        // Set text labels
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String

        // Now load high-res
        var range = urlString!.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlString = urlString!.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        let url = NSURL(string: urlString!)
        detailPosterView.setImageWithURL(url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
