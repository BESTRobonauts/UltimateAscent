//
//  ImportDataViewController.h
//  UltimateAscent
//
//  Created by FRC on 4/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class SettingsData;

@interface ImportDataViewController : UIViewController
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, strong) SettingsData *settings;
@property (weak, nonatomic) IBOutlet UIButton *importSMButton;
-(void)retrieveSettings;

@end
