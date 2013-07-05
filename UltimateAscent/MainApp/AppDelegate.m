//
//  AppDelegate.m
//  UltimateAscent
//
//  Created by FRC on 1/11/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadCSVData.h"
#import "DataManager.h"
#import "SplashPageViewController.h"
#import "iPhoneMainViewController.h"
#import "TeamDataInterfaces.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;
@synthesize splashPageViewController;
@synthesize iPhoneMainViewController = _iPhoneMainViewController;
@synthesize dataManager = _dataManager;
@synthesize loadDataFromBundle;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    // Create the managed object and persistant store
    _dataManager = [[DataManager alloc] init];
    [self initializeDataCollections];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        navigationController = (UINavigationController *)self.window.rootViewController;
        _iPhoneMainViewController = (iPhoneMainViewController *)navigationController.topViewController;
        _iPhoneMainViewController.dataManager = self.dataManager;
        return YES;
    }
    LoadCSVData *loadData = [[LoadCSVData alloc] initWithDataManager:_dataManager];
    [loadData loadCSVDataFromBundle];

    navigationController = (UINavigationController *)self.window.rootViewController;
    splashPageViewController = (SplashPageViewController *)navigationController.topViewController;
    splashPageViewController.dataManager = self.dataManager;
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (url != nil && [url isFileURL]) {
        LoadCSVData *loadData = [LoadCSVData new];
        [loadData handleOpenURL:url];
    }
    // Temporary fix to help Main Scouting Remember where it is
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"dataMarker.csv"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:storePath]) {
        // dataMarker.csv doesn't already not exist");
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"dataMarker" ofType:@"csv"];  
        if (defaultStorePath) {
            // Copy dataMarker.csv from the main bundle
            NSLog(@"Found a dataMarker.csv file in the main bundle");
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }
    
    return YES;

}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url 
 sourceApplication:(NSString *)sourceApplication 
        annotation:(id)annotation {    
    NSLog(@"openURL");
    if (url != nil && [url isFileURL]) {
        _dataManager = [[DataManager alloc] init];
        LoadCSVData *loadData = [[LoadCSVData alloc] initWithDataManager:_dataManager];
        [loadData handleOpenURL:url];
    }
    NSLog(@"end of openurl");
    return YES;
}

- (void) initializeDataCollections {
    NSString *teamDataPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"teamDataDictionary.plist"];
//    [[TeamDataInterfaces new] createTeamDataCollection:_dataManager dictionaryPath:teamDataPath];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [_dataManager saveContext];
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
