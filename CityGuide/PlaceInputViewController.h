//
//  PlaceInputViewController.h
//  CityGuide
//
//  Created by Konstantin Simakov on 11.07.13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol PlaceInputDelegate <NSObject>

-(void)onPlaceSaveWithCityName:(NSString*)cityName placeName:(NSString*)placeName coordinates:(CLLocationCoordinate2D)coordinate;

@end

@interface PlaceInputViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *cityNameInput;
@property (retain, nonatomic) IBOutlet UITextField *placeNameInput;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)saveButtonOnClick:(id)sender;

@property (assign) id<PlaceInputDelegate> delegate;
@property (assign) CLLocationCoordinate2D coordinate;

@end
