//
//  StackMobExportViewController.h
//  UltimateAscent
//
//  Created by FRC on 3/28/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class SettingsData;

@interface StackMobExportViewController : UIViewController
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *smManagedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *pushTeamButton;
@property (nonatomic, strong) SettingsData *settings;
@property (weak, nonatomic) IBOutlet UIButton *pushTournamentButton;
- (IBAction)pushTeamData:(id)sender;
- (IBAction)pushTournamentData:(id)sender;
-(void)retrieveSettings;

@end
