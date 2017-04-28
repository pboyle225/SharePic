//
//  UsersViewController.swift
//  SharePic
//
//  Created by Patrick Boyle on 4/21/17.
//  Copyright © 2017 Patrick Boyle. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!;
    @IBOutlet weak var logoutButton: UIBarButtonItem!;
    
    var users = [User]();

    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        retrieveUsers();
    }
    
    func retrieveUsers(){
        let ref = FIRDatabase.database().reference();
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let usersDatabase = snapshot.value as! [String : AnyObject];
            self.users.removeAll(); //clear list before iterating over users in database
            
            for (_, value) in usersDatabase
            {
                if let uid = value["uid"] as? String
                {
                    if uid != FIRAuth.auth()!.currentUser!.uid
                    {
                        let userToShow = User();
                        
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String
                        {
                            userToShow.fullName = fullName;
                            userToShow.imagePath = imagePath;
                            userToShow.userID = uid;
                            self.users.append(userToShow);
                        }
                    }
                
                }
            }
            
            self.tableView.reloadData();
        })
        
        ref.removeAllObservers();
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell;
        
        cell.nameLabel.text = self.users[indexPath.row].fullName;
        cell.userID = self.users[indexPath.row].userID;
        cell.userImage.downloadImage(from: self.users[indexPath.row].imagePath!);
        
        checkFollowing(indexPath: indexPath);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid;
        let ref = FIRDatabase.database().reference();
        let key = ref.child("users").childByAutoId().key;
        
        var isFollower = false;
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject]
            {
                for(ke, value) in following
                {
                    if value as! String == self.users[indexPath.row].userID
                    {
                        isFollower = true;
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue(); //remove follower
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(ke)").removeValue();
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none;
                    }
                }
            }
            
            //Follow user since he is not being followed
            
            if !isFollower
            {
                let following = ["following/\(key)" : self.users[indexPath.row].userID];
                let followers = ["followers/\(key)" : uid];
                
                ref.child("users").child(uid).updateChildValues(following);
                ref.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers);
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark;
            }
        })
        
        ref.removeAllObservers();
    }
    
    func checkFollowing(indexPath: IndexPath)
    {
        let uid = FIRAuth.auth()!.currentUser!.uid;
        let ref = FIRDatabase.database().reference();
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject]
            {
                for(ke, value) in following
                {
                    if value as! String == self.users[indexPath.row].userID
                    {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark;
                    }
                }
            }
        })
    }
}


extension UIImageView
{
    func downloadImage(from imgURL: String!)
    {
        let url = URLRequest(url: URL(string: imgURL)!);
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                print(error!);
                return;
            }
            
            DispatchQueue.main.sync {
                self.image = UIImage(data: data!);
            }
        }
        
        task.resume();
    }
}
