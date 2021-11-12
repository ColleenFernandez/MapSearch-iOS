//
//  MapVC.swift
//  MapApp
//
//  Created by top Dev on 14.01.2021.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import Kingfisher
import FirebaseDatabase
import LSDialogViewController

var gMapVC: UIViewController?

class MapVC: BaseVC {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var cus_right_badge: BadgeBarButtonItem!
    
    var zoom:Float = 15
    var tappedMarker : GMSMarker?
    
    var locations = [LocationModel]()
    var marks = [MarkModel]()
    var location_options = [KeyValueModel]()
    var markers = [GMSMarker]()
    var infoWindow : InfoWindow!
    var myLocation: CLLocation?
    var locationManager = CLLocationManager()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var delegate: InfoChangeDelegate?
    var badge_count: Int = 0
    
    var bagdeChangeHandle: UInt?
    var bagdeGetHandle: UInt?
    let badgePath = Database.database().reference().child("badge").child("\(thisuser.user_id ?? 0)")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        self.mapView.mapStyle(withFilename: "map_style", andType: "json")
        gMapVC = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavBar()
        setMapMarkers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        badgePath.removeAllObservers()
    }
    
    func setUI(){
        self.navigationItem.title = Messages.MAP
        self.mapView.delegate = self
    }
    
    func setBadge() {
        bagdeChangeHandle = FirebaseAPI.getBadgeValueChanage { value in
            if let value = value {
                DispatchQueue.main.async {
                    self.badge_count = value
                    self.cus_right_badge.badgeNumber = value
                    UIApplication.shared.applicationIconBadgeNumber = value
                }

            } else {
                DispatchQueue.main.async{
                    //self.cus_right_badge.badgeLabel.isHidden = true
                }

            }
        }
        bagdeGetHandle = FirebaseAPI.getBadgeValue(thisuser.user_id) { value in
            if let value = value {
                DispatchQueue.main.async {
                    self.badge_count = value
                    self.cus_right_badge.badgeNumber = value
                    UIApplication.shared.applicationIconBadgeNumber = value
                }
            } else {
                DispatchQueue.main.async{
                    //self.cus_right_badge.badgeLabel.isHidden = true
                }
            }
        }
    }
    
    func filterMapMarkers(location_type: Int?, favorite_type: Int?){
        self.mapView.clear()
        var filtered_markers = [GMSMarker]()
        filtered_markers.removeAll()
        if let location_type = location_type {
            if location_type == 0{
                for one in self.locations{
                    if let favorite_type = favorite_type {
                        switch favorite_type {
                        case 0: // all
                            let marker = self.parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = self.mapView
                        case 1: // like
                            if one.is_location_like{
                                let marker = self.parseMarker(one)
                                filtered_markers.append(marker)
                            }
                        case 2: // unlike
                            if !one.is_location_like{
                                let marker = self.parseMarker(one)
                                filtered_markers.append(marker)
                                marker.map = self.mapView
                            }
                        default:
                            print("default")
                        }
                    }else{
                        let marker = self.parseMarker(one)
                        filtered_markers.append(marker)
                        marker.map = self.mapView
                    }
                }
            }else{
                for one in self.locations{
                    if location_type == one.mark?.mark_id{
                        if let favorite_type = favorite_type {
                            switch favorite_type {
                            case 0: // all
                                let marker = self.parseMarker(one)
                                filtered_markers.append(marker)
                                marker.map = self.mapView
                            case 1: // like
                                if one.is_location_like{
                                    let marker = self.parseMarker(one)
                                    filtered_markers.append(marker)
                                    marker.map = self.mapView
                                }
                            case 2: // unlike
                                if !one.is_location_like{
                                    let marker = self.parseMarker(one)
                                    filtered_markers.append(marker)
                                    marker.map = self.mapView
                                }
                            default:
                                print("default")
                            }
                        }else{
                            let marker = self.parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = self.mapView
                        }
                    }
                }
            }
        }else{
            for one in self.locations{
                if let favorite_type = favorite_type {
                    switch favorite_type {
                    case 0: // all
                        let marker = self.parseMarker(one)
                        filtered_markers.append(marker)
                        marker.map = self.mapView
                    case 1: // like
                        if one.is_location_like{
                            let marker = self.parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = self.mapView
                        }
                    case 2: // unlike
                        if !one.is_location_like{
                            let marker = self.parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = self.mapView
                        }
                    default:
                        print("default")
                    }
                }else{
                    let marker = self.parseMarker(one)
                    filtered_markers.append(marker)
                    marker.map = self.mapView
                }
            }
        }
    }
    
    func setMapMarkers(){
        self.locations.removeAll()
        self.markers.removeAll()
        self.marks.removeAll()
        self.location_options.removeAll()
        self.locations.removeAll()
        self.mapView.clear()
        self.showLoadingView(vc: self)
        ApiManager.getLocations { success, response in
            self.hideLoadingView()
            self.setBadge()
            if success{
                let dict = JSON(response as Any)
                if let location_data = dict["location_info"].arrayObject{
                    if location_data.count > 0{
                        var num = 0
                        for one in location_data{
                            num += 1
                            self.locations.append(LocationModel(JSON(one)))
                            if num == location_data.count{
                                self.mapView.isMyLocationEnabled = true
                                for two in self.locations{
                                    let marker = self.parseMarker(two)
                                    marker.map = self.mapView
                                    self.markers.append(marker)
                                }
                            }
                        }
                    }
                }
                if let mark_data = dict["mark_info"].arrayObject{
                    if mark_data.count > 0{
                        self.location_options.append(KeyValueModel(key: "0", value: "ディフォルト"))
                        var num = 0
                        for one in mark_data{
                            num += 1
                            self.marks.append(MarkModel(JSON(one)))
                            if num == mark_data.count{
                                for two in self.marks{
                                    self.location_options.append(KeyValueModel(key: "\(two.mark_id ?? 0)", value: two.mark_name ?? ""))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func parseMarker(_ one: LocationModel) -> GMSMarker {
        var marker = GMSMarker()
        marker = GMSMarker(position: CLLocationCoordinate2D(latitude: one.location_lat ?? 0, longitude: one.location_lang ?? 0))
        marker.title = "\(one.location_id ?? 0)"
        let url = URL(string: one.mark?.mark_image ?? "")
        getData(from: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                let imgView = UIImageView(image: UIImage.init(named: "marker"))
                let picImgView = UIImageView()
                picImgView.image = UIImage(data: data)?.withBackground(color: .white)
                picImgView.frame = CGRect(x: 0, y: 0, width: imgView.frame.width - 10, height: imgView.frame.height - 20)
                picImgView.borderColor = .black
                picImgView.borderWidth = 2
                imgView.addSubview(picImgView)
                picImgView.center.x = imgView.center.x
                picImgView.center.y = imgView.center.y - 10
                picImgView.layer.cornerRadius = 7
                picImgView.contentMode = .scaleToFill
                picImgView.clipsToBounds = true
                imgView.setNeedsLayout()
                imgView.layer.cornerRadius = 7
                imgView.clipsToBounds = true
                imgView.contentMode = .scaleAspectFit
                picImgView.setNeedsLayout()
                marker.icon = self!.imageWithView(view: imgView)
            }
        }
        return marker
    }
    
    func imageWithView(view: UIView) -> UIImage {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }

    @IBAction func btnZoomIn(_ sender: UIButton) {
        zoom = zoom + 1
        self.mapView.animate(toZoom: zoom)
    }
    @IBAction func btnZoomOut(_ sender: UIButton) {
        zoom = zoom - 1
        self.mapView.animate(toZoom: zoom)
    }
    
    @IBAction func gotoNotiVC(_ sender: UIButton) {
        let tovc = self.createVC("NotiVC") as! NotiVC
        tovc.badge_count = self.badge_count
        tovc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(tovc, animated: true)
    }
    
    @IBAction func btnMyLocation(_ sender: UIButton) {
        guard let lat = self.mapView.myLocation?.coordinate.latitude, let lng = self.mapView.myLocation?.coordinate.longitude else {
            return
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: zoom)
        self.mapView.animate(to: camera)
        
        let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let userLocation = GMSMarker(position: position)
        userLocation.map = mapView
    }
    
    @IBAction func filterBtnClicked(_ sender: Any) {
        showDialog(.fadeInOut)
    }
    
    fileprivate func showDialog(_ animationPattern: LSAnimationPattern) {
        let dialogViewController = SearchDialogUV(nibName: "SearchDialogUV", bundle: nil) 
        dialogViewController.delegate = self
        dialogViewController.location_options = self.location_options
        presentDialogViewController(dialogViewController, animationPattern: animationPattern)
    }

    func dismissDialog() {
        dismissDialogViewController(LSAnimationPattern.fadeInOut)
    }
}

extension GMSMapView {
    func mapStyle(withFilename name: String, andType type: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }else {
                NSLog("Unable to find darkMap")
            }
        }
        catch {
            NSLog("failded to load. \(error)")
        }
    }
}

extension MapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        tappedMarker = marker
        
        let location_id = marker.title?.toInt() ?? 0
        let infoWindow = InfoWindow().loadView()
        // get osition of tapped marker
        let position = marker.position
        mapView.animate(toLocation: position)
        let point = mapView.projection.point(for: position)
        let newPoint = mapView.projection.coordinate(for: point)
        let camera = GMSCameraUpdate.setTarget(newPoint)
        mapView.animate(with: camera)
        infoWindow.center = CGPoint.init(x: view.centerX, y: view.centerY - (Constants.SCREEN_HEIGHT / 5 - 170))// iphone 6s
        for one in locations{
            if location_id == one.location_id{
                infoWindow.loadData(location: one)
                infoWindow.didTappedCancel = { () in
                    infoWindow.removeFromSuperview()
                }
                infoWindow.didTappedShowDetail = {
                    infoWindow.removeFromSuperview()
                    let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
                    tovc.location = one
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
                infoWindow.didTappedFavorite = { () in
                    if one.is_location_like{
                        ApiManager.manageLocationLike(location_id: one.location_id, request_type:.unlike){ success,response in
                            if success{
                                self.delegate?.updateStatus(status: false)
                                one.is_location_like = false
                            }
                        }
                    }else{
                        ApiManager.manageLocationLike(location_id: one.location_id, request_type:.like){ success,response in
                            if success{
                                self.delegate?.updateStatus(status: true)
                                one.is_location_like = true
                            }
                        }
                    }
                }
                mapView.addSubview(infoWindow)
            }
        }
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow?.removeFromSuperview()
    }
}

protocol InfoChangeDelegate {
    func updateStatus(status: Bool)
}






