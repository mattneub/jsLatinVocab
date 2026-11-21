import UIKit

/// Subclass of diffable data source that implements `sectionIndexTitles` for the All Terms module.
/// The problem being solved here is that if we are compelled to show the terms list in portrait,
/// the default way of showing an index (one letter per section) is just too tall for the space.
/// So we clump them into threes. We only need to do this on iPad; on iPhone, we can show the
/// terms list in portrait.
final class AllTermsIndexedDatasource: UITableViewDiffableDataSource<String, Int> {
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if snapshot().itemIdentifiers.isEmpty {
            return nil
        }
        if tableView.traitCollection.userInterfaceIdiom == .pad {
            return [
                "A B C",
                "•",
                "D E F",
                "•",
                "G H I",
                "•",
                "L M N",
                "•",
                "O P Q",
                "•",
                "R S T",
                "•",
                "U",
            ]
        }
        return snapshot().sectionIdentifiers.map { $0 + "\u{2800}" }
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return snapshot().sectionIdentifiers.firstIndex(where: { section in section == title.prefix(1) }) ?? -1
    }
}

