//
//  LucienPageViewController.h
//  UltimateAscent
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class SettingsData;

@interface LucienPageViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) SettingsData *settings;
@property (weak, nonatomic) IBOutlet UITextField *autonNormal;
@property (weak, nonatomic) IBOutlet UITextField *autonFactor;

@property (weak, nonatomic) IBOutlet UITextField *teleOpNormal;
@property (weak, nonatomic) IBOutlet UITextField *teleOpFactor;

@property (weak, nonatomic) IBOutlet UITextField *climbNormal;
@property (weak, nonatomic) IBOutlet UITextField *climbFactor;

@property (weak, nonatomic) IBOutlet UITextField *driverNormal;
@property (weak, nonatomic) IBOutlet UITextField *driverFactor;

@property (weak, nonatomic) IBOutlet UITextField *speedNormal;
@property (weak, nonatomic) IBOutlet UITextField *speedFactor;

@property (weak, nonatomic) IBOutlet UITextField *defenseNormal;
@property (weak, nonatomic) IBOutlet UITextField *defenseFactor;

@property (weak, nonatomic) IBOutlet UITextField *height1Factor;
@property (weak, nonatomic) IBOutlet UITextField *height2Factor;

- (NSString *)applicationDocumentsDirectory;
-(void)setDisplayData;
- (void)retrieveSettings;

@end
