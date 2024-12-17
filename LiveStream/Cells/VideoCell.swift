//
//  VideoCell.swift
//  LiveStream
//
//  Created by Mujahed Ansari on 17/12/24.
//

import UIKit
import  AVFoundation
import Lottie


class VideoCell: UICollectionViewCell {
    static let identifier = "VideoCell"
    
    private let videoPlayerView = AVPlayerLayer()
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let viewersLabel = UILabel()
    private let likesLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let commentsTableView = UITableView()
    private let loaderView = UIActivityIndicatorView(style: .medium)
    
    var player: AVPlayer?
    
    var comments: [Comment] = []// Load from JSON
    var timer: Timer?
    var commentData: Comments?
    var commentsCount = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        if let data = LoadJsonFile().loadJSON(filename: "CommentsData", type: Comments.self) {
            self.commentData = data
        }
        // Configure video player
        videoPlayerView.frame = contentView.bounds
        contentView.layer.addSublayer(videoPlayerView)
        
        // Configure profile image
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileImageView)
        
        // Configure labels
        usernameLabel.font = .boldSystemFont(ofSize: 16)
        usernameLabel.textColor = .gray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)
        
        viewersLabel.font = .systemFont(ofSize: 14)
        viewersLabel.textColor = .gray
        viewersLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewersLabel)
        
        likesLabel.font = .systemFont(ofSize: 14)
        likesLabel.textColor = .gray
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likesLabel)
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Configure comments table
        commentsTableView.backgroundColor = .clear
        commentsTableView.isScrollEnabled = false
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.frame = commentsTableView.bounds
//        commentsTableView.layer.mask = gradientLayer
        commentsTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        commentsTableView.separatorStyle = .none
        commentsTableView.translatesAutoresizingMaskIntoConstraints = false

       
        contentView.addSubview(commentsTableView)
        
        loaderView.color = .gray
        loaderView.startAnimating()
        loaderView.center = contentView.center
        contentView.addSubview(loaderView)
        
        
        setupConstraints()
        showHeartAnimation()
        startAutoScrollingComments()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            viewersLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 8),
            viewersLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            
            likesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likesLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            commentsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            commentsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            commentsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            commentsTableView.heightAnchor.constraint(equalToConstant: 200),
            
        ])
    }
    
    private func setUpObservers() {
        NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewAccessLogEntry,
                object: player?.currentItem,
                queue: .main) { [weak self] _ in
                    self?.loaderView.stopAnimating()
            }
    }
    
    func configure(with video: Video) {
        usernameLabel.text = video.username
        viewersLabel.text = "\(video.viewers) viewers"
        likesLabel.text = "\(video.likes) likes"
        descriptionLabel.text = video.description
        
        if let url = URL(string: video.profilePicURL) {
            // Load profile image asynchronously
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        if let videoURL = URL(string: video.video) {
            player = AVPlayer(url: videoURL)
            videoPlayerView.player = player
            player?.play()
        }
        
        setUpObservers()
     
    } //end function body.
    
    func showHeartAnimation() {
        DispatchQueue.main.async{ [unowned self]  in
            let heartAnimation = LottieAnimationView(name: "heart")
            heartAnimation.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
            heartAnimation.play { finished in
                heartAnimation.removeFromSuperview()
            }
            contentView.addSubview(heartAnimation)
        }
    }
    
  
    func startAutoScrollingComments() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
           
            if (commentData?.comments.count) ?? 0 >  commentsCount {
                self.comments.append(commentData!.comments[commentsCount])
                DispatchQueue.main.async {
                    self.commentsTableView.reloadData()
                    let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
                    self.commentsTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }


}

extension VideoCell : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
                  return UITableViewCell()
              }
              cell.configure(with: comments[indexPath.row])
              return cell
    }
    
    
}
