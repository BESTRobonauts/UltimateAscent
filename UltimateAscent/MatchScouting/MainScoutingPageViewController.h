//
//  MainScoutingPageViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlliancePickerController.h"
#import "MatchTypePickerController.h"
#import "TeamPickerController.h"
#import "RecordScorePickerController.h"
#import "DefensePickerController.h"
#import "AlertPromptViewController.h"
#import "ValuePromptViewController.h"
#import "PopUpPickerViewController.h"

@protocol MainScoutingPageDelegate
- (void)scoutingPageStatus:(NSUInteger)sectionIndex forRow:(NSUInteger)rowIndex forTeam:(NSUInteger)teamIndex;
@end

@class MatchData;
@class TeamScore;
@class SettingsData;
@class DataManager;

@interface MainScoutingPageViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, AlliancePickerDelegate, MatchTypePickerDelegate, TeamPickerDelegate, RecordScorePickerDelegate, DefensePickerDelegate, PopUpPickerDelegate, AlertPromptDelegate, ValuePromptDelegate> {
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, assign) MatchType currentSectionType;
@property (nonatomic, assign) NSUInteger sectionIndex;
@property (nonatomic, assign) NSUInteger rowIndex;
@property (nonatomic, assign) NSUInteger teamIndex;
@property (nonatomic, retain) MatchData *currentMatch;
@property (nonatomic, retain) TeamScore *currentTeam;
@property (nonatomic, retain) NSArray *teamData;
@property (nonatomic, assign) BOOL dataChange;
@property (nonatomic, assign) NSString *storePath;
@property (nonatomic, retain) NSFileManager *fileManager;

// Match Control
@property (nonatomic, retain) IBOutlet UIButton *prevMatch;
@property (nonatomic, retain) IBOutlet UIButton *nextMatch;
-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection;
-(int)getNumberOfMatches:(NSUInteger)section;
-(MatchData *)getCurrentMatch;

// User Access Control
typedef enum {
    NoOverride,
	OverrideDrawLock,
    OverrideMatchReset,
    OverrideAllianceSelection,
    OverrideTeamSelection,
} OverrideMode;

@property (nonatomic, retain) AlertPromptViewController *alertPrompt;
@property (nonatomic, retain) UIPopoverController *alertPromptPopover;
@property (nonatomic, assign) OverrideMode overrideMode;

-(IBAction)PrevButton;
-(IBAction)NextButton;
-(NSUInteger)GetNextSection:(MatchType) currentSection;
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection;
- (void)retrieveSettings;

// Match Scores
@property (nonatomic, retain) IBOutlet UILabel *teamName;
@property (nonatomic, retain) IBOutlet UISlider *driverRating;
@property (nonatomic, retain) IBOutlet UISlider *defenseRating;
@property (nonatomic, retain) IBOutlet UISlider *robotSpeed;
@property (nonatomic, retain) IBOutlet UISwitch *attemptedClimb;
@property (nonatomic, retain) UISegmentedControl *climbLevel;
@property (nonatomic, retain) IBOutlet UITextField *notes;
@property (nonatomic, retain) IBOutlet UIButton *matchResetButton;
@property (nonatomic, retain) IBOutlet UIButton *climbTimerButton;
-(IBAction)matchResetRequest:(id) sender;
-(void)matchReset;
-(IBAction)updateDriverRating:(id) sender;
-(IBAction)updateDefenseRating: (id) sender;
-(IBAction)updateRobotSpeed: (id) sender;
-(IBAction)toggleForClimbAttempt: (id) sender;
-(void)setClimbSegment: (id) sender;
-(IBAction)climbTimerStart:(id)sender;
-(IBAction)climbTimerStop:(id) sender;
- (void)timerFired;

-(IBAction)scoreButtons: (id)sender;
@property (nonatomic, retain) IBOutlet UIButton *teleOpMissButton;
@property (nonatomic, retain) IBOutlet UIButton *teleOpHighButton;
@property (nonatomic, retain) IBOutlet UIButton *teleOpMediumButton;
@property (nonatomic, retain) IBOutlet UIButton *teleOpLowButton;
@property (nonatomic, retain) IBOutlet UIButton *autonMissButton;
@property (nonatomic, retain) IBOutlet UIButton *autonHighButton;
@property (nonatomic, retain) IBOutlet UIButton *autonMediumButton;
@property (nonatomic, retain) IBOutlet UIButton *autonLowButton;
@property (nonatomic, retain) IBOutlet UIButton *pyramidGoalsButton;
@property (nonatomic, retain) IBOutlet UIButton *passesButton;
@property (nonatomic, retain) IBOutlet UIButton *blocksButton;
@property (nonatomic, retain) IBOutlet UIButton *wallPickUpsButton;
@property (nonatomic, retain) IBOutlet UIButton *floorPickUpsButton;
@property (nonatomic, retain) IBOutlet UIButton *wall1Button;
@property (nonatomic, retain) IBOutlet UIButton *wall2Button;
@property (nonatomic, retain) IBOutlet UIButton *wall3Button;
@property (nonatomic, retain) IBOutlet UIButton *wall4Button;
@property (nonatomic, retain) PopUpPickerViewController *scoreButtonReset;
@property (nonatomic, retain) NSMutableArray *scoreButtonChoices;
@property (nonatomic, retain) UIPopoverController *scoreButtonPickerPopover;
@property (nonatomic, retain) ValuePromptViewController *valuePrompt;
@property (nonatomic, retain) UIPopoverController *valuePromptPopover;

-(void)teleOpMiss:(NSString *)choice;
-(void)teleOpHigh:(NSString *)choice;
-(void)teleOpMedium:(NSString *)choice;
-(void)teleOpLow:(NSString *)choice;
-(void)autonMiss:(NSString *)choice;
-(void)autonHigh:(NSString *)choice;
-(void)autonMedium:(NSString *)choice;
-(void)autonLow:(NSString *)choice;
-(void)pyramidGoals;
-(void)blockedShots;
-(void)passesMade;
-(IBAction)wallPickUpsMade:(id) sender;
-(void)floorPickUpsMade;
-(void)promptForValue:(UIButton *)button;

// Overall Match Scores
@property (nonatomic, retain) IBOutlet UITextField *redScore;
@property (nonatomic, retain) IBOutlet UITextField *blueScore;

// Match Number
@property (nonatomic, retain) IBOutlet UITextField *matchNumber;
-(IBAction)MatchNumberChanged;

// Match Type
@property (nonatomic, retain) IBOutlet UIButton *matchType;
@property (nonatomic, retain) NSMutableArray *matchTypeList;
@property (nonatomic, retain) MatchTypePickerController *matchTypePicker;
@property (nonatomic, retain) UIPopoverController *matchTypePickerPopover;
-(IBAction)MatchTypeSelectionChanged:(id)sender;
-(NSMutableArray *)getMatchTypeList;

// Alliance Picker
@property (nonatomic, retain) IBOutlet UIButton *alliance;
@property (nonatomic, retain) NSMutableArray *allianceList;
@property (nonatomic, retain) AlliancePickerController *alliancePicker;
@property (nonatomic, retain) UIPopoverController *alliancePickerPopover;
-(IBAction)AllianceSelectionChanged:(id)sender;
-(void)AllianceSelectionPopUp;

// Team Picker
-(IBAction)TeamSelectionChanged:(id)sender;
-(void)TeamSelectionPopUp;
@property (nonatomic, retain) IBOutlet UIButton *teamNumber;
@property (nonatomic, retain) NSMutableArray *teamList;
@property (nonatomic, retain) TeamPickerController *teamPicker;
@property (nonatomic, retain) UIPopoverController *teamPickerPopover;

// Other Stuff
@property (nonatomic, retain) IBOutlet UIButton *matchListButton;
@property (nonatomic, retain) IBOutlet UIButton *teamEdit;
@property (nonatomic, retain) IBOutlet UIButton *syncButton;
@property (nonatomic, assign) id<MainScoutingPageDelegate> delegate;
- (NSString *)applicationDocumentsDirectory;

// Make It Look Good
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
-(void)SetSmallButtonDefaults:(UIButton *)currentButton;
// Data Handling
-(void)ShowTeam:(NSUInteger)currentTeamIndex;
-(TeamScore *)GetTeam:(NSUInteger)currentTeamIndex;
-(void)setTeamList;
-(void)CheckDataStatus;

// Match Drawing
typedef enum {
	DrawOff,
	DrawAuton,
	DrawTeleop,
    DrawDefense,
    DrawLock,
} DrawingMode;

@property (nonatomic, retain) NSString *baseDrawingPath;
@property (nonatomic, retain) NSString *fieldDrawingPath;
@property (nonatomic, retain) NSString *fieldDrawingFile;
@property (nonatomic, retain) IBOutlet UIImageView *fieldImage;
@property (nonatomic, retain) IBOutlet UIView *imageContainer;
@property (nonatomic, assign) BOOL fieldDrawingChange;
@property (nonatomic, retain) NSMutableArray *scoreList;
@property (nonatomic, retain) RecordScorePickerController *scorePicker;
@property (nonatomic, retain) UIPopoverController *scorePickerPopover;
@property (nonatomic, retain) NSMutableArray *defenseList;
@property (nonatomic, retain) DefensePickerController *defensePicker;
@property (nonatomic, retain) UIPopoverController *defensePickerPopover;
@property (nonatomic, assign) int popCounter;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) DrawingMode drawMode;
@property (nonatomic, retain) IBOutlet UIButton *drawModeButton;
@property (weak, nonatomic) IBOutlet UIButton *eraserButton;

-(void)floorDiskPickUp:(UITapGestureRecognizer *)gestureRecognizer;
-(void)scoreDisk:(UITapGestureRecognizer *)gestureRecognizer;
-(void)drawPath:(UIPanGestureRecognizer *)gestureRecognizer;
-(void)drawText:(NSString *) marker location:(CGPoint) point;
-(CGPoint)scorePopOverLocation:(CGPoint)location;
-(CGPoint)defensePopOverLocation:(CGPoint)location;
-(IBAction)drawModeChange: (id)sender;
-(IBAction)eraserPressed:(id)sender;

-(void)drawModeSettings:(DrawingMode) mode;
-(void)checkOverrideCode:(UIButton *)button;
-(void)checkAdminCode:(UIButton *)button;
@end
