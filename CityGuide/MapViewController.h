//
//  MapViewController.h
//  CityGuide
//
//  Created by Konstantin Simakov on 03.07.13.
//
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController : UIViewController
{
    GMSMapView *_mapView;
}

@property (retain) NSNumber *latitude;
@property (retain) NSNumber *longitude;
@property (retain) NSNumber *zoom;

@end
