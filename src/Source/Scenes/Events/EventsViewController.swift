import UIKit

struct Event: Decodable {
    var name: String
    var urlLink: String
}

class EventsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private var viewModel = EventsViewModel()
    private var events: [Event] = [Event(name: "First",
                                 urlLink: "http://google.com"),
                           Event(name: "Second",
                                 urlLink: "http://google.com")]

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
        cell.detailTextLabel?.text = events[indexPath.row].name
//        let accessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        accessoryView.setImage(UIImage(named: "star.fill"), for: .normal)
//        cell.accessoryView = accessoryView
        return cell
    }
}

extension EventsViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(events[indexPath.row].name)
        if let url = URL(string: events[indexPath.row].urlLink) {
            UIApplication.shared.open(url)
        }
    }

    func tableView(_: UITableView, accessoryButtonTappedForRowWith _: IndexPath) {
        print("AccessoryView")
    }
}
