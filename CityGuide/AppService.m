//
//  AppService.m
//  CityGuide
//
//  Created by Konstantin Simakov on 24.06.13.
//
//

#import "AppService.h"
#import "DBPlaceObject.h"
#import "NSDictionary+Utility.h"

@implementation AppService

static AppService *_sharedInstance;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(AppService *)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

-(void)beginUpdateData {
    NSString *urlString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"data_url"] autorelease];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSString *jsonText = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            NSDictionary *dataDict = [AppService getObjectFromJSON:jsonText];
            if (dataDict) {
                NSArray *places = [dataDict valueForKeyNotNull:@"places"];
                if (places != nil) {
                    [self beginSavePlaces:places];
                }
            }
            else {
                NSLog(@"There's some error while parsing JSON response");
            }
        }
        else {
            NSLog(@"There's some error with data %@", error.description);
        }
    }];
}

-(void)beginSavePlaces:(NSArray *)places {
    NSFetchRequest * requestAll = [[[NSFetchRequest alloc] init] autorelease];
    [requestAll setEntity:[NSEntityDescription entityForName:@"DBPlaceObject" inManagedObjectContext:[[AppService sharedInstance] managedObjectContext]]];
    
    NSError *fetchError = nil;
    NSArray *oldPlaces = [[[AppService sharedInstance] managedObjectContext] executeFetchRequest:requestAll error:&fetchError];
    if (fetchError == nil) {
        for (DBPlaceObject *oldPlace in oldPlaces) {
            [[[AppService sharedInstance] managedObjectContext] deleteObject:oldPlace];
        }
    }
    
    for (NSDictionary *placeInfo in places) {
        DBPlaceObject *placeObject = placeObject = (DBPlaceObject *)[NSEntityDescription insertNewObjectForEntityForName:@"DBPlaceObject" inManagedObjectContext:[[AppService sharedInstance] managedObjectContext]];
        
        placeObject.latitude = [placeInfo valueForKeyNotNull:@"latitude"];
        placeObject.longtitude = [placeInfo valueForKeyNotNull:@"longtitude"];
        placeObject.text = [placeInfo valueForKeyNotNull:@"text"];
        placeObject.city = [placeInfo valueForKeyNotNull:@"city"];
        placeObject.image = [placeInfo valueForKeyNotNull:@"image"];
    }
    NSError *error = nil;
    [[[AppService sharedInstance] managedObjectContext] save:&error];
    if (!error) {
        NSLog(@"Successfully saved");
    }
    else {
        NSLog(@"There's some error with saving data: %@", error.description);
    }
}

+ (id)getObjectFromJSON:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error != nil) {
        NSLog(@"Error while JSON parse: %@", error);
        return nil;
    }
    return object;
}

#pragma mark - Core Data stack
/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
