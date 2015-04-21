//
//  MoviesViewController.swift
//  Tomatoes
//
//  Created by Rohit Bhoompally on 4/14/15.
//  Copyright (c) 2015 Rohit Bhoompally. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBarBO: UISearchBar!
    var searchActive : Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    var movies : [NSDictionary]?
    var filteredResults: [NSDictionary]?
    
    var refreshControl: UIRefreshControl!
    var networkErrorView : UIView!
    
    var isMoviesScene: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        prepareErrorView()
        
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)

        tableView.dataSource = self
        tableView.delegate = self
        searchBarBO.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        tabBarController?.tabBar.hidden = false
        var selectedIndex = tabBarController?.selectedIndex
        isMoviesScene = isMoviesSelected(selectedIndex!)
        makeRottenTomatoesApiCall(isMoviesScene, isRefreshing: false)
    }
    
    func isMoviesSelected(selectedIndex: Int) -> Bool {
        if selectedIndex == 0 {
            return true
        } else {
            return false
        }
    }
    
    func makeRottenTomatoesApiCall(isMoviesScene: Bool, isRefreshing: Bool) {
        var url: NSURL
        if isMoviesScene {
            url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=US")!
        } else {
            url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=US")!
        }
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if isRefreshing {
                self.refreshControl.endRefreshing()
            } else {
                SVProgressHUD.dismiss()
            }
            
            if error != nil {
                self.showError()
                return
            } else {
                self.hideError()
            }
            
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            if let json = json {
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
            }
            println("Called")
        }
    }
    
    private func prepareErrorView() {
        networkErrorView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.width, height:30))
        networkErrorView.backgroundColor = UIColor.grayColor()
        networkErrorView.alpha = 0.9
        
        var label = UILabel(frame: networkErrorView.frame)
        label.text = "Network Error. Please pull to refresh."
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: label.font.fontName, size: 14)
        
        label.textColor = UIColor.whiteColor()
        self.networkErrorView.addSubview(label)
    }
    
    private func showError() {
        self.tableView.addSubview(networkErrorView)
    }
    
    private func hideError() {
        if networkErrorView.superview != nil {
            networkErrorView.removeFromSuperview()
        }
    }
    
    func onRefresh() {
        makeRottenTomatoesApiCall(self.isMoviesScene, isRefreshing: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredResults!.count
        }
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        var cellMovie: NSDictionary
        if(searchActive){
            cellMovie = filteredResults![indexPath.row]
        } else {
            cellMovie = movies![indexPath.row]
        }
        
        cell.titleLabel.text = cellMovie["title"] as? String
        cell.synopsisLabel.text = cellMovie["synopsis"] as? String
        
        let url = NSURL(string: cellMovie.valueForKeyPath("posters.thumbnail") as! String)!
        var urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: url)
       
        cell.posterView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            if urlRequest != request {
                cell.posterView.image = image
                println("Cached")
            } else {
                UIView.transitionWithView(cell.posterView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    cell.posterView.image = image
                }, completion: nil)
                println("Network")
            }
            }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchActive = false
            return
        }

        filteredResults = movies!.filter({ (movie) -> Bool in
            let tmp: NSString = movie["title"] as! NSString
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        if(filteredResults!.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }
}
