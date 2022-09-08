//
//  ViewController.swift
//  Flyweight
//
//  Created by Macbook on 05.05.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    //MARK: - Buttons
    let addAdress: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(hierarchicalColor: .red)
        let image = UIImage(systemName: "plus.app", withConfiguration: config)!
        button.setBackgroundImage(image, for: .normal)
        return button
    }()
    
    let route: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(hierarchicalColor: .red)
        let image = UIImage(systemName: "mappin.and.ellipse", withConfiguration: config)!
        button.setBackgroundImage(image, for: .normal)
        button.isHidden = true
        return button 
    }()
    
    let reset: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(hierarchicalColor: .red)
        let image = UIImage(systemName: "clear", withConfiguration: config)!
        button.setBackgroundImage(image, for: .normal)
        button.isHidden = true
        return button
    }()
    
    //MARK: - viewDidLoad
    
    var arrayAnnotation = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setConstraints()
        
        addAdress.addTarget(self, action: #selector(addAdressSelector), for: .touchUpInside)
        route.addTarget(self, action: #selector(routeSelector), for: .touchUpInside)
        reset.addTarget(self, action: #selector(resetSelector), for: .touchUpInside)
    }
    
    @objc func addAdressSelector() {
        alerAddAdress(title: "Add adress", placeholder: "Enter location") { [self] text in
            setupPlaceMark(adressPlace: text)
        }
     
    }
    
    @objc func routeSelector() {
        for index in 0...arrayAnnotation.count - 2 {
            createDirectionRequest(start: arrayAnnotation[index].coordinate, destination: arrayAnnotation[index + 1].coordinate)
        }
        mapView.showAnnotations(arrayAnnotation, animated: true)
    }
    
    @objc func resetSelector() {
        mapView.removeOverlay(mapView.overlays as! MKOverlay)
        mapView.removeAnnotation(mapView.annotations as! MKAnnotation)
        arrayAnnotation = [MKPointAnnotation]()
        route.isHidden = true
        reset.isHidden = true
    }
    
    //MARK: - LOCATION SETUP
    func setupPlaceMark(adressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] place, error in
            if let error = error {
                print(error)
                alertError(title: "Error", message: "Map out of service")
                return
            }
            
            guard let placemark = place else {return}
            let placemarks = placemark.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            
            guard let placeMarkLocation = placemarks?.location else {return}
            annotation.coordinate = placeMarkLocation.coordinate
            
            arrayAnnotation.append(annotation)
            
            if arrayAnnotation.count > 2 {
                route.isHidden = false
                reset.isHidden = false
            }
            
            mapView.showAnnotations(arrayAnnotation, animated: true)
        }
    }

    //MARK: - Direction request
    
    private func createDirectionRequest(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: start)
        let destionationLocation = MKPlacemark(coordinate: destination)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destionationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.alertError(title: "Error", message: "Failed route")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
        
    }
    
}

//MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderLine = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderLine.strokeColor = .blue
        return renderLine
    }
    
}

//MARK: - Constraints buttons

extension ViewController {
    
    func setConstraints() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(addAdress)
        NSLayoutConstraint.activate([
            addAdress.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            addAdress.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addAdress.widthAnchor.constraint(equalToConstant: 70),
            addAdress.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        view.addSubview(route)
        NSLayoutConstraint.activate([
            route.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 30),
            route.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            route.widthAnchor.constraint(equalToConstant: 70),
            route.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        view.addSubview(reset)
        NSLayoutConstraint.activate([
            reset.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            reset.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            reset.widthAnchor.constraint(equalToConstant: 70),
            reset.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}

