//
//  MapViewController.m
//  CityGuide
//
//  Created by Konstantin Simakov on 03.07.13.
//
//

#import "MapViewController.h"
#import "DBPlaceObject.h"
#import "AppService.h"

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
    _mapView.delegate = self;
    self.view = _mapView;
    
    [self updatePlacesOnMap];
}

-(void)updatePlacesOnMap
{
    if ((_places != nil) && (_places.count > 0)) {
        [_mapView clear];
        for (DBPlaceObject *place in _places) {
            GMSMarker *marker = [[[GMSMarker alloc] init] autorelease];
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

-(void)createPlaceWithCityName:(NSString *)cityName placeName:(NSString *)placeName coordinate:(CLLocationCoordinate2D)coordinate
{
    GMSMarker *marker = [[[GMSMarker alloc] init] autorelease];
    marker.position = coordinate;
    marker.title = placeName;
    marker.snippet = cityName;
    marker.map = _mapView;
    
    [[AppService sharedInstance] addNewPlaceWithCityName:cityName placeName:placeName coordinate:coordinate];
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

#pragma mark - Map delegate

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLGeocoder *geoCoder = [[[CLGeocoder alloc] init] autorelease];
    CLLocation *location = [[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] autorelease];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ((!error) && (placemarks.count > 0)) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CGPoint point = [[mapView projection] pointForCoordinate:coordinate];
            
            NSString *cityName = placemark.locality;
            NSLog(@"%@", cityName);
            if (cityName == nil) {
                cityName = @"";
            }
            
            PlaceInputViewController *inputViewController = [[[PlaceInputViewController alloc] initWithNibName:@"PlaceInputViewController" bundle:nil] autorelease];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.navigationController pushViewController:inputViewController animated:YES];
            }
            else {
                inputViewController.contentSizeForViewInPopover = CGSizeMake(320, 140);
                
                if (_placeInputPopover) {
                    [_placeInputPopover release]; //old popover
                }
                _placeInputPopover = [[UIPopoverController alloc] initWithContentViewController:inputViewController];
                [_placeInputPopover presentPopoverFromRect:CGRectMake(point.x, point.y, 1, 1) inView:mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            inputViewController.coordinate = coordinate;
            inputViewController.delegate = self;
            inputViewController.cityNameInput.text = cityName;
            
        }
        else {
            NSLog(@"Error with getting location info: %@", error);
        }
    }];
}

#pragma mark - PlaceInputDelegate methods

-(void)onPlaceSaveWithCityName:(NSString *)cityName placeName:(NSString *)placeName coordinates:(CLLocationCoordinate2D)coordinate
{
    [self createPlaceWithCityName:cityName placeName:placeName coordinate:coordinate];
    if (_placeInputPopover) {
        [_placeInputPopover dismissPopoverAnimated:YES];
    }
}



@end
