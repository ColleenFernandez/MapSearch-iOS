//
//  MapVC.swift
//  MapApp
//
//  Created by top Dev on 14.01.2021.
//

import Alamofire
import FirebaseDatabase
import GoogleMaps
import Kingfisher
import LSDialogViewController
import SwiftyJSON
import UIKit
import Spring

var gMapVC: UIViewController?

class MapVC: BaseVC {
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var cus_right_badge: BadgeBarButtonItem!
    @IBOutlet var uiv_info: SpringView!
    @IBOutlet weak var uiv_background: UIView!
    @IBOutlet var lbl_info: UILabel!
    
    var zoom: Float = 15
    var tappedMarker: GMSMarker?

    var locations = [LocationModel]()
    var marks = [MarkModel]()
    var location_options = [KeyValueModel]()
    var markers = [GMSMarker]()
    var myLocation: CLLocation?
    var locationManager = CLLocationManager()
    fileprivate var locationMarker: GMSMarker? = GMSMarker()
    var delegate: InfoChangeDelegate?
    var badge_count: Int = 0

    var bagdeChangeHandle: UInt?
    var bagdeGetHandle: UInt?
    let badgePath = Database.database().reference().child("badge").child("\(thisuser.user_id ?? 0)")

    // polylines
    var polylines = [GMSPolyline]()
    var is_started_measure: Bool = false
    var selected_location: LocationModel?
    var location_markers = [GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        mapView.mapStyle(withFilename: "map_style", andType: "json")
        gMapVC = self
    }
    
    func initializeTheLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        polylines.removeAll()
        location_markers.removeAll()
        showNavBar()
        setMapMarkers()
        setInfoUI()
        //Location Manager code to fetch current location
        initializeTheLocationManager()
        self.mapView.isMyLocationEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        badgePath.removeAllObservers()
    }

    func setInfoUI() {
        self.uiv_info.isHidden = true
        uiv_info.roundCorners([.bottomLeft, .bottomRight], radius: 10)
    }
    
    func showInfo(_ text: String) {
        self.uiv_info.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            //self.uiv_background.backgroundColor = UIColor(hex: "69DBFF")
        }, completion: { finished in
            UIView.animate(withDuration: 0.5, animations: {
                //self.uiv_background.backgroundColor = UIColor(hex: "279CEB")
                self.lbl_info.text = text
            })
        })
        
        animateView()
    }
    
    func animateView(){
        uiv_info.force = 1
        uiv_info.duration = 1
        uiv_info.delay = 0
        
        uiv_info.damping = 0.7
        uiv_info.velocity = 0.7
        uiv_info.animation = Spring.AnimationPreset.FadeInDown.rawValue
        uiv_info.curve = Spring.AnimationCurve.EaseIn.rawValue
        uiv_info.animate()
    }
    
    func setUI() {
        navigationItem.title = Messages.MAP
        mapView.delegate = self
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
                DispatchQueue.main.async {
                    // self.cus_right_badge.badgeLabel.isHidden = true
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
                DispatchQueue.main.async {
                    // self.cus_right_badge.badgeLabel.isHidden = true
                }
            }
        }
    }

    func filterMapMarkers(location_type: Int?, favorite_type: Int?) {
        mapView.clear()
        var filtered_markers = [GMSMarker]()
        filtered_markers.removeAll()
        if let location_type = location_type {
            if location_type == 0 {
                for one in locations {
                    if let favorite_type = favorite_type {
                        switch favorite_type {
                        case 0: // all
                            let marker = parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = mapView
                        case 1: // like
                            if one.is_location_like {
                                let marker = parseMarker(one)
                                filtered_markers.append(marker)
                            }
                        case 2: // unlike
                            if !one.is_location_like {
                                let marker = parseMarker(one)
                                filtered_markers.append(marker)
                                marker.map = mapView
                            }
                        default:
                            print("default")
                        }
                    } else {
                        let marker = parseMarker(one)
                        filtered_markers.append(marker)
                        marker.map = mapView
                    }
                }
            } else {
                for one in locations {
                    if location_type == one.mark?.mark_id {
                        if let favorite_type = favorite_type {
                            switch favorite_type {
                            case 0: // all
                                let marker = parseMarker(one)
                                filtered_markers.append(marker)
                                marker.map = mapView
                            case 1: // like
                                if one.is_location_like {
                                    let marker = parseMarker(one)
                                    filtered_markers.append(marker)
                                    marker.map = mapView
                                }
                            case 2: // unlike
                                if !one.is_location_like {
                                    let marker = parseMarker(one)
                                    filtered_markers.append(marker)
                                    marker.map = mapView
                                }
                            default:
                                print("default")
                            }
                        } else {
                            let marker = parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = mapView
                        }
                    }
                }
            }
        } else {
            for one in locations {
                if let favorite_type = favorite_type {
                    switch favorite_type {
                    case 0: // all
                        let marker = parseMarker(one)
                        filtered_markers.append(marker)
                        marker.map = mapView
                    case 1: // like
                        if one.is_location_like {
                            let marker = parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = mapView
                        }
                    case 2: // unlike
                        if !one.is_location_like {
                            let marker = parseMarker(one)
                            filtered_markers.append(marker)
                            marker.map = mapView
                        }
                    default:
                        print("default")
                    }
                } else {
                    let marker = parseMarker(one)
                    filtered_markers.append(marker)
                    marker.map = mapView
                }
            }
        }
    }

    func setMapMarkers() {
        locations.removeAll()
        markers.removeAll()
        marks.removeAll()
        location_options.removeAll()
        locations.removeAll()
        mapView.clear()
        showLoadingView(vc: self)
        ApiManager.getLocations { success, response in
            self.hideLoadingView()
            self.setBadge()
            if success {
                let dict = JSON(response as Any)
                if let location_data = dict["location_info"].arrayObject {
                    if location_data.count > 0 {
                        var num = 0
                        for one in location_data {
                            num += 1
                            self.locations.append(LocationModel(JSON(one)))
                            if num == location_data.count {
                                self.mapView.isMyLocationEnabled = true
                                for two in self.locations {
                                    let marker = self.parseMarker(two)
                                    marker.map = self.mapView
                                    self.markers.append(marker)
                                }
                            }
                        }
                    }
                }
                if let mark_data = dict["mark_info"].arrayObject {
                    if mark_data.count > 0 {
                        self.location_options.append(KeyValueModel(key: "0", value: "ディフォルト"))
                        var num = 0
                        for one in mark_data {
                            num += 1
                            self.marks.append(MarkModel(JSON(one)))
                            if num == mark_data.count {
                                for two in self.marks {
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
        getData(from: url!) { data, _, error in
            guard let data = data, error == nil else { return }
            // always update the UI from the main thread
            DispatchQueue.main.async { [weak self] in
                let imgView = UIImageView(image: UIImage(named: "marker"))
                let picImgView = UIImageView()
                picImgView.image = UIImage(data: data)?.withBackground(color: .white)
                picImgView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                picImgView.borderColor = .black
                picImgView.borderWidth = 1
                imgView.addSubview(picImgView)
                picImgView.center.x = imgView.center.x
                picImgView.center.y = imgView.center.y - 1
                picImgView.layer.cornerRadius = 7
                picImgView.contentMode = .scaleToFill
                picImgView.clipsToBounds = true
                imgView.setNeedsLayout()
                imgView.layer.cornerRadius = 7
                imgView.clipsToBounds = true
                imgView.contentMode = .scaleAspectFit
                picImgView.setNeedsLayout()
                if one.has_new_noti {
                    let imv_badgenew = UIImageView()
                    imv_badgenew.image = UIImage(named: "ic_new_badge")
                    imv_badgenew.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    imgView.addSubview(imv_badgenew)
                    imv_badgenew.center.x = imgView.center.x + 20
                    imv_badgenew.center.y = imgView.center.y - 25
                    imv_badgenew.clipsToBounds = true
                    imv_badgenew.contentMode = .scaleAspectFit
                    imv_badgenew.setNeedsLayout()
                }
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
        mapView.animate(toZoom: zoom)
    }

    @IBAction func btnZoomOut(_ sender: UIButton) {
        zoom = zoom - 1
        mapView.animate(toZoom: zoom)
    }

    @IBAction func gotoNotiVC(_ sender: UIButton) {
        if thisuser.isValid {
            let tovc = createVC("NotiVC") as! NotiVC
            tovc.badge_count = badge_count
            tovc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(tovc, animated: true)
        } else {
            requireLogin()
        }
    }

    @IBAction func btnMyLocation(_ sender: UIButton) {
        guard let lat = mapView.myLocation?.coordinate.latitude, let lng = mapView.myLocation?.coordinate.longitude else {
            return
        }

        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: zoom)
        mapView.animate(to: camera)

        let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let userLocation = GMSMarker(position: position)
        userLocation.map = mapView
    }

    @IBAction func filterBtnClicked(_ sender: Any) {
        showDialog(.fadeInOut)
    }
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        self.uiv_info.force = 1
        self.uiv_info.duration = 1
        self.uiv_info.delay = 0
        self.uiv_info.damping = 0.7
        self.uiv_info.velocity = 0.7
        self.uiv_info.animation = Spring.AnimationPreset.FadeOut.rawValue
        self.uiv_info.curve = Spring.AnimationCurve.EaseOut.rawValue
        self.uiv_info.animateToNext {
            self.uiv_info.isHidden = true
        }
    }

    fileprivate func showDialog(_ animationPattern: LSAnimationPattern) {
        let dialogViewController = SearchDialogUV(nibName: "SearchDialogUV", bundle: nil)
        dialogViewController.delegate = self
        dialogViewController.location_options = location_options
        presentDialogViewController(dialogViewController, animationPattern: animationPattern)
    }

    func dismissDialog() {
        dismissDialogViewController(LSAnimationPattern.fadeInOut)
    }

    func drawPolyline(from: LocationModel, destination: CLLocationCoordinate2D) {
        if location_markers.count > 0 {
            for one in location_markers {
                one.map = nil
            }
        }
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            let marker = GMSMarker()
            marker.position = position
            marker.map = self.mapView
            marker.icon = UIImage.init(named: "location_marker")
            self.location_markers.append(marker)
        }
        if polylines.count > 0 {
            for one in polylines {
                DispatchQueue.main.async {
                    one.map = nil
                    self.mapView.reloadInputViews()
                }
            }
        }
        let origin = "\(from.location_lat ?? 0),\(from.location_lang ?? 0)"
        let destination = "\(destination.latitude),\(destination.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.DIRECTION_API_KEY)"
        let walkingurl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&key=\(Constants.DIRECTION_API_KEY)"
        var distance = ""
        var driving_time = ""
        var walking_time = ""
        Alamofire.request(walkingurl).responseJSON { response1 in
            
            let json1 = JSON(response1.data!)
            let status = json1["status"].stringValue
            if status == "OK"{
                let routes = json1["routes"].arrayValue
                if let json_data = routes.first{
                    let legs = json_data["legs"].arrayValue
                    if let legdata = legs.first{
                        walking_time = JSON(JSON(legdata)["duration"])["text"].stringValue
                        Alamofire.request(url).responseJSON { response in
                            let json = JSON(response.data!)
                            let status = json["status"].stringValue
                            if status == "OK"{
                                let routes = json["routes"].arrayValue
                                if let json_data = routes.first{
                                    let legs = json_data["legs"].arrayValue
                                    if let legdata = legs.first{
                                        distance = JSON(JSON(legdata)["distance"])["text"].stringValue
                                        driving_time = JSON(JSON(legdata)["duration"])["text"].stringValue
                                    }
                                }
                                var num = 0
                                for route in routes {
                                    num += 1
                                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                                    let points = routeOverviewPolyline?["points"]?.stringValue
                                    let path = GMSPath(fromEncodedPath: points!)

                                    let polyline = GMSPolyline(path: path)
                                    polyline.strokeColor = UIColor.systemIndigo
                                    polyline.strokeWidth = 4.0
                                    polyline.map = self.mapView
                                    self.polylines.append(polyline)
                                    if num == routes.count {
                                        let replaced_walking_time = walking_time.replacingOccurrences(of: "days", with: "日").replacingOccurrences(of: "day", with: "日").replacingOccurrences(of: "hours", with: "時間").replacingOccurrences(of: "hour", with: "時間").replacingOccurrences(of: "mins", with: "分").replacingOccurrences(of: "min", with: "分")
                                        let replaced_driving_time = driving_time.replacingOccurrences(of: "days", with: "日").replacingOccurrences(of: "day", with: "日").replacingOccurrences(of: "hours", with: "時間").replacingOccurrences(of: "hour", with: "時間").replacingOccurrences(of: "mins", with: "分").replacingOccurrences(of: "min", with: "分")
                                        self.showInfo("距離:\(distance)  徒歩:\(replaced_walking_time)  車:\(replaced_driving_time)")
                                    }
                                }
                            }else{
                                self.uiv_info.force = 1
                                self.uiv_info.duration = 1
                                self.uiv_info.delay = 0
                                self.uiv_info.damping = 0.7
                                self.uiv_info.velocity = 0.7
                                self.uiv_info.animation = Spring.AnimationPreset.FadeOut.rawValue
                                self.uiv_info.curve = Spring.AnimationCurve.EaseOut.rawValue
                                self.uiv_info.animateToNext {
                                    self.uiv_info.isHidden = true
                                }
                            }
                        }
                    }
                }
            }else{
                self.uiv_info.force = 1
                self.uiv_info.duration = 1
                self.uiv_info.delay = 0
                self.uiv_info.damping = 0.7
                self.uiv_info.velocity = 0.7
                self.uiv_info.animation = Spring.AnimationPreset.FadeOut.rawValue
                self.uiv_info.curve = Spring.AnimationCurve.EaseOut.rawValue
                self.uiv_info.animateToNext {
                    self.uiv_info.isHidden = true
                }
            }
        }
    }
}

extension GMSMapView {
    func mapStyle(withFilename name: String, andType type: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find darkMap")
            }
        } catch {
            NSLog("failded to load. \(error)")
        }
    }
}

extension MapVC: GMSMapViewDelegate {
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
        infoWindow.center = CGPoint(x: view.centerX, y: view.centerY - (Constants.SCREEN_HEIGHT / 5 - 190)) // iphone 6s
        for one in locations {
            if location_id == one.location_id {
                infoWindow.loadData(location: one)
                infoWindow.didTappedCancel = { () in
                    self.selected_location = nil
                    self.is_started_measure = false
                    infoWindow.removeFromSuperview()
                }
                infoWindow.didTappedShowDetail = {
                    self.selected_location = nil
                    self.is_started_measure = false
                    infoWindow.removeFromSuperview()
                    let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
                    tovc.location = one
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
                infoWindow.didTappedShowRecent = { () in
                    self.selected_location = nil
                    self.is_started_measure = false
                    infoWindow.removeFromSuperview()
                    let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
                    tovc.location = one
                    tovc.is_last_post = true
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
                infoWindow.didTappedFavorite = { () in
                    self.selected_location = nil
                    self.is_started_measure = false
                    if thisuser.isValid{
                        if one.is_location_like {
                            ApiManager.manageLocationLike(location_id: one.location_id, request_type: .unlike) { success, _ in
                                if success {
                                    self.delegate?.updateStatus(status: false)
                                    one.is_location_like = false
                                }
                            }
                        } else {
                            ApiManager.manageLocationLike(location_id: one.location_id, request_type: .like) { success, _ in
                                if success {
                                    self.delegate?.updateStatus(status: true)
                                    one.is_location_like = true
                                }
                            }
                        }
                    }else{
                        infoWindow.removeFromSuperview()
                        self.requireLogin()
                    }
                }
                infoWindow.didTappedMeasure = { () in
                    if thisuser.isValid{
                        self.selected_location = one
                        self.is_started_measure = true
                        infoWindow.removeFromSuperview()
                        self.showToastCenter("地図から目的地をお選びください")
                    }else{
                        infoWindow.removeFromSuperview()
                        self.requireLogin()
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
        if is_started_measure, let location = selected_location {
            drawPolyline(from: location, destination: coordinate)
        }
    }
}

extension MapVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate{
            self.mapView.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: 17))
            self.locationManager.stopUpdatingLocation()
        }
    }
}

protocol InfoChangeDelegate {
    func updateStatus(status: Bool)
}

public extension UIColor {
    convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var hex:   String = hex
        
        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }
        
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
            }
        } else {
            print("Scan hex error")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}


