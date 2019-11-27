//
//  ViewController.swift
//  Events
//
//  Created by Denis Efimov on 11/27/19.
//  Copyright © 2019 Denis Efimov. All rights reserved.
//

import UIKit

struct Event: Decodable {
    var name: String
}

class EventsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var events: [Event] = [Event(name: "First"), Event(name: "Second")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension EventsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        cell.textLabel?.text = events[indexPath.row].name
        return cell
    }
}

extension EventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(events[indexPath.row].name)
    }
}

