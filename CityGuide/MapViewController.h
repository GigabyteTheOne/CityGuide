//
//  MapViewController.h
//  CityGuide
//
//  Created by Konstantin Simakov on 03.07.13.
//
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController : UIViewController <UISplitViewControllerDelegate>
{
}

@property (retain) NSNumber *latitude;
@property (retain) NSNumber *longitude;
@property (retain) NSNumber *zoom;
@property (readonly) GMSMapView *mapView;

@property (retain, setter=setPlaces:) NSArray *places;


@property (strong, nonatomic) UIPopoverController *masterPopoverController;

-(void)setCameraLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude zoom:(NSNumber *)zoom animated:(BOOL)animated;

@end
