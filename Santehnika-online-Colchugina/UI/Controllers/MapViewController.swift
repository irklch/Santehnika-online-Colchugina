//
//  MapViewController.swift
//  Santehnika-online-Colchugina
//
//  Created by Ирина Кольчугина on 13.10.2021.
//

import UIKit
import YandexMapsMobile
import CoreLocation

final class MapViewController: UIViewController {

    //MARK: - Static properties
    static var newPoint = YMKSuggestItem()
    static var oldPoint: YMKMapObject?

    //MARK: - Private properties
    private var points = [Point]()
    private let mapView = YMKMapView()
    private let locationManager = CLLocationManager()
    private var searchManager: YMKSearchManager?
    private var searchSession: YMKSearchSession?

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        addNotificationObserver()
        setUserLocation()
        setMapInputListener()
        setSearchConfigurations()
    }

    //MARK: - Public methods

    //Добавить изменённую точку на карту
    func onSearchResponse(_ response: YMKSearchResponse) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        for searchResult in response.collection.children {
            if let pointFromSearch = searchResult.obj?.geometry.first?.point {
                createPoint(point: pointFromSearch) { [weak self] point in
                    guard let self = self else {return}
                    var newPoint = point
                    let placemark = mapObjects.addPlacemark(with: pointFromSearch)
                    newPoint.mark = placemark
                    self.points.append(newPoint)
                    placemark.setIconWith(UIImage(named: "SearchResult")!)
                }
            }
        }
    }

    //Вывод ошибки
    func onSearchError(_ error: Error) {
        let searchError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if searchError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if searchError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }

        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Private mathods

    //Установить границы карты
    private func setViews() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    //Настройки кнопки навигации
    private func setBarButtonItem() {
        let backItem = UIBarButtonItem()
        backItem.title = "Карта"
        self.navigationItem.backBarButtonItem = backItem
    }

    //Подписаться на уведомления об изменениях точки
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(changePoint), name: Notification.Name("pointDidChanged"), object: nil)
    }

    //Найти геололокацию изменённой точку
    @objc
    private func changePoint (notification: NSNotification){
        let mapObjects = self.mapView.mapWindow.map.mapObjects
        guard let point = MapViewController.oldPoint else {return}
        points.removeAll { $0.mark == point}
        mapObjects.remove(with: point)

        let responseHandler = {(searchResponse: YMKSearchResponse?, error: Error?) -> Void in
            if let response = searchResponse {
                self.onSearchResponse(response)
            } else {
                self.onSearchError(error!)
            }
        }
        guard let uri = MapViewController.newPoint.uri else {return}
        searchSession = searchManager?.searchByURI(
            withUri: uri,
            searchOptions: YMKSearchOptions(),
            responseHandler: responseHandler)
    }

    //Настроить менеджера для поиска изменённой точки
    private func setSearchConfigurations() {
        searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    }
    
}

//MARK: - Extension
extension MapViewController: CLLocationManagerDelegate {

    //MARK: - Public methods

    //Определить геолокацию устройства
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = manager.location?.coordinate else {return}
        self.setMapSettings(latitude: locValue.latitude, longitude: locValue.longitude)
        locationManager.stopUpdatingLocation()
    }

    //MARK: - Private methods

    //Отобразить геолокацию устройства на карте
    private func setMapSettings(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: YMKPoint(latitude: latitude,
                                                     longitude: longitude),
                                    zoom: 15,
                                    azimuth: 0,
                                    tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 3),
            cameraCallback: nil)
    }

    //Настроить отслеживание геолокации устройства
    private func setUserLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

}

//MARK: - Extension
extension MapViewController:  YMKMapInputListener {

    //MARK: - Public methods

    //Открыть существующую кнопку или добавить новую
    func onMapTap(with map: YMKMap, point: YMKPoint) {
        createPoint(point: point) { [weak self] point in
            guard let self = self else {return}
            if self.points.contains(where: {$0.address == point.address}) {
                for index in 0..<self.points.count {
                    if self.points[index].address == point.address {
                        let pointDescriptionViewController = PointDescriptionViewController(point: self.points[index])
                        self.navigationController?.pushViewController(pointDescriptionViewController, animated: true)
                    }
                }
            } else {
                var newPoint = point
                self.showAlert(address: newPoint.address, completion: { result in
                    if result {
                        let mapObjects = self.mapView.mapWindow.map.mapObjects
                        let point = YMKPoint(latitude: point.latitude, longitude: point.longitude)
                        let placemark = mapObjects.addPlacemark(with: point)
                        placemark.opacity = 1
                        placemark.isDraggable = false
                        placemark.setIconWith(UIImage(named:"SearchResult")!)
                        newPoint.mark = placemark
                        self.points.append(newPoint)
                        let pointDescriptionViewController = PointDescriptionViewController(point: newPoint)
                        self.navigationController?.pushViewController(pointDescriptionViewController, animated: true)
                    }
                })
            }
        }
    }

    func onMapLongTap(with map: YMKMap, point: YMKPoint) { }

    //MARK: - Private methods

    //Подписаться на отслеживание нажатий на карту
    private func setMapInputListener() {
        mapView.mapWindow.map.addInputListener(with: self)
    }

    //Собрать данные о точке
    private func createPoint(point mapPoint: YMKPoint, complition: @escaping(Point) -> Void){
        let geocodeLocation = CLGeocoder.init()
        geocodeLocation.reverseGeocodeLocation(CLLocation.init(latitude: mapPoint.latitude,
                                                               longitude: mapPoint.longitude)) {  (places, error) in
            var point = Point()
            if let error = error { print(error) }
            guard let place = places?.first else {return}
            let addressName = place.name?.appending(", ") ?? ""
            let city = place.subAdministrativeArea?.appending(", ") ?? ""
            let country = place.country?.appending(", ") ?? ""
            var fullAddress = country + city + addressName
            if fullAddress.last == " " { fullAddress.removeLast(2) }
            point.address = fullAddress
            point.latitude = mapPoint.latitude
            point.longitude = mapPoint.longitude
            complition(point)
        }
    }

    //Отобразить алерт с подтверждением о добавлении точки
    private func showAlert(address: String, completion: @escaping(Bool) -> Void) {
        let title = "Добавить новую точку на карту?"
        let message = address
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Да", style: .default, handler: { _ in
            completion(true)
        })
        let actionNo = UIAlertAction(title: "Нет", style: .cancel, handler: { _ in
            completion(false)
        })
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
    }
    
}



