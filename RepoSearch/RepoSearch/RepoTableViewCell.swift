//
//  RepoTableViewCell.swift
//  RepoSearch
//
//  Created by Kane on 2022/10/21.
//

import UIKit

class RepoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var forkCountLabel: UILabel!
    @IBOutlet weak var watcherCountLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var ownerAvatarImage: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(githubRepo: GithubRepo) {
        repoNameLabel.text = githubRepo.name
        starCountLabel.text = String(githubRepo.stargazersCount ?? 0)
        forkCountLabel.text = String(githubRepo.forksCount ?? 0)
        watcherCountLabel.text = String(githubRepo.watchersCount ?? 0)
        ownerNameLabel.text = githubRepo.owner.login
        
        if let avatarURL = githubRepo.owner.avatarURL {
            ownerAvatarImage.downloaded(from: avatarURL)
        }
        
        languageLabel.text = githubRepo.language
        descriptionLabel.text = githubRepo.itemDescription
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
