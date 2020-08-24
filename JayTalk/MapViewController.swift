//
//  MapViewController.swift
//  JayTalk
//
//  Created by Jkookoo on 2020/08/24.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    // MARK: - ProPerties
    var mapView: NMFMapView?
    let infoWindow = NMFInfoWindow()
    let dataSource = NMFInfoWindowDefaultTextSource.data()
//    var marker: NMFMarker?
    let apiKey = "52516b6f6768636d38306848616a70"
    var bikeDatas: [BikeDataModel.RentBikeStatus] = []
    let mapKey = "eMUPmNaPhsvBdc3GWGnMlsbA0a0oDKKcUVGK9ZB7"
    let locationManager = CLLocationManager()
    
    
    // MARK: - Methods
    func getBikeData() {
        var i = 0
        var startIndex = 1
        var endIndex = 1000
        while(endIndex < 4000) {
            let urlString = "http://openapi.seoul.go.kr:8088/\(self.apiKey)/json/bikeList/\(startIndex)/\(endIndex)/"
            guard let url = URL(string: urlString) else {
                print("url 실패")
                return
            }
            
            print("url 성공")
            let session = URLSession.shared
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                if(error == nil) {
                    i += 1
                    let jsonDecoder = JSONDecoder()
                    do {
                        print("디코딩중...")
                        let bikeData = try jsonDecoder.decode(BikeDataModel.self, from: data!)
                        if let bikeStatus = bikeData.rentBikeStatus {
                            self.bikeDatas.append(bikeStatus)
                        }
                        
                        if i == 3 {
                            self.mapConfig()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    print("url error : " + error.debugDescription)
                }
            }
            dataTask.resume()
            startIndex += 1000
            endIndex += 1000
        }
    }

    func mapConfig() {
        //좌표
        for page in self.bikeDatas {
            for row in page.rows! {
                let lat = row.stationLatitude
                let lng = row.stationLongitude
                if let doubleLat = Double(lat!), let doubleLng = Double(lng!) {
                    let marker = NMFMarker()
                    let coord = NMGLatLng(lat: doubleLat, lng: doubleLng)
                    
                    DispatchQueue.main.async {
                        self.mapView?.latitude = doubleLat
                        self.mapView?.longitude = doubleLng
                        marker.position = coord
                        
                        self.dataSource.title = "정보 창 내용"
                        self.infoWindow.open(with: marker)
                        
                        marker.mapView = self.mapView
                    }
                }
            }
        }
        
        
        
        print("끝")
    }
    
    // MARK: - IBOutlets
    
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        
        self.mapView = self.naverMapView.mapView
        
        self.naverMapView.showCompass = true
        self.naverMapView.showLocationButton = true
        self.naverMapView.showZoomControls = true
        
        self.infoWindow.dataSource = dataSource
        
        self.getBikeData()
    }
}
