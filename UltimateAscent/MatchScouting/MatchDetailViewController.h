//
//  MatchDetailViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchTypePickerController.h"
#import "AlertPromptViewController.h"

@class MatchData;
@class TeamScore;
@class TeamData;
@class SettingsData;

@protocol MatchDetailDelegate
- (void)matchDetailReturned:(BOOL)dataChange;
@end

@interface MatchDetailViewController : UIViewController <UITextFieldDelegate, AlertPromptDelegate, MatchTypePickerDelegate>
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) MatchData *match;

@property (nonatomic, assign) BOOL textChangeDetected;
@property (nonatomic, retain) IBOutlet UITextField *numberTextField;
@property (nonatomic, retain) IBOutlet UITextField *red1TextField;
@property (nonatomic, retain) IBOutlet UITextField *red2TextField;
@property (nonatomic, retain) IBOutlet UITextField *red3TextField;
@property (nonatomic, retain) IBOutlet UITextField *blue1TextField;
@property (nonatomic, retain) IBOutlet UITextField *blue2TextField;
@property (nonatomic, retain) IBOutlet UITextField *blue3TextField;
@property (nonatomic, assign) id<MatchDetailDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *matchTypeButton;
@property (nonatomic, retain) MatchTypePickerController *matchTypePicker;
@property (nonatomic, retain) UIPopoverController *matchTypePickerPopover;

// User Access Control
typedef enum {
    NoOverride,
    OverrideMatchTypeSelection,
    OverrideMatchNumberSelection,
} OverrideMode;

@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, retain) AlertPromptViewController *alertPrompt;
@property (nonatomic, retain) UIPopoverController *alertPromptPopover;
@property (nonatomic, assign) OverrideMode overrideMode;
- (void)retrieveSettings;

-(IBAction)MatchTypeSelectionChanged:(id)sender;
-(void)MatchTypeSelectionPopUp;
-(void)matchNumberChanged:(NSNumber *)number forMatchType:(NSString *)matchType;

-(void)checkOverrideCode;

-(BOOL)editTeam:(int)teamNumber forScore:(TeamScore *)score;
-(BOOL)editMatch:(NSNumber *)number forMatchType:(NSString *)matchType;
-(TeamData *)GetTeam:(int)teamNumber forTournament:(NSString *)tournament;
-(void)setTeamField:(UITextField *)textBox forTeam:(TeamScore *)score;
-(void)setScoreData:(TeamScore *)score;

@end
