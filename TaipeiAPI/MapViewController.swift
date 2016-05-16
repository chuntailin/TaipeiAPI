//
//  MapViewController.swift
//  TaipeiAPI
//
//  Created by Chun Tie Lin on 2016/5/11.
//  Copyright © 2016年 ChunTaiLin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var siteNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var siteArray = [Site]()
    var siteAddress: String!
    var siteInformation = [String : Site]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        self.setInitialStyle()
        self.fetchData("201d8ae8-dffc-4d17-ae1f-e58d8a95b162")
        
    }
    
    
    // MARK: - Fetch Data
    
    func fetchData(id: String) {
        
        ServerManager.getSites(
            idString: id,
            completion:{
                [weak self] (sites) in
                if let weakSelf = self{
                    weakSelf.siteArray = sites
                    weakSelf.addAnnotations(weakSelf.siteArray)
                    weakSelf.siteNumberLabel.text = "目前共有\(weakSelf.siteArray.count)處在施工中"
                }
            },
            failure: { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    print("Get error when call ServerManager.getSites, error : \(error)")
                })
        })
    }
    
    
    // MARK: - MapView Delegate
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("Pin")
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView?.backgroundColor = UIColor.redColor()
        } else {
            annotationView?.annotation = annotation
        }
        
        let detailButton = UIButton(type: .DetailDisclosure)
        detailButton.frame = CGRectMake(0, 0, 44, 50)
        detailButton.tintColor = UIColor.whiteColor()
        detailButton.backgroundColor = UIColor.grayColor()
        annotationView?.rightCalloutAccessoryView = detailButton
        
        return annotationView
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: true)
            
            performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        siteAddress = view.annotation?.subtitle!
        
        let request = MKDirectionsRequest()
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil))
        request.source = sourceItem
        
        let site = siteInformation[siteAddress]
        let locationCoordinates = CLLocationCoordinate2D(latitude: (site?.coordinate[0])!, longitude: (site?.coordinate[1])!)
        
        
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: locationCoordinates, addressDictionary: nil))
        
        
        request.destination = destinationItem
        request.requestsAlternateRoutes = false
        request.transportType = .Transit
        
        mapView.setCenterCoordinate(locationCoordinates, animated: true)
        
        
        let directions = MKDirections(request: request)
        
        directions.calculateETAWithCompletionHandler { response, error in
            if let error = error {
                print("Error while requesting ETA : \(error.localizedDescription)")
            } else {
                self.etaLabel.text = "路程：預估\(Int((response?.expectedTravelTime)!/60))分鐘"
                self.distanceLabel.text = "距離：約\(Int((response?.distance)!))公尺"
                self.nameLabel.text = site?.cityName
            }
        }
    }
    
    func addAnnotations(result: [Site]) {
        
        for i in 0...result.count-1 {
            let lat:CLLocationDegrees = result[i].coordinate[0]
            let long:CLLocationDegrees = result[i].coordinate[1]
            let latDelta:CLLocationDegrees = 0.1
            let longDelta:CLLocationDegrees = 0.1
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            mapView.setRegion(region, animated: true)
            
            self.siteInformation[result[i].address!] = result[i]
            
            let information = MKPointAnnotation()
            information.coordinate = location
            information.title = result[i].cityName
            information.subtitle = result[i].address
            
            mapView.addAnnotation(information)
            
        }
    }
    
    
    //MARK: - InitializeView
    
    func setInitialStyle() {
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 94/255, green: 134/255, blue: 193/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        self.nameLabel.text = "行政區："
        self.distanceLabel.text = "距離："
        self.etaLabel.text = "路程："
        
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            let destinationVC = segue.destinationViewController as! DetailViewController
            
            let site: Site = siteInformation[siteAddress]!
            
            destinationVC.acceptCityName = site.cityName
            destinationVC.acceptAddress = site.address
            destinationVC.acceptUnit = site.unit
            destinationVC.acceptStartDate = site.startDate
            destinationVC.acceptEndDate = site.endDate
            
        }
    }
}
