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
    var requestLocation: CLLocationCoordinate2D!
    
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
        
        // mapView.userLocation.coordinate ← この書き方で現在地を取得
        var region:MKCoordinateRegion = mapView.region        
        region.center = mapView.userLocation.coordinate
        
        // 縮尺を設定
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        
        mapView.setRegion(region, animated:true)
        
        // 表示タイプを航空写真と地図のハイブリッドに設定
        mapView.mapType = MKMapType.hybrid
        // mapView.mapType = MKMapType.standard
        // mapView.mapType = MKMapType.satellite

        // 進行方向を画面上に設定
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        
        // 長押しのUIGestureRecognizerを生成
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self, action: #selector(recognizeLongPress))
        self.view.addGestureRecognizer(myLongPress)
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
    
    func getRoute() {
        // 現在地と目的地のMKPlacemarkを生成
        let fromPlacemark = MKPlacemark(coordinate:mapView.userLocation.coordinate, addressDictionary:nil)
        let toPlacemark   = MKPlacemark(coordinate:requestLocation, addressDictionary:nil)
        
        // MKPlacemark から MKMapItem を生成
        let fromItem = MKMapItem(placemark:fromPlacemark)
        let toItem   = MKMapItem(placemark:toPlacemark)
        
        // MKMapItem をセットして MKDirectionsRequest を生成
        let request = MKDirections.Request()
        
        request.source = fromItem
        request.destination = toItem
        request.requestsAlternateRoutes = false // 単独の経路を検索
        request.transportType = MKDirectionsTransportType.any
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            //　ルートを追加
            let route = directionResonse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            //　縮尺を設定
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    @objc func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        // 長押しの最中に何度もピンを生成しないようにする.
        if sender.state != UIGestureRecognizer.State.began { return }
        
        // 長押しした地点の座標を取得.
        let location = sender.location(in: mapView)
        
        // locationをCLLocationCoordinate2Dに変換.
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        
        // ピンの座標を保持
        requestLocation = mapView.convert(location, toCoordinateFrom: mapView)
        print(requestLocation)
        
        // ピンを生成.
        let newPin: MKPointAnnotation = MKPointAnnotation()
        
        // 座標を設定.
        newPin.coordinate = myCoordinate
        
        // 位置情報の更新
        locationManager.startUpdatingLocation()
        
        // タイトルを設定.
        newPin.title = "タイトル"
        
        // サブタイトルを設定.
        newPin.subtitle = "サブタイトル"
        
        // MapViewにピンを追加.
        mapView.addAnnotation(newPin)
        
        getRoute()
    }
    
    
    /*
     -[*] 現在地と目的地までのルートを描画
     -[] ピンを消してもルートが表示されたまま
     -[] ルートを描画した際のズームがぎこちない
     */
    
    //  MARK: - delegate
    //    --------------------------------------------------------------------------------
    //    locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    //    --------------------------------------------------------------------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("タイミング確認")
        
        // 現在地を地図の中心に
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
//        if let _ = requestLocation { getRoute() }
        // 現在地にピンを立てる
//        if let coordinate = locations.last?.coordinate {
//            let pin = MKPointAnnotation()
//            pin.coordinate = coordinate
//            mapView.addAnnotation(pin)
//        }
//        getRoute()
    }
    
    // 位置情報の取得に失敗した際に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "位置情報の取得に失敗しました",
                                      message: nil,
                                      preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedPin = view.annotation
        mapView.removeAnnotation(selectedPin!)
    }
    
    // ルートを表示
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
//    func mapView(viewFor: MKAnnotation) -> MKAnnotationView {
//        let myPinIdentifier = "PinAnnotationIdentifier"

//        // ピンを生成.
//        var myPinView: MKPinAnnotationView!
//
//        // MKPinAnnotationViewのインスタンスが生成されていなければ作る.
//        if myPinView == nil {
//            myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
//
//            // アニメーションをつける.
//            myPinView.animatesDrop = true
//
//            // コールアウトを表示する.
//            myPinView.canShowCallout = true
//            return myPinView
//        }
//        // annotationを設定.
//        myPinView.annotation = annotation
//        return myPinView
//    }
}

