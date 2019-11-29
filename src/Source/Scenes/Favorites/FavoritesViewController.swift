import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private var data = ["1", "2"]
    private var storage = LocalStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(storage.getFavorites())
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}
