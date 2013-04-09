//
//  iDeviceExportViewController.h
//  UltimateAscent
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface iDeviceExportViewController : UIViewController
@property (nonatomic, retain) DataManager *dataManager;
@property (weak, nonatomic) IBOutlet UIButton *exportMatchListButton;

@end
