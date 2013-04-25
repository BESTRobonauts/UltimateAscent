//
//  FieldDrawingViewController.h
//  UltimateAscent
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MatchData;
@class TeamScore;
@class SettingsData;

@interface FieldDrawingViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSArray *teamScores;
@property (nonatomic, assign) int *startingIndex;
@property (nonatomic, retain) NSString *drawDirectory;
@property (nonatomic, retain) IBOutlet UIButton *prevMatchButton;
@property (nonatomic, retain) IBOutlet UIButton *nextMatchButton;
- (IBAction)nextMatch:(id)sender;
- (IBAction)prevMatch:(id)sender;
@property (nonatomic, retain) NSString *baseDrawingPath;
@property (nonatomic, retain) NSString *fieldDrawingPath;
@property (nonatomic, retain) NSString *fieldDrawingFile;
@property (nonatomic, retain) IBOutlet UITextField *matchNumber;
@property (nonatomic, retain) IBOutlet UIButton *matchType;
@property (nonatomic, retain) IBOutlet UITextField *teamName;
@property (nonatomic, retain) IBOutlet UITextField *teamNumber;
@property (nonatomic, retain) IBOutlet UITextField *autonScoreMade;
@property (nonatomic, retain) IBOutlet UITextField *autonScoreShot;
@property (nonatomic, retain) IBOutlet UITextField *autonHigh;
@property (nonatomic, retain) IBOutlet UITextField *autonMed;
@property (nonatomic, retain) IBOutlet UITextField *autonLow;
@property (nonatomic, retain) IBOutlet UITextField *autonMissed;

@property (nonatomic, retain) IBOutlet UITextField *teleOpScoreMade;
@property (nonatomic, retain) IBOutlet UITextField *teleOpScoreShot;
@property (nonatomic, retain) IBOutlet UITextField *teleOpHigh;
@property (nonatomic, retain) IBOutlet UITextField *teleOpMed;
@property (nonatomic, retain) IBOutlet UITextField *teleOpLow;
@property (nonatomic, retain) IBOutlet UITextField *teleOpMissed;
@property (nonatomic, retain) IBOutlet UITextField *discPassed;
@property (nonatomic, retain) IBOutlet UITextField *autonPyramidGoals;
@property (nonatomic, retain) IBOutlet UITextField *pyramidGoals;
@property (nonatomic, retain) IBOutlet UITextField *wallPickUp;
@property (nonatomic, retain) IBOutlet UITextField *wall1;
@property (nonatomic, retain) IBOutlet UITextField *wall2;
@property (nonatomic, retain) IBOutlet UITextField *wall3;
@property (nonatomic, retain) IBOutlet UITextField *wall4;
@property (nonatomic, retain) IBOutlet UITextField *floorPickUp;
@property (nonatomic, retain) IBOutlet UITextField *blocked;
@property (nonatomic, retain) IBOutlet UITextField *climbAttempt;
@property (nonatomic, retain) IBOutlet UITextField *climbLevel;
@property (nonatomic, retain) IBOutlet UITextField *climbTime;
@property (nonatomic, retain) IBOutlet UITextView  *notes;
@property (nonatomic, retain) IBOutlet UIImageView *fieldImage;

-(void)setDisplayData;
-(void)loadFieldDrawing;
-(void)gotoNextMatch:(UISwipeGestureRecognizer *)gestureRecognizer;
-(void)gotoPrevMatch:(UISwipeGestureRecognizer *)gestureRecognizer;

// Make It Look Good
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetSmallTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
-(void)SetSmallButtonDefaults:(UIButton *)currentButton;

@end
