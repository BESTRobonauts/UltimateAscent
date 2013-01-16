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

@interface DownloadPageViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIButton *exportTeamData;
@property (nonatomic, retain) IBOutlet UIButton *exportMatchData;
@property (nonatomic, retain) IBOutlet UIImageView *mainLogo;
@property (nonatomic, retain) NSString *exportPath;

-(IBAction)exportTapped:(id)sender;
-(void)emailTeamData;
-(void)emailMatchData;
-(NSString *)buildMatchCSVOutput:(TeamScore *)teamScore;
-(NSString *)applicationDocumentsDirectory;
-(void)buildEmail:(NSString *)filePath attach:(NSString *)emailFile subject:(NSString *)emailSubject;
@end
