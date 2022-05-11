//
//  MapViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/11.
//

import UIKit
import MapKit
import CoreLocation
import WebKit

class MapViewController: UIViewController {
    private var mapModel = MapModel()
    private var locationManager = CLLocationManager()
    private var currentLocation = CLLocation(latitude: 25.04336042435599, longitude:  121.52270562636868)
    private var isFirstLocation = true
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        self.setLocationManager()
        
        let coordinateRegion = MKCoordinateRegion(center: self.currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsUserLocation = true
        
        mapModel.getAntigenData(result: { antigenData in
            DispatchQueue.main.async {
                antigenData.features.forEach({
                    let location = CLLocation(latitude: $0.geometry.coordinates[1], longitude: $0.geometry.coordinates[0]).coordinate
                    let antigenAnnotation = HaspitalAnnotation(location)
                    
                    antigenAnnotation.title = $0.properties.name
                    antigenAnnotation.subtitle = $0.properties.address
                    antigenAnnotation.haspitalData = $0.properties
                    self.mapView.addAnnotation(antigenAnnotation)
                })
            }
        }, Error: { msg in
            DispatchQueue.main.async {
                print(msg)
                self.checkNetworkAlert()
            }
        })
    }
    
    private func setLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if locationManager.authorizationStatus == .denied {
            self.showNotLocationPermission()
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    private func checkNetworkAlert() {
        let alertController = UIAlertController(title: "Error", message: "Please check network connection", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
    
    private func showNotLocationPermission() {
        let msgTitle = NSLocalizedString("NotLocationPermission", comment: "")
        let msgContent = NSLocalizedString("LocationInfo", comment: "")
        
        let alertController = UIAlertController(title: msgTitle, message: msgContent, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func btnBackEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // click annotation event
        let haspitalAnnotation = view.annotation as! HaspitalAnnotation
        
        let viewController = MainViewController()
        if #available(iOS 15.0, *) {
            if let sheet = viewController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            // Fallback on earlier versions
        }
        
        print(haspitalAnnotation.haspitalData?.address ?? "")
        present(viewController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // custom annotation view
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        
        if let dequedAnnotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequedAnnotationView
            annotationView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "Haspital Icon")
        }
        
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0] as CLLocation
        let coordinateRegion = MKCoordinateRegion(center: self.currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        if isFirstLocation {
            mapView.setRegion(coordinateRegion, animated: true)
            isFirstLocation.toggle()
        }
    }
}
