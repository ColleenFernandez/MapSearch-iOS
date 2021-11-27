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
import Spring
import SwiftyJSON
import UIKit
import CoreLocation

var gMapVC: UIViewController?

class MapVC: BaseVC {
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var cus_right_badge: BadgeBarButtonItem!
    @IBOutlet var cus_total_noti_unread_badge: BadgeBarButtonItem!
    @IBOutlet var uiv_info: SpringView!
    @IBOutlet var uiv_background: UIView!
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
    var infoWindow: InfoWindow?
    // polylines
    var polylines = [GMSPolyline]()
    var is_started_markerlocation_measure: Bool = false
    var is_started_mylocation_measure: Bool = false
    var is_loading_marker: Bool = false
    var selected_location: LocationModel?
    var location_markers = [GMSMarker]()
    var mylocation: CLLocationCoordinate2D?
    var total_noti = [TotalNotiModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavBar()
        setUI()
        mapView.mapStyle(withFilename: "map_style", andType: "json")
        gMapVC = self
        // from will appear method
        polylines.removeAll()
        
        setInfoUI()
        // Location Manager code to fetch current location
        initializeTheLocationManager()
        mapView.isMyLocationEnabled = true
    }

    func initializeTheLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        location_markers.removeAll()
        setMapMarkers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        badgePath.removeAllObservers()
    }

    func setInfoUI() {
        uiv_info.isHidden = true
        uiv_info.roundCorners([.bottomLeft, .bottomRight], radius: 10)
    }

    func showInfo(_ text: String) {
        uiv_info.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            // self.uiv_background.backgroundColor = UIColor(hex: "69DBFF")
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                // self.uiv_background.backgroundColor = UIColor(hex: "279CEB")
                self.lbl_info.text = text
            })
        })

        animateView()
    }

    func animateView() {
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
        total_noti.removeAll()
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
                if let total_noti_data = dict["total_noti_info"].arrayObject {
                    if total_noti_data.count > 0 {
                        for one in total_noti_data {
                            self.total_noti.append(TotalNotiModel(JSON(one)))
                        }
                    }
                }
                let unread_num = dict["total_noti_unread_num"].intValue
                if unread_num > 0{
                    self.cus_total_noti_unread_badge.badgeNumber = unread_num
                }else{
                    self.cus_total_noti_unread_badge.badgeNumber = 0
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
                if one.is_location_like {
                    let imv_badgenew = UIImageView()
                    imv_badgenew.image = UIImage(named: "ic_heart")
                    imv_badgenew.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    imgView.addSubview(imv_badgenew)
                    imv_badgenew.center.x = imgView.center.x + 20
                    imv_badgenew.center.y = imgView.center.y - 24
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
    
    @IBAction func gotoTotalNotiVC(_ sender: UIButton) {
        let tovc = TotalNotiVC()
        tovc.modalPresentationStyle = .fullScreen
        tovc.ds_total_noti = self.total_noti
        navigationController?.pushViewController(tovc, animated: true)
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
        if polylines.count > 0 {
            for one in polylines {
                DispatchQueue.main.async {
                    one.map = nil
                    self.mapView.reloadInputViews()
                }
            }
        }
        if location_markers.count > 0 {
            for one in location_markers {
                one.map = nil
            }
        }
        uiv_info.force = 1
        uiv_info.duration = 1
        uiv_info.delay = 0
        uiv_info.damping = 0.7
        uiv_info.velocity = 0.7
        uiv_info.animation = Spring.AnimationPreset.FadeOut.rawValue
        uiv_info.curve = Spring.AnimationCurve.EaseOut.rawValue
        uiv_info.animateToNext {
            self.selected_location = nil
            self.is_started_markerlocation_measure = false
            self.is_started_mylocation_measure = false
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
            marker.icon = UIImage(named: "location_marker")
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
            if status == "OK" {
                let routes = json1["routes"].arrayValue
                if let json_data = routes.first {
                    let legs = json_data["legs"].arrayValue
                    if let legdata = legs.first {
                        walking_time = JSON(JSON(legdata)["duration"])["text"].stringValue
                        Alamofire.request(url).responseJSON { response in
                            let json = JSON(response.data!)
                            let status = json["status"].stringValue
                            if status == "OK" {
                                let routes = json["routes"].arrayValue
                                if let json_data = routes.first {
                                    let legs = json_data["legs"].arrayValue
                                    if let legdata = legs.first {
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
                            } else {
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
            } else {
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
    
    public func presentAlert(from sourceView: UIView, location: LocationModel) {
        self.selected_location = location
        let alertController = UIAlertController(title: "開始位置を選択してください", message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(title: "選択したマーカーから開始", location: location) {
            alertController.addAction(action)
        }
        
        if let action = self.action(title: "現在の私の場所から開始", location: location) {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: Messages.CANCEL, style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    private func action(title: String, location: LocationModel) -> UIAlertAction? {
        return UIAlertAction(title: title, style: .default) {  _ in
            if title == "選択したマーカーから開始"{
                self.is_started_markerlocation_measure = true
                self.showToastCenter("地図から目的地をお選びください")
            }else if title == "現在の私の場所から開始"{
                self.is_started_mylocation_measure = true
                if self.is_started_mylocation_measure {
                    if let mylocation = self.mylocation{
                        self.drawPolyline(from: location, destination: mylocation)
                        self.is_started_mylocation_measure = false
                    }else{
                        self.showAlertMessage(title: nil, msg: "現在地へのアクセスを許可しませんでした。システム設定で位置情報へのアクセスを許可してください。")
                        self.is_started_mylocation_measure = false
                    }
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
        self.is_loading_marker = true
        if let infoWindow = self.infoWindow{
            infoWindow.removeFromSuperview()
            self.infoWindow = nil
        }
        self.infoWindow = infoWindow
        // get position of tapped marker
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
                    self.is_started_markerlocation_measure = false
                    self.is_started_mylocation_measure = false
                    infoWindow.removeFromSuperview()
                }
                infoWindow.didTappedShowDetail = {
                    self.selected_location = nil
                    self.is_started_markerlocation_measure = false
                    self.is_started_mylocation_measure = false
                    infoWindow.removeFromSuperview()
                    let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
                    tovc.location = one
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
                infoWindow.didTappedShowRecent = { () in
                    self.selected_location = nil
                    self.is_started_markerlocation_measure = false
                    self.is_started_mylocation_measure = false
                    infoWindow.removeFromSuperview()
                    let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
                    tovc.location = one
                    tovc.is_last_post = true
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
                infoWindow.didTappedFavorite = { () in
                    self.selected_location = nil
                    self.is_started_markerlocation_measure = false
                    self.is_started_mylocation_measure = false
                    if thisuser.isValid {
                        if one.is_location_like {
                            ApiManager.manageLocationLike(location_id: one.location_id, request_type: .unlike) { success, _ in
                                if success {
                                    self.delegate?.updateStatus(status: false)
                                    one.is_location_like = false
                                    self.setMapMarkers()
                                }
                            }
                        } else {
                            ApiManager.manageLocationLike(location_id: one.location_id, request_type: .like) { success, _ in
                                if success {
                                    self.delegate?.updateStatus(status: true)
                                    one.is_location_like = true
                                    self.setMapMarkers()
                                }
                            }
                        }
                    } else {
                        infoWindow.removeFromSuperview()
                        self.requireLogin()
                    }
                }
                infoWindow.didTappedMeasure = { () in
                    if thisuser.isValid {
                        infoWindow.removeFromSuperview()
                        self.presentAlert(from: self.view, location: one)
                    } else {
                        infoWindow.removeFromSuperview()
                        self.requireLogin()
                    }
                }
                mapView.addSubview(infoWindow)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.is_loading_marker = false
                }
            }
        }
        return false
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if is_started_markerlocation_measure, let location = selected_location {
            drawPolyline(from: location, destination: coordinate)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let infoWindow = infoWindow{
            if !self.is_loading_marker{
                infoWindow.removeFromSuperview()
            }
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            self.mylocation = location
            mapView.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: 15))
            locationManager.stopUpdatingLocation()
        }
    }
}

protocol InfoChangeDelegate {
    func updateStatus(status: Bool)
}
