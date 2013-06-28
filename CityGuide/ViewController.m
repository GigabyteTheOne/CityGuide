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

@interface ViewController ()

@end

@implementation ViewController
@synthesize tableView = _tableView;

- (id)init
{
    self = [super init];
    if (self) {
        _tableData = [[NSDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_tableData release];
    [_tableView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[AppService sharedInstance] beginUpdateDataWithCompletionBlock:^{
        [self setDataToTable];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDataToTable
{
    NSArray *places = [[AppService sharedInstance] getAllPlaces];
    NSMutableDictionary *tmpTableData = [[NSMutableDictionary new] autorelease];
    
    NSString *lastCityName = @"";
    for (DBPlaceObject *place in places) {
        unichar firstLetterChar = [place.city characterAtIndex:0];
        NSString *firstLetter = [NSString stringWithFormat:@"%C", firstLetterChar];
        
        NSMutableArray *curArray = [tmpTableData objectForKey:firstLetter];
        if (curArray == nil) {
            curArray = [[NSMutableArray new] autorelease];
        }
        
        if (![lastCityName isEqualToString:place.city]) {
            PlaceTableCellInfo *cellCityInfo = [[[PlaceTableCellInfo alloc] init] autorelease];
            cellCityInfo.text = place.city;
            [curArray addObject:cellCityInfo];
            lastCityName = place.city;
        }
        PlaceTableCellInfo *cellPlaceInfo = [[[PlaceTableCellInfo alloc] init] autorelease];
        cellPlaceInfo.text = place.text;
        cellPlaceInfo.imageUrl = place.image;
        [curArray addObject:cellPlaceInfo];
        
        [tmpTableData setValue:curArray forKey:firstLetter];
    }
    
    _tableData = [tmpTableData retain];
    [_tableView reloadData];
}



#pragma mark - Table datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableData allKeys].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[_tableData allKeys] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[_tableData allKeys] objectAtIndex:section];
    return ((NSArray *)[_tableData valueForKey:key]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] autorelease];
    }
    
    NSString *key = [[_tableData allKeys] objectAtIndex:indexPath.section];
    NSArray *sectionData = [_tableData valueForKey:key];
    PlaceTableCellInfo *placeInfo = [sectionData objectAtIndex:indexPath.row];
    cell.textLabel.text = placeInfo.text;
    if ((cell.imageView.image == nil) && (placeInfo.imageUrl != nil)) {
        [[AppService sharedInstance] beginLoadImage:placeInfo.imageUrl withCompletionBlock:^(UIImage *image) {
            cell.imageView.image = image;
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    return cell;
}


@end
