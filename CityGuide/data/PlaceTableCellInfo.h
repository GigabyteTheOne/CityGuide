//
//  PlaceTableCellInfo.h
//  CityGuide
//
//  Created by Konstantin Simakov on 29.06.13.
//
//

#import <Foundation/Foundation.h>
#import "DBPlaceObject.h"

@interface PlaceTableCellInfo : NSObject

@property (retain) NSString *text;
@property (retain) NSString *imageUrl;
@property (retain) UIImage *image;
@property (retain) DBPlaceObject *placeObject;

@end
