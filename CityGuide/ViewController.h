//
//  ViewController.h
//  CityGuide
//
//  Created by Konstantin Simakov on 24.06.13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>
{
    NSDictionary *_tableData;
    UIBarButtonItem *_filterBarButton;
    UIBarButtonItem *_refreshBarButton;
    UIBarButtonItem *_addBarButton;
    
    UIView *_backgroundActivityView;
    UIActivityIndicatorView *_activityIndicator;
    
    int _filterValue;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
