import UIKit

/// Chief presenter for the all terms module, displaying a table view that lists all terms.
/// The user can choose one to navigate to it.
final class AllTermsViewController: UITableViewController, ReceiverPresenter {
    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Receiver<AllTermsAction>)?

    /// Our data source object. It is lazily created when we receive our first `present` call.
    lazy var datasource: any AllTermsDatasourceType<AllTermsState> = AllTermsDatasource(
        tableView: tableView,
        processor: processor
    )

    init() {
        super.init(style: .plain)
        tableView.backgroundColor = .myGolden.withAlphaComponent(1) // picked up by nav bar and headers
        tableView.sectionIndexColor = .black
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
        Task {
            await processor?.receive(.initialInterface)
        }
    }

    func present(_ state: AllTermsState) async {
        await datasource.present(state)
    }

    @objc func cancel() {
        Task {
            await processor?.receive(.cancel)
        }
    }

}
