//
//  MapVC.swift
//  MapApp
//
//  Created by top Dev on 14.01.2021.
//

import FirebaseDatabase
import GoogleMaps
import Kingfisher
import LSDialogViewController
import SwiftyJSON
import UIKit
import Alamofire

var gMapVC: UIViewController?

class MapVC: BaseVC {
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var cus_right_badge: BadgeBarButtonItem!

    var zoom: Float = 15
    var tappedMarker: GMSMarker?

    var locations = [LocationModel]()
    var marks = [MarkModel]()
    var location_options = [KeyValueModel]()
    var markers = [GMSMarker]()
    var infoWindow: InfoWindow!
    var myLocation: CLLocation?
    var locationManager = CLLocationManager()
    fileprivate var locationMarker: GMSMarker? = GMSMarker()
    var delegate: InfoChangeDelegate?
    var badge_count: Int = 0

    var bagdeChangeHandle: UInt?
    var bagdeGetHandle: UInt?
    let badgePath = Database.database().reference().child("badge").child("\(thisuser.user_id ?? 0)")

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        mapView.mapStyle(withFilename: "map_style", andType: "json")
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

    fileprivate func showDialog(_ animationPattern: LSAnimationPattern) {
        let dialogViewController = SearchDialogUV(nibName: "SearchDialogUV", bundle: nil)
        dialogViewController.delegate = self
        dialogViewController.location_options = location_options
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
        infoWindow.center = CGPoint(x: view.centerX, y: view.centerY - (Constants.SCREEN_HEIGHT / 5 - 170)) // iphone 6s
        for one in locations {
            if location_id == one.location_id {
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
                infoWindow.didTappedShowRecent = { () in
                    infoWindow.removeFromSuperview()
                    let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
                    tovc.location = one
                    tovc.is_last_post = true
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
                infoWindow.didTappedFavorite = { () in
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
                }
                infoWindow.loginAction = { () in
                    self.requireLogin()
                }
                infoWindow.didTappedFinish = { () in
                }
                
                infoWindow.didTappedMeasure = { () in
                    let origin = "\(one.location_lat ?? 0),\(one.location_lang ?? 0)"
                    let destination = "\(35.68382748306113),\(139.7523487072757)"
                    let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(Constants.GOOGLE_API_KEY)"

                    Alamofire.request(url).responseJSON { response in
                        let json = JSON(response.data!)
                        let routes = json["routes"].arrayValue

                        for route in routes {
                            let routeOverviewPolyline = route["overview_polyline"].dictionary
                            let points = routeOverviewPolyline?["points"]?.stringValue
                            let path = GMSPath(fromEncodedPath: points!)

                            let polyline = GMSPolyline(path: path)
                            polyline.strokeColor = .black
                            polyline.strokeWidth = 10.0
                            polyline.map = self.mapView
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
        print(coordinate)
        infoWindow?.removeFromSuperview()
    }
}

protocol InfoChangeDelegate {
    func updateStatus(status: Bool)
}
