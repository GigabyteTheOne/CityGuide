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

-(void)beginUpdateData;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
