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
        getMovies(page: 1)
    }
    
    func getMovies(page: Int?) {
        var queryParams = [URLQueryItem]()
        
        if let page = page {
            queryParams.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        let url = ApiClient.createUrl(queryParams: queryParams)!
        print(url)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: URLRequest(url: url), completionHandler: {
            data, response, error in
        
            self.onFetchMoviesComplete(data, response: response, error: error as NSError?)
        })
        task.resume()
    }

    //get all movies
    fileprivate func onFetchMoviesComplete(_ data: Data?, response: URLResponse?, error: NSError?) {
        if error != nil {
            print("An error occurred while loading now playing list: \(String(describing: error?.localizedDescription))")
        }
        else {
            if let rawData = data {
                do {
                    //get response
                    let jsonResponse = try JSONSerialization.jsonObject(with: rawData, options: []) as? [String:Any]
                    //parse data
                    self.page = jsonResponse?["page"] as? Int
                    self.totalPages = jsonResponse?["total_pages"] as? Int
                    //parse results
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
        cell.lblOverview.text = movie.overview
        
        let posterUrl: String = "http://image.tmdb.org/t/p/w185"+movie.posterPath!
        print(posterUrl)
        Downloader.downloadImage(url: URL(string: posterUrl)!, cell: cell)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailFilmVC = segue.destination as! DetailFilmViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let movie = movies[indexPath.row]
                detailFilmVC.filmId = movie.id!
            }
        }
    }

}

class Downloader {
    
    class func downloadImageWithURL(_ url:String) -> UIImage! {
        
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
    
    class func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    class func downloadImage(url: URL, cell: MovieViewCell) -> Void{
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                cell.imgPoster.image = UIImage(data: data)
               //return UIImage(data: data)
            }
        }
    }
}
