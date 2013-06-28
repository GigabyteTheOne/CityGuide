//
//  ViewController.h
//  CityGuide
//
//  Created by Konstantin Simakov on 24.06.13.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSDictionary *_tableData;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
