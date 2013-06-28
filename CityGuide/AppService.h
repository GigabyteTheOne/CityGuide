//
//  AppService.h
//  CityGuide
//
//  Created by Konstantin Simakov on 24.06.13.
//
//

#import <Foundation/Foundation.h>

@interface AppService : NSObject
{
    AppService *_sharedInstance;
}

+(AppService *)sharedInstance;
+(id)getObjectFromJSON:(NSString *)jsonString;

-(void)beginUpdateDataWithCompletionBlock:(void(^)())completionBlock;
-(void)beginLoadImage:(NSString *)imageUrl withCompletionBlock:(void(^)(UIImage *image))completionBlock;
- (NSArray *)getAllPlaces;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
