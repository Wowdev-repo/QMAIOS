//
//  TourGuideFloorMap.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/09/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct TourGuideFloorMap: ResponseObjectSerializable, ResponseCollectionSerializable {
    var title: String? = nil
    var accessionNumber: String? = nil
    var nid: String? = nil
    var curatorialDescription: String? = nil
    var diam: String? = nil
    var dimensions: String? = nil
    var mainTitle: String? = nil
    var objectENGSummary: String? = nil
    var objectHistory: String? = nil
    var production: String? = nil
    
    var productionDates: String? = nil
    var image: String? = nil
    var tourGuideId: String? = nil
    
    var artifactNumber : String? = nil
    var artifactPosition : String? = nil
    var audioDescriptif : String? = nil
    var images : [String]? = []
    var audioFile : String? = nil
    var floorLevel: String? = nil
    var galleyNumber: String? = nil
    var artistOrCreatorOrAuthor: String? = nil
    var periodOrStyle: String? = nil
    var techniqueAndMaterials : String? = nil
    var thumbImage : String? = nil
    var artifactImg : Data? = nil
    var language: String?
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.accessionNumber = representation["Accession_Number"] as? String
            self.nid = representation["nid"] as? String
            self.curatorialDescription = representation["Curatorial_Description"] as? String
            self.diam = representation["Diam"] as? String
            self.dimensions = representation["Dimensions"] as? String
            self.mainTitle = representation["Main_Title"] as? String
            self.objectENGSummary = representation["Object_ENG_Summary"] as? String
            self.objectHistory = representation["Object_History"] as? String
            
            self.production = representation["Production"] as? String
            self.productionDates = representation["Production_dates"] as? String
            self.image = representation["Image"] as? String
            self.tourGuideId = representation["tour_guide_id"] as? String
            
            self.artifactNumber = representation["artifact_number"] as? String
            self.artifactPosition = representation["artifact_position"] as? String
            self.audioDescriptif = representation["audio_descriptif"] as? String
            self.images = representation["images"] as? [String]
            self.audioFile = representation["audio_file"] as? String
            
            
            self.floorLevel = representation["floor_level"] as? String
            self.galleyNumber = representation["gallery_number"] as? String
            self.artistOrCreatorOrAuthor = representation["Artist/Creator/Author"] as? String
            self.periodOrStyle = representation["Period/Style"] as? String
            self.techniqueAndMaterials = representation["Technique_&_Materials"] as? String
            self.thumbImage = representation["thumb_Image"] as? String
            
            
            self.language = representation["language"] as? String
            
        }
    }
    
    
    init(entity: FloorMapTourGuideEntity) {
        var imgsArray : [String] = []
        if let imgInfoArray = (entity.imagesRelation?.allObjects) as? [ImageEntity] {
            for info in imgInfoArray {
                if let image = info.image {
                    imgsArray.append(image)
                }
            }
        }
        
        self.title = entity.title
        self.accessionNumber = entity.accessionNumber
        self.nid = entity.nid
        self.curatorialDescription = entity.curatorialDescription
        self.diam = entity.diam
        self.dimensions = entity.dimensions
        self.mainTitle = entity.mainTitle
        self.objectENGSummary = entity.objectEngSummary
        self.objectHistory = entity.objectHistory
        
        self.production = entity.production
        self.productionDates = entity.productionDates
        self.image = entity.image
        self.tourGuideId = entity.tourGuideId //
        self.artifactNumber = entity.artifactNumber
        self.artifactPosition = entity.artifactPosition
        self.audioDescriptif = entity.audioDescriptif
        self.images = imgsArray
        self.audioFile = entity.audioFile
        self.floorLevel = entity.floorLevel
        self.galleyNumber = entity.galleyNumber
        self.artistOrCreatorOrAuthor = entity.artistOrCreatorOrAuthor
        
        self.periodOrStyle = entity.periodOrStyle
        self.techniqueAndMaterials = entity.techniqueAndMaterials
        self.thumbImage = entity.thumbImage
        self.artifactImg = entity.artifactImg
        self.language = entity.language

    }
}

struct TourGuideFloorMaps: ResponseObjectSerializable {
    var tourGuideFloorMap: [TourGuideFloorMap]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.tourGuideFloorMap = TourGuideFloorMap.collection(response: response, representation: data as AnyObject)
        }
    }
}

