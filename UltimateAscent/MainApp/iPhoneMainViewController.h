//
//  iPhoneMainViewController.h
//  UltimateAscent
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface iPhoneMainViewController : UIViewController
@property (nonatomic, retain) DataManager *dataManager;
@property (strong, nonatomic) IBOutlet UIWebView *viewWeb;
-(void) extractMatchList:(NSArray *)allLines;

@end
