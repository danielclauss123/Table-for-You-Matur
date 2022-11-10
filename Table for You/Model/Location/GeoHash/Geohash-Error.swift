import Foundation

extension Geohash {
    enum GeohashError: Error, LocalizedError {
        case noNeighborBuckets
        
        var errorDescription: String? {
            switch self {
            case .noNeighborBuckets:
                return "There are no neighbor buckets for the given geo hash."
            }
        }
    }
}
