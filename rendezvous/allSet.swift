//
//  allSet.swift
//  Rendezvous
//
//  Created by Philippe Kimura-Thollander on 9/6/15.
//  Copyright © 2015 Philippe Kimura-Thollander. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreBluetooth

class allSet: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {

    var uname: NSString = ""
    var id: NSString = ""
    var result: NSString = ""
    var friends: NSArray = []
    
    let locationManager = CLLocationManager()
    var region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "29B1AD96-1DF0-4392-8C8A-7387F9E7BD84")!, identifier: "")
    var periphmanager: CBPeripheralManager! = nil
    var meters: Double = 0
    var lat: NSNumber! = nil
    var long: NSNumber! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self;
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse ) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeaconsInRegion(region)
        
        beginBroadcasting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "nearby"){
            let destinationVC:locator = segue.destinationViewController as! locator
            destinationVC.meters = self.meters
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons)
        
        if(beacons.count > 0){
            self.meters = beacons[0].accuracy;
            self.performSegueWithIdentifier("nearby", sender: self)
        }
        
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager){
        
        if(peripheral.state == CBPeripheralManagerState.PoweredOn){
            let dict: [String:AnyObject] = self.region.peripheralDataWithMeasuredPower(nil) as! [String:AnyObject]
            periphmanager.startAdvertising(dict)
        }
        print(peripheral.state)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil{
            print(error)
        }
        print("Broadcasting!")
    }
    
    /*
    * Initialize the peripheral manager which is responsible for broadcasting
    */
    func beginBroadcasting(){
        
        var locValue:CLLocationCoordinate2D = self.locationManager.location!.coordinate
        self.lat = locValue.latitude
        self.long = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")

        var majVal = self.lat
        var minVal = self.long

        region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "29B1AD96-1DF0-4392-8C8A-7387F9E7BD84")!,identifier: "")
        region.setValue(majVal, forKey: "major")
        region.setValue(minVal, forKey: "minor")
        self.periphmanager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        print("Error while updating location " + error.localizedDescription)
    }

}
