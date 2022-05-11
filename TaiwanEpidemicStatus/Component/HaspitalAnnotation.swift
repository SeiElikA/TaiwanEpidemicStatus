//
//  HaspitalAnnotation.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/11.
//

import Foundation
import MapKit
public class HaspitalAnnotation: NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?
    public var haspitalData: Properties?
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
