//
//  MapStorage.swift
//  DemoArcGIS
//
//  Created by Salmdo on 12/28/23.
//

import Foundation
import ArcGIS


protocol MapStorageProtocol {
    func saveMap(map: MapItem) throws
    func deleteMap(mapId: String) throws
    func loadAllMap() throws -> [MapItem]
    func loadMap(id: String) throws -> MapItem?
}

struct CoreDataMapStorage: MapStorageProtocol {
    private let persistent = PersistenceController.instance
    let temporaryDirectory: URL
    
    func saveMap(map: MapItem) throws {
        let results = try persistent.fetchAllMaps()
        if results.filter({ $0.id == map.id }).first == nil {
            let mapSaved = MapOffline(context: persistent.container.viewContext)
            mapSaved.id = map.id
            mapSaved.snippet = map.snippet
            mapSaved.thumbnailUrl = map.thumbnailUrl
            mapSaved.title = map.title
            try persistent.saveMap(map: mapSaved)
        }
    }
    
    func deleteMap(mapId: String) throws {
        try persistent.deleteMap(id: mapId)
    }
    
    func loadAllMap() throws -> [MapItem] {
        let results = try persistent.fetchAllMaps()
        return results.compactMap { OfflineStoredMap(offlineModel: $0, mapStorage: self, temporaryDirectory: temporaryDirectory)}
    }
    
    func loadMap(id: String) throws -> MapItem? {
        let results = try persistent.fetchAllMaps()
        if let item = results.filter({ $0.id == id }).first {
            return OfflineStoredMap(offlineModel: item, mapStorage: self, temporaryDirectory: temporaryDirectory)
        }
        return nil
    }
    
    
}
