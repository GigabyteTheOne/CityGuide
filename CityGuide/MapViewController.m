//
//  MapViewController.m
//  CityGuide
//
//  Created by Konstantin Simakov on 03.07.13.
//
//

#import "MapViewController.h"
#import "DBPlaceObject.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize places = _places;
@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _latitude = [[NSNumber numberWithDouble:0.0] retain];
        _longitude = [[NSNumber numberWithDouble:0.0] retain];
    }
    return self;
}

- (void)dealloc
{
    [_latitude release];
    [_longitude release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[_latitude doubleValue] longitude:[_longitude doubleValue] zoom:1];
    _mapView = [[GMSMapView mapWithFrame:CGRectZero camera:camera] retain];
//    _mapView.myLocationEnabled = YES;
    self.view = _mapView;
    
    [self updatePlacesOnMap];
}

-(void)updatePlacesOnMap
{
    if ((_places != nil) && (_places.count > 0)) {
        [_mapView clear];
        for (DBPlaceObject *place in _places) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([place.latitude doubleValue], [place.longtitude doubleValue]);
            marker.title = place.text;
            marker.snippet = place.city;
            marker.map = _mapView;
        }
    }
}

-(void)setPlaces:(NSArray *)places
{
    if (places != _places) {
        [_places release];
        [places retain];
        _places = places;
        
        [self updatePlacesOnMap];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCameraLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude zoom:(NSNumber *)zoom animated:(BOOL)animated
{
    GMSCameraPosition *newCamera = [GMSCameraPosition cameraWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue] zoom:[zoom floatValue]];
    if (animated) {
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat: 0.5f] forKey:kCATransactionAnimationDuration];
        [_mapView animateToCameraPosition:newCamera];
        [CATransaction commit];
    }
    else {
        [_mapView moveCamera:[GMSCameraUpdate setCamera:newCamera]];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Places";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
