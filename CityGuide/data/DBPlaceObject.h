//
//  DBPlaceObject.h
//  CityGuide
//
//  Created by Konstantin Simakov on 24.06.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBPlaceObject : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * image;

@end
