//
//  PlaceInputViewController.m
//  CityGuide
//
//  Created by Konstantin Simakov on 11.07.13.
//
//

#import "PlaceInputViewController.h"

@interface PlaceInputViewController ()

@end

@implementation PlaceInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_cityNameInput release];
    [_placeNameInput release];
    [_saveButton release];
    [super dealloc];
}
- (IBAction)saveButtonOnClick:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.delegate onPlaceSaveWithCityName:self.cityNameInput.text placeName:self.placeNameInput.text coordinates:self.coordinate];
}

@end
