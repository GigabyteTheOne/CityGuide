//
//  MapViewController.m
//  CityGuide
//
//  Created by Konstantin Simakov on 03.07.13.
//
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_latitude == nil) {
        _latitude = [NSNumber numberWithDouble:0.0];
    }
    if (_longitude == nil) {
        _longitude = [NSNumber numberWithDouble:0.0];
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[_latitude doubleValue] longitude:[_longitude doubleValue] zoom:14];
    _mapView = [[GMSMapView mapWithFrame:CGRectZero camera:camera] retain];
    _mapView.myLocationEnabled = YES;
    self.view = _mapView;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([_latitude doubleValue], [_longitude doubleValue]);
//    marker.title = @"Sydney";
//    marker.snippet = @"Australia";
    marker.map = _mapView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
