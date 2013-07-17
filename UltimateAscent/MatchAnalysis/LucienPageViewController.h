//
//  LucienPageViewController.h
//  UltimateAscent
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class SettingsData;
@class PopUpPickerViewController;

@interface LucienPageViewController : UIViewController <UITextFieldDelegate, PopUpPickerDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) PopUpPickerViewController *averagePicker;
@property (nonatomic, retain) NSMutableArray *averageList;
@property (nonatomic, retain) UIPopoverController *averagePickerPopover;
@property (nonatomic, retain) PopUpPickerViewController *heightPicker;
@property (nonatomic, retain) NSMutableArray *heightList;
@property (nonatomic, retain) UIPopoverController *heightPickerPopover;

@property (weak, nonatomic) IBOutlet UIButton *autonAverage;
@property (weak, nonatomic) IBOutlet UITextField *autonNormal;
@property (weak, nonatomic) IBOutlet UITextField *autonFactor;

@property (weak, nonatomic) IBOutlet UIButton *teleOpAverage;
@property (weak, nonatomic) IBOutlet UITextField *teleOpNormal;
@property (weak, nonatomic) IBOutlet UITextField *teleOpFactor;

@property (weak, nonatomic) IBOutlet UIButton *climbAverage;
@property (weak, nonatomic) IBOutlet UITextField *climbNormal;
@property (weak, nonatomic) IBOutlet UITextField *climbFactor;

@property (weak, nonatomic) IBOutlet UIButton *driverAverage;
@property (weak, nonatomic) IBOutlet UITextField *driverNormal;
@property (weak, nonatomic) IBOutlet UITextField *driverFactor;

@property (weak, nonatomic) IBOutlet UIButton *speedAverage;
@property (weak, nonatomic) IBOutlet UITextField *speedNormal;
@property (weak, nonatomic) IBOutlet UITextField *speedFactor;

@property (weak, nonatomic) IBOutlet UIButton *defenseAverage;
@property (weak, nonatomic) IBOutlet UITextField *defenseNormal;
@property (weak, nonatomic) IBOutlet UITextField *defenseFactor;

@property (weak, nonatomic) IBOutlet UITextField *height1Normal;
@property (weak, nonatomic) IBOutlet UIButton *height1Average;
@property (weak, nonatomic) IBOutlet UITextField *height1Factor;

@property (weak, nonatomic) IBOutlet UITextField *height2Normal;
@property (weak, nonatomic) IBOutlet UIButton *height2Average;
@property (weak, nonatomic) IBOutlet UITextField *height2Factor;

@property (weak, nonatomic) IBOutlet UIButton *calculateButton;

- (IBAction)selectAverage:(id)sender;
- (IBAction)selectHeight:(id)sender;

-(float)calculateNumbers:(NSMutableArray *)list forAverage:(NSNumber *)average forNormal:(NSNumber *)normal forFactor:(NSNumber *)factor;

- (NSString *)applicationDocumentsDirectory;
-(void)setDisplayData;
- (void)retrieveSettings;

@end
