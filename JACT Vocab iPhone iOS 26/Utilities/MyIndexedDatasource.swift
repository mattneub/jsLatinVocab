import UIKit

/// Subclass of diffable data source that implements `sectionIndexTitles`.
final class MyIndexedDatasource<T, U>: UITableViewDiffableDataSource<T, U> where T: Hashable & Sendable, U: Hashable & Sendable {
    override func sectionIndexTitles(for _: UITableView) -> [String]? {
        if snapshot().itemIdentifiers.isEmpty {
            return nil
        }
        // I can imagine we might make this work for non-String section identifiers if needed,
        // for example by letting the client set a transform function
        return snapshot().sectionIdentifiers as? [String]
    }
}

