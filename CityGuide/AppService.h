//
//  AppService.h
//  CityGuide
//
//  Created by Konstantin Simakov on 24.06.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AppService : NSObject
{
    AppService *_sharedInstance;
}

+(AppService *)sharedInstance;
+(id)getObjectFromJSON:(NSString *)jsonString;

-(void)beginUpdateDataWithCompletionBlock:(void(^)())completionBlock;
- (NSArray *)getAllPlaces;
- (void)addNewPlaceWithCityName:(NSString *)cityName placeName:(NSString *)placeName coordinate:(CLLocationCoordinate2D)coordinate;
- (NSArray *)getPlacesInRadius:(int)radiusValue ofLocation:(CLLocation*)location;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
