//
//  DownloadPageViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PopUpPickerViewController.h"

@class MatchData;
@class TeamScore;
@class SettingsData;
@class DataManager;

@interface DownloadPageViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) SettingsData *settings;
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UIButton *exportTeamData;
@property (nonatomic, weak) IBOutlet UIButton *exportMatchData;
@property (nonatomic, weak) IBOutlet UIButton *ftpButton;
@property (nonatomic, strong) NSString *exportPath;
@property (nonatomic, weak) IBOutlet UIButton *iPadExportButton;


@property (nonatomic, weak) IBOutlet UIButton *syncButton;
@property (nonatomic, strong) PopUpPickerViewController *syncPicker;
@property (nonatomic, strong) UIPopoverController *syncPickerPopover;
@property (nonatomic, strong) NSMutableArray *syncList;

-(IBAction)exportTapped:(id)sender;
-(void)emailTeamData;
-(void)emailMatchData;
-(NSString *)buildMatchCSVOutput:(TeamScore *)teamScore;
-(NSString *)buildDanielleMatchCSVOutput:(MatchData *)match forTeam:(TeamScore *)teamScore;
-(NSString *)applicationDocumentsDirectory;
-(void)buildEmail:(NSString *)filePath attach:(NSString *)emailFile subject:(NSString *)emailSubject;
-(void)retrieveSettings;

@end
