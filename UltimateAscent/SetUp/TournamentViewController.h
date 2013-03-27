//
//  TournamentViewController.h
//  UltimateAscent
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TournamentPickerController.h"
#import "AlliancePickerController.h"

@class SettingsData;
@class DataManager;

@interface TournamentViewController : UIViewController <TournamentPickerDelegate>
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIImageView *mainLogo;
@property (nonatomic, retain) IBOutlet UIImageView *splashPicture;
@property (nonatomic, retain) IBOutlet UILabel *pictureCaption;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) IBOutlet UIButton *adminButton;
@property (nonatomic, retain) IBOutlet UIButton *overrideButton;
@property (nonatomic, retain) IBOutlet UIButton *modeButton;
@property (nonatomic, retain) IBOutlet UIButton *bluetoothButton;
@property (nonatomic, strong) IBOutlet UILabel *tournamentLabel;

// Tournament Picker
@property (nonatomic, retain) IBOutlet UIButton *tournamentButton;
@property (nonatomic, retain) NSMutableArray *tournamentList;
@property (nonatomic, retain) NSArray *tournamentData;
@property (nonatomic, retain) TournamentPickerController *tournamentPicker;
@property (nonatomic, retain) UIPopoverController *tournamentPickerPopover;
-(IBAction)TournamentSelectionChanged:(id)sender;

// Alliance Picker
@property (nonatomic, retain) IBOutlet UIButton *allianceButton;
@property (nonatomic, retain) NSMutableArray *allianceList;
@property (nonatomic, retain) AlliancePickerController *alliancePicker;
@property (nonatomic, retain) UIPopoverController *alliancePickerPopover;
-(IBAction)AllianceSelectionChanged:(id)sender;

// User Access Control
typedef enum {
    NoOverride,
    OverrideAllianceSelection,
} OverrideMode;

-(void)checkOverrideCode:(UIButton *)button;
-(void)checkAdminCode:(UIButton *)button;


@end
