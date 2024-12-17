//
//  LiveStreamViewController.swift
//  LiveStream
//
//  Created by Mujahed Ansari on 17/12/24.
//

import UIKit
import AVKit

class LiveStreamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var videos: [Video] = []
    private var  previousCell: VideoCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadVideos()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = view.frame.size
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        view.addSubview(collectionView)
    }
    
    private func loadVideos() {
        // Load video data (mock JSON for now)
        if let data = LoadJsonFile().loadJSON(filename: "videosData", type: Videos.self) {
            videos = data.videos
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
        if previousCell != nil {
            previousCell?.player?.pause()
        }
        previousCell = cell
        cell.configure(with: videos[indexPath.item])
        return cell
    }
    
}
