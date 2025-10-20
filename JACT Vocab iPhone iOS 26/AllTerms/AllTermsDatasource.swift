import UIKit

/// Protocol describing the view controller's interaction with the datasource, so we can
/// mock it for testing.
protocol AllTermsDatasourceType<State>: Presenter, UITableViewDelegate {
    associatedtype State
}

/// Table view data source and delegate for the view controller's table view.
final class AllTermsDatasource: NSObject, AllTermsDatasourceType {
    typealias State = AllTermsState

    /// Processor to whom we can send action messages.
    weak var processor: (any Receiver<AllTermsAction>)?

    /// Weak reference to the table view.
    weak var tableView: UITableView?

    /// Reuse identifiers for the table view cells we will be creating.
    private let reuseIdentifier = "reuseIdentifier"
    private let headerReuseIdentifier = "headerReuseIdentifier"

    init(tableView: UITableView, processor: (any Receiver<AllTermsAction>)?) {
        self.tableView = tableView
        self.processor = processor
        super.init()
        // We're going to use a diffable data source. Register the cell type, make the
        // diffable data source, and set the table view's dataSource and delegate.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        datasource = createDataSource(tableView: tableView)
        tableView.dataSource = datasource
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.sectionHeaderHeight = 30
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = .black
        tableView.sectionIndexTrackingBackgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.topEdgeEffect.style = .hard
    }

    func present(_ state: AllTermsState) async {
        await configureData(terms: state.terms)
    }

    var data = [Term]()

    /// Type of the diffable data source.
    typealias Datasource = MyIndexedDatasource<String, Int>

    /// Retain the diffable data source.
    var datasource: Datasource!

    func createDataSource(tableView: UITableView) -> Datasource {
        let datasource = Datasource(tableView: tableView) { [unowned self] tableView, indexPath, identifier in
            return cellProvider(tableView, indexPath, identifier)
        }
        return datasource
    }

    func configureData(terms: [Term]) async {
        // We only need to do this once.
        var snapshot = NSDiffableDataSourceSnapshot<String, Int>()
        guard snapshot.itemIdentifiers.isEmpty else {
            return
        }
        let betaSorter = SwiftSortDescriptor<Term>.sortFunction { $0.beta }
        let lessonSorter = SwiftSortDescriptor<Term>.sortFunction { $0.lessonSection }
        let sortFunctions = SwiftSortDescriptor<Term>.combine([betaSorter, lessonSorter])
        let terms = terms.sorted(by: sortFunctions)
        self.data = terms
        // TODO: wouldn't this work for lesson list too? no?
        let dictionary = Dictionary(grouping: terms, by: { $0.beta.prefix(1).uppercased() })
        let sections = Array(dictionary).sorted { $0.key < $1.key }
        for section in sections {
            snapshot.appendSections([section.key])
            snapshot.appendItems(section.value.map { $0.indexOrig })
        }
        await datasource?.apply(snapshot, animatingDifferences: false)
        // what we have now is a datasource whose sections are section title string values and
        // whose items are `indexOrig` values of terms that live in our `data` array
    }

    func cellProvider(_ tableView: UITableView, _ indexPath: IndexPath, _ identifier: Int) -> UITableViewCell? {
        guard let term = data.first(where: { $0.indexOrig == identifier }) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.contentConfiguration = UIListContentConfiguration.subtitleCell().configured {
            $0.text = term.latin
            $0.textProperties.font = UIFont(name:"Times New Roman", size: 18) ?? UIFont.systemFont(ofSize: 18)
            $0.textProperties.color = .black
            $0.secondaryText = String(format: "%@ — %@%@", term.english, term.lesson, term.sectionFirstWord)
            $0.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
            $0.secondaryTextProperties.lineBreakMode = .byTruncatingMiddle
            $0.secondaryTextProperties.color = .black
            $0.directionalLayoutMargins = .init(top: 2, leading: 0, bottom: 6, trailing: 0)
        }
        cell.backgroundConfiguration = .listCell().configured {
            $0.backgroundColorTransformer = .init { color in
                if cell.configurationState.isHighlighted || cell.configurationState.isSelected {
                    return UIColor.blue.withAlphaComponent(0.8)
                }
                return .myPaler
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) else {
            return nil
        }
        view.contentConfiguration = UIListContentConfiguration.header().configured {
            $0.text = datasource.sectionIdentifier(for: section)
            $0.textProperties.color = .darkGray
            $0.directionalLayoutMargins = .zero
        }
        view.backgroundConfiguration = .listHeader().configured {
            $0.backgroundColor = UIColor.myGolden.withAlphaComponent(1)
        }
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identifier = datasource.itemIdentifier(for: indexPath) else {
            return
        }
        Task {
            try? await unlessTesting {
                try? await Task.sleep(for: .seconds(0.1))
            }
            tableView.deselectRow(at: indexPath, animated: true)
            await processor?.receive(.termChosen(identifier))
        }
    }

}
