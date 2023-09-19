
import Foundation

extension FileManager {

    enum ContentDate {
        case created, modified, accessed

        var resourceKey: URLResourceKey {
            switch self {
            case .created: return .creationDateKey
            case .modified: return .contentModificationDateKey
            case .accessed: return .contentAccessDateKey
            }
        }
    }

    func contentsOfDirectory1(atURL url: URL, sortedBy: ContentDate, ascending: Bool = true, options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]) throws -> [String]? {

        let key = sortedBy.resourceKey

        var files = try contentsOfDirectory(at: url, includingPropertiesForKeys: [key], options: options)

        try files.sort {

            let values1 = try $0.resourceValues(forKeys: [key])
            let values2 = try $1.resourceValues(forKeys: [key])

            if let date1 = values1.allValues.first?.value as? Date, let date2 = values2.allValues.first?.value as? Date {

                return date1.compare(date2) == (ascending ? .orderedAscending : .orderedDescending)
            }
            return true
        }
        return files.map { $0.lastPathComponent }
    }
}
