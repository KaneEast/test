//
//  ViewController.swift
//  RepoSearch
//
//  Created by Kane on 2022/10/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var repoTableView: UITableView!
    
    var lastRequestTime: Date?
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    @IBAction func didTapSearchButton(_ sender: Any) {
        guard searchTextField.text?.count ?? 0 > 0 else {
            // alert
            return
        }
        
        currentPage = 0
        
        // APIのリクエストにはスロットリング
        if let lastRequestTime = lastRequestTime {
            let comp = Calendar.current.dateComponents([.second], from: lastRequestTime, to: Date())
            if comp.second ?? 0 < 1 {
                return
            }
        }
        lastRequestTime = Date()
        
        Task {
            await RepoRequestManager.shared.findRepos(keyword: "git")
            repoTableView.reloadData()
        }
    }
    
    private func setupTableView() {
        repoTableView.delegate = self
        repoTableView.dataSource = self
        repoTableView.register(UINib(nibName: "RepoTableViewCell", bundle: nil), forCellReuseIdentifier: "RepoTableViewCell")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RepoRequestManager.shared.githubRepo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoTableViewCell") as! RepoTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.configure(githubRepo: RepoRequestManager.shared.githubRepo[indexPath.row])
        
        // Infinite scroll
        if(indexPath.row == RepoRequestManager.shared.githubRepo.count - 1 && indexPath.row != 0) {
            currentPage += 1
            Task {
                await RepoRequestManager.shared.findRepos(keyword: "git", page: currentPage)
                repoTableView.reloadData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        216
    }
}

