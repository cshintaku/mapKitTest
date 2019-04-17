//
//  ViewController.swift
//  mapKitTest
//
//  Created by aki on 2019/04/17.
//  Copyright © 2019 uncode,Inc. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    //  MARK: - override
    //    --------------------------------------------------------------------------------
    //    viewDidLoad()
    //    --------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 位置情報の使用許可
        setupLocationManager()
        
        // 位置情報の更新
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        var region:MKCoordinateRegion = mapView.region
        // mapView.userLocation.coordinate ← この書き方で現在地を取得
        region.center = mapView.userLocation.coordinate
        // 縮尺を設定
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        
        mapView.setRegion(region, animated:true)
        
        // 表示タイプを航空写真と地図のハイブリッドに設定
        mapView.mapType = MKMapType.hybrid
        // mapView.mapType = MKMapType.standard
        // mapView.mapType = MKMapType.satellite
        
        // 追従方法の設定
        mapView.userTrackingMode = MKUserTrackingMode.follow
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
    }
    
    //  MARK: - method
    //    --------------------------------------------------------------------------------
    //    setupLocationManager()
    //    --------------------------------------------------------------------------------
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("タイミング確認")
        // 現在地にピンを立てる
        if let coordinate = locations.last?.coordinate {
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            mapView.addAnnotation(pin)
        }
        
    }

}

