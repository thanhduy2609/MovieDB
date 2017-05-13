//
//  ListMovieTableViewController.swift
//  MovieDB
//
//  Created by Duy Bùi on 5/12/17.
//  Copyright © 2017 Duy Bùi. All rights reserved.
//

import UIKit

class ListMovieTableViewController: UITableViewController {
    
    var allMovie = [Movie]()
    var movePath: String?
    var isFetchingMovies = false
    var page: Int?
    var totalPages: Int?
    var movies = [Movie]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
        getMovies()
    }

    func getMovies() {
        
//        Movie.getMovies(page: 1) {
//            (data, response, error) in
//            self.onFetchMoviesComplete(data, response: response, error: error)
//        }
        
        getMovies(page: 1)
    }
    
    func getMovies(page: Int?) {
        var queryParams = [URLQueryItem]()
        
        if let page = page {
            queryParams.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        let url = ApiClient.createUrl(queryParams: queryParams)!
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: URLRequest(url: url), completionHandler: {
            data, response, error in
        
            self.onFetchMoviesComplete(data, error: error as! NSError)
        })
        task.resume()
    }

    fileprivate func onFetchMoviesComplete(_ data: Data?, error: NSError?) {
        isFetchingMovies = true
        print("A")
        if error != nil {
            print("An error occurred while loading now playing list: \(String(describing: error?.localizedDescription))")
        }
        else {
            if let rawData = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:Any]
                    
                    self.page = jsonResponse?["page"] as? Int
                    self.totalPages = jsonResponse?["total_pages"] as? Int
                    
                    if let moviesJson = jsonResponse?["results"] as? [[String: AnyObject]] {
                        for movieJson in moviesJson {
                            self.allMovie.append(Movie(parsedJson: movieJson))
                        }
                        self.movies = allMovie
                    }
                    
                }
                catch let error as NSError {
                    // Handle JSON parsing error
                    print("\(error.localizedDescription)")
                }
            }
        }
        
        // Refresh table view on the main UI thread
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as!MovieViewCell
        
        let movie = movies[indexPath.row]
        
        cell.lblTitle.text = movie.title
        cell.lblOverview.text = movie.posterPath
        
        let posterUrl: String = "http://image.tmdb.org/t/p/w185"+movie.posterPath!
        cell.imgPoster.image = Downloader.downloadImageWithURL(posterUrl)
        return cell
    }

}

class Downloader {
    
    class func downloadImageWithURL(_ url:String) -> UIImage! {
        
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
}
