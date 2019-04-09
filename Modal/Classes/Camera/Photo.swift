//
//  Photo.swift
//  Modal
//
//  Created by Amir Shayegh on 2019-04-09.
//

import Foundation
import AVFoundation
import CoreLocation

public class Photo {
    public var image: UIImage?
    public var timeStamp: CMTime?
    
    // Azimuth
    public var magneticHeading: Double = -1
    public var trueHeading: Double = -1
    public var headingAccuracy: Double = -1
    
    public var latitude: Double = -1
    public var longitude: Double = -1
    
    public var metadata: [String : Any]
    
    init(image: UIImage, timeStamp: CMTime, location: CLLocation?, heading: CLHeading?, metadata: [String : Any]) {
        self.image = image
        self.timeStamp = timeStamp
        self.metadata = metadata
        
        if let l = location {
            self.latitude = l.coordinate.latitude
            self.longitude = l.coordinate.longitude
        }
        if let h = heading {
            self.magneticHeading = h.magneticHeading
            self.trueHeading = h.trueHeading
            self.headingAccuracy = h.headingAccuracy
        }
    }
}
