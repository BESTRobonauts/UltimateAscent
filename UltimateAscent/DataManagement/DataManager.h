//
//  DataManager.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMClient;
@class SMCoreDataStore;

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *smManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) SMCoreDataStore *coreDataStore;
@property (strong, nonatomic) SMClient *client;
@property (nonatomic, assign) BOOL loadDataFromBundle;

- (void)saveContext;
- (NSString *)applicationDocumentsDirectory;
-(BOOL)databaseExists;
-(NSManagedObjectContext *)getSMContext;
@end
