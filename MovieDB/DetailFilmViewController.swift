//
//  DetailFilmViewController.swift
//  MovieDB
//
//  Created by Cntt03 on 5/13/17.
//  Copyright © 2017 Duy Bùi. All rights reserved.
//

import UIKit

class DetailFilmViewController: UIViewController {

    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgPoster: UIImageView!
    var filmId: Int = 0
    var movie: Movie!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let url = ApiClient.getDetailFilm(filmId: filmId)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: URLRequest(url: url!), completionHandler: {
            data, response, error in
            
            self.onFetchMovieDetailComplete(data, response: response, error: error as NSError?)
        })
        task.resume()
    }
    
    fileprivate func onFetchMovieDetailComplete(_ data: Data?, response: URLResponse?, error: NSError?) {
        print("A")
        if error != nil {
            print("An error occurred while loading now playing list: \(String(describing: error?.localizedDescription))")
        }
        else {
            if let rawData = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: rawData, options: [])
                    movie = Movie(parsedJson: jsonResponse as! [String : AnyObject])
                    //load data
                    lblTitle.text = movie.title
                    let posterUrl: String = "https://image.tmdb.org/t/p/w780"+movie.posterPath!
                    downloadImage(url: URL(string: posterUrl)!)
                }
                catch let error as NSError {
                    // Handle JSON parsing error
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) -> Void{
            getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imgPoster.image = UIImage(data: data)
                //return UIImage(data: data)
            }
        }
    }
}


