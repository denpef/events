import UIKit

struct Event: Decodable {
    var name: String
}

class EventsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var events: [Event] = [Event(name: "First"), Event(name: "Second")]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension EventsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        cell.textLabel?.text = events[indexPath.row].name
        return cell
    }
}

extension EventsViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(events[indexPath.row].name)
    }
}
