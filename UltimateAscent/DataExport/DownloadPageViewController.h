//
//  DownloadPageViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@class MatchData;
@class TeamScore;
@class SettingsData;

@interface DownloadPageViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) SettingsData *settings;
@property (nonatomic, strong) IBOutlet UIImageView *mainLogo;
@property (nonatomic, strong) IBOutlet UIImageView *splashPicture;
@property (nonatomic, strong) IBOutlet UILabel *pictureCaption;
@property (nonatomic, strong) IBOutlet UIButton *exportTeamData;
@property (nonatomic, strong) IBOutlet UIButton *exportMatchData;
@property (nonatomic, strong) NSString *exportPath;

-(IBAction)exportTapped:(id)sender;
-(void)emailTeamData;
-(void)emailMatchData;
-(NSString *)buildMatchCSVOutput:(TeamScore *)teamScore;
-(NSString *)buildDanielleMatchCSVOutput:(MatchData *)match forTeam:(TeamScore *)teamScore;
-(NSString *)applicationDocumentsDirectory;
-(void)buildEmail:(NSArray *)filePath attach:(NSArray *)emailFile subject:(NSString *)emailSubject;
-(void)retrieveSettings;

@end
