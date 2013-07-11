//
//  ViewController.m
//  CityGuide
//
//  Created by Konstantin Simakov on 24.06.13.
//
//

#import "ViewController.h"
#import "AppService.h"
#import "DBPlaceObject.h"
#import "PlaceTableCellInfo.h"
#import "PlaceTableViewCell.h"

@interface ViewController ()

@end

const int CELL_HEIGHT = 56;

@implementation ViewController
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _filterValue = -1;
    _tableData = [[NSDictionary alloc] init];
    _filterBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonOnClick:)];
    _refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonOnClick:)];
//    _addBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonOnClick:)];
    
    self.title = @"List of places";
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:_filterBarButton, nil]];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:_refreshBarButton, nil]];
        
    if (_mapViewController == nil) {
        _mapViewController = [[MapViewController alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewPlaceNotification:) name:@"NewPlace" object:nil];
}

- (void)onNewPlaceNotification:(NSNotification *)notification
{
    [self refreshTableData];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSArray *places = [[AppService sharedInstance] getAllPlaces];
    if ((places != nil) && (places.count > 0)) {
        [self setDataToTable:places];
    }
    else {
        [self downloadPlaces];
    }
}

- (void)viewDidUnload
{
    [_tableData release];
    [_tableView release];
    [_filterBarButton release];
    [_refreshBarButton release];
    [_filterBarButton release];
    if (_mapViewController) {
        [_mapViewController release];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTableData
{
    if (_filterValue != -1) {
        [self startProgressView];
        
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
    }
    else {
        NSArray *places = [[AppService sharedInstance] getAllPlaces];
        [self setDataToTable:places];
    }
}

- (void)setDataToTable:(NSArray *)places
{
    NSMutableDictionary *tmpTableData = [[NSMutableDictionary new] autorelease];
    NSMutableArray *newAlphabetIndex = [[NSMutableArray new] autorelease];
    
    NSString *lastCityName = @"";
    for (DBPlaceObject *place in places) {
        if ((place.city != nil) && (place.city.length > 0)) {
            unichar firstLetterChar = [place.city characterAtIndex:0];
            NSString *firstLetter = [NSString stringWithFormat:@"%C", firstLetterChar];
            
            NSMutableArray *curArray = [tmpTableData objectForKey:firstLetter];
            if (curArray == nil) {
                curArray = [[NSMutableArray new] autorelease];
                [newAlphabetIndex addObject:firstLetter];
            }
            
            if (![lastCityName isEqualToString:place.city]) {
                PlaceTableCellInfo *cellCityInfo = [[[PlaceTableCellInfo alloc] init] autorelease];
                cellCityInfo.text = place.city;
                cellCityInfo.isCityCell = YES;
                [curArray addObject:cellCityInfo];
                lastCityName = place.city;
            }
            PlaceTableCellInfo *cellPlaceInfo = [[[PlaceTableCellInfo alloc] init] autorelease];
            cellPlaceInfo.text = place.text;
            cellPlaceInfo.imageUrl = place.image;
            cellPlaceInfo.placeObject = place;
            cellPlaceInfo.isCityCell = NO;
            [curArray addObject:cellPlaceInfo];
            
            [tmpTableData setValue:curArray forKey:firstLetter];
        }
    }
    
    _tableData = [tmpTableData retain];
    _alphabetIndex = [newAlphabetIndex retain];
    [_tableView reloadData];
    
    _mapViewController.places = places;
}

- (void)downloadPlaces
{
    [self startProgressView];
    
    [[AppService sharedInstance] beginUpdateDataWithCompletionBlock:^{
        NSArray *places = [[AppService sharedInstance] getAllPlaces];
        [self setDataToTable:places];
        [self stopProgressView];
    }];
}

- (void)startProgressView
{
    CGRect frame = self.view.bounds;
    _backgroundActivityView = [[UIView alloc] initWithFrame:frame];
    _backgroundActivityView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.7];
    [self.view addSubview:_backgroundActivityView];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.frame = self.view.bounds;
    [_activityIndicator startAnimating];
    [self.view addSubview:_activityIndicator];
}

- (void)stopProgressView
{
    if (_backgroundActivityView != nil) {
        [_backgroundActivityView removeFromSuperview];
        [_backgroundActivityView release];
    }
    if (_activityIndicator != nil) {
        [_activityIndicator stopAnimating];
        [_activityIndicator removeFromSuperview];
        [_activityIndicator release];
    }
}

#pragma mark - Table datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _alphabetIndex.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_alphabetIndex objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_alphabetIndex objectAtIndex:section];
    return ((NSArray *)[_tableData valueForKey:key]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_alphabetIndex objectAtIndex:indexPath.section];
    NSArray *sectionData = [_tableData valueForKey:key];
    PlaceTableCellInfo *placeInfo = [sectionData objectAtIndex:indexPath.row];
    
    NSString *simpleTableIdentifier = @"PlaceCell";
    if (placeInfo.isCityCell) {
        simpleTableIdentifier = @"CityCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        if ([simpleTableIdentifier isEqualToString:@"PlaceCell"]) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaceTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] autorelease];
        }
    }
    
    if ([simpleTableIdentifier isEqualToString:@"PlaceCell"]) {
        PlaceTableViewCell *placeCell = (PlaceTableViewCell *)cell;
        placeCell.nameLabel.text = placeInfo.text;
        if (placeInfo.imageUrl != nil) {
            if (placeInfo.image == nil) {
                placeCell.placeImage.image = [UIImage imageNamed:@"waiting_ph"];
                
                [self beginLoadImage:placeInfo.imageUrl withCompletionBlock:^(UIImage *image) {
                    if (image != nil) {
                        placeInfo.image = image;
                    }
                    else {
                        placeInfo.image = [UIImage imageNamed:@"no_image_ph"];
                    }
                    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
            else {
                placeCell.placeImage.image = placeInfo.image;
            }
        }
        else {
            placeCell.placeImage.image = placeInfo.image = [UIImage imageNamed:@"no_image_ph"];
        }
        return placeCell;
    }
    else {
        cell.textLabel.text = placeInfo.text;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

-(void)beginLoadImage:(NSString *)urlString withCompletionBlock:(void(^)(UIImage *image))completionBlock {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            completionBlock(image);
        }
        else {
            completionBlock(nil);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [_alphabetIndex objectAtIndex:indexPath.section];
    NSArray *sectionData = [_tableData valueForKey:key];
    PlaceTableCellInfo *placeInfo = [sectionData objectAtIndex:indexPath.row];
    if (placeInfo.placeObject != nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.navigationController pushViewController:_mapViewController animated:YES];
            [_mapViewController setCameraLatitude:placeInfo.placeObject.latitude longitude:placeInfo.placeObject.longtitude zoom:[NSNumber numberWithFloat:14] animated:NO];
        }
        else {
            [_mapViewController setCameraLatitude:placeInfo.placeObject.latitude longitude:placeInfo.placeObject.longtitude zoom:[NSNumber numberWithFloat:14] animated:YES];
        }
    }
}

#pragma mark - Navigation buttons

- (void)filterButtonOnClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Filter distance" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Remove filter" otherButtonTitles:@"1 mile", @"10 miles", @"100 miles", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)refreshButtonOnClick:(id)sender {
    [self downloadPlaces];
}

- (void)addButtonOnClick:(id)sender {
    
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            _filterValue = 1;
            break;
        case 2:
            _filterValue = 10;
            break;
        case 3:
            _filterValue = 100;
            break;
        case 0:
            _filterValue = -1;
            break;
        default:
            break;
    }
    [self refreshTableData];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    NSArray *places = [[AppService sharedInstance] getPlacesInRadius:_filterValue ofLocation:newLocation];
    [self setDataToTable:places];
    
    [manager release];
    [self stopProgressView];
}


@end
