//
//  AppDelegate.h
//  UltimateAscent
//
//  Created by FRC on 1/11/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SplashPageViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) SplashPageViewController *splashPageViewController;
@property (nonatomic, assign) BOOL loadDataFromBundle;

- (NSString *)applicationDocumentsDirectory;


@end
