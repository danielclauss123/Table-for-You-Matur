/*
 Abstract:
    Ein Actor der das Yelp Laden übernimmt und die geladenen Restaurants cached.
 Quelle:
    Gemacht nach Apple Developer Session: "Protect mutable state with Swift actors".
*/

import Foundation

/// The actor that manages loading and caching the yelp restaurants.
actor YelpRestaurantStore {
    private var cache = [String: CacheEntry]()
    
    /// The shared instance of the store.
    static let shared = YelpRestaurantStore()
    
    /// The initializer is private, because there should be only one shared instance.
    private init() { }
    
    /*/// Loads the given restaurants concurrently from either the cache or the yelp server.
    func loadRestaurants(withIds ids: [String]) async throws -> [YelpRestaurantDetail] {
        var restaurants = [YelpRestaurantDetail]()
        
        try await withThrowingTaskGroup(of: YelpRestaurantDetail.self) { group in
            for id in ids {
                group.addTask {
                    return try await self.loadRestaurant(withId: id)
                }
            }
            
            for try await restaurant in group {
                restaurants.append(restaurant)
            }
        }
        
        return restaurants
    }*/
    
    /// Loads the given restaurants concurrently from either the cache or the yelp server. If the loading fails, the restaurant gets skipped, and the rest of them still get loaded.
    func loadRestaurants(withIds ids: [String]) async -> [YelpRestaurantDetail] {
        var restaurants = [YelpRestaurantDetail]()
        
        await withTaskGroup(of: YelpRestaurantDetail?.self) { group in
            for id in ids {
                group.addTask {
                    do {
                        return try await self.loadRestaurant(withId: id)
                    } catch {
                        print("Failed to load yelp restaurant \(id). Error: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
            
            for await restaurant in group {
                if let restaurant = restaurant {
                    restaurants.append(restaurant)
                }
            }
        }
        
        return restaurants
    }
    
    /// Loads the yelp restaurant from either the cache or the yelp server.
    func loadRestaurant(withId id: String) async throws -> YelpRestaurantDetail {
        if let cached = cache[id] {
            switch cached {
                case .ready(let restaurant):
                    return restaurant
                case .inProgress(let task):
                    return try await task.value
            }
        }
        
        let task = Task {
            try await URLSession.shared.restaurantDetails(forYelpId: id)
        }
        
        cache[id] = .inProgress(task)
        
        do {
            let restaurant = try await task.value
            cache[id] = .ready(restaurant)
            return restaurant
        } catch {
            cache[id] = nil
            throw error
        }
    }
    
    /// Represents the different states for the restaurants in the cache.
    ///
    /// Either they were loaded before (ready), or they are being loaded right now (inProgress).
    private enum CacheEntry {
        case inProgress(Task<YelpRestaurantDetail, Error>)
        case ready(YelpRestaurantDetail)
    }
}
