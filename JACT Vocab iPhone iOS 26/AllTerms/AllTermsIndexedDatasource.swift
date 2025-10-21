import UIKit

/// Subclass of diffable data source that implements `sectionIndexTitles` for the All Terms module.
/// The problem being solved here is that if we are compelled to show the terms list in portrait,
/// the default way of showing an index (one letter per section) is just too tall for the space.
/// So we clump them into threes.
final class AllTermsIndexedDatasource: UITableViewDiffableDataSource<String, Int> {
    override func sectionIndexTitles(for _: UITableView) -> [String]? {
        if snapshot().itemIdentifiers.isEmpty {
            return nil
        }
        return [
            "\u{391} \u{392} \u{393}",
            "•",
            "\u{394} \u{395} \u{396}",
            "•",
            "\u{397} \u{398} \u{399}",
            "•",
            "\u{39A} \u{39B} \u{39C}",
            "•",
            "\u{39D} \u{39E} \u{39F}",
            "•",
            "\u{3A0} \u{3A1} \u{3A3}",
            "•",
            "\u{3A4} \u{3A5} \u{3A6}",
            "•",
            "\u{3A7} \u{3A8} \u{3A9}",
        ]
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return snapshot().sectionIdentifiers.firstIndex(where: { section in section == title.prefix(1) }) ?? -1
    }
}

