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

@protocol MainScoutingPageDelegate
- (void)scoutingPageStatus:(NSUInteger)sectionIndex forRow:(NSUInteger)rowIndex forTeam:(NSUInteger)teamIndex;
@end

@class MatchData;
@class TeamScore;
@class SettingsData;

@interface MainScoutingPageViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, AlliancePickerDelegate, MatchTypePickerDelegate, TeamPickerDelegate, RecordScorePickerDelegate> {
    
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
@property (nonatomic, retain) SettingsData *settings;
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
-(IBAction)PrevButton;
-(IBAction)NextButton;
-(NSUInteger)GetNextSection:(NSUInteger) currentSection;
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection;
- (void)retrieveSettings;

// Match Scores
@property (nonatomic, retain) IBOutlet UILabel *teamName;
@property (nonatomic, retain) IBOutlet UISlider *driverRating;
@property (nonatomic, retain) IBOutlet UISwitch *crossesHump;
@property (nonatomic, retain) IBOutlet UISwitch *coopBalance;
@property (nonatomic, retain) IBOutlet UISwitch *modedRamp;
@property (nonatomic, retain) UISegmentedControl *balanced;
@property (nonatomic, retain) IBOutlet UITextField *notes;
-(IBAction)updateDriverRating:(id) sender;
-(IBAction)toggleForCrossesHump: (id) sender;
-(IBAction)toggleForCoopBalance: (id) sender;
-(void)setBalanceSegment: (id) sender;
-(IBAction)toggleForRampModing: (id) sender;


-(IBAction)scoreButtons: (id)sender;
@property (nonatomic, retain) IBOutlet UIButton *teleOpMissButton;
@property (nonatomic, retain) IBOutlet UIButton *teleOpHighButton;
@property (nonatomic, retain) IBOutlet UIButton *teleOpMediumButton;
@property (nonatomic, retain) IBOutlet UIButton *teleOpLowButton;
@property (nonatomic, retain) IBOutlet UIButton *autonMissButton;
@property (nonatomic, retain) IBOutlet UIButton *autonHighButton;
@property (nonatomic, retain) IBOutlet UIButton *autonMediumButton;
@property (nonatomic, retain) IBOutlet UIButton *autonLowButton;
-(void)teleOpMiss;
-(void)teleOpHigh;
-(void)teleOpMedium;
-(void)teleOpLow;
-(void)autonMiss;
-(void)autonHigh;
-(void)autonMedium;
-(void)autonLow;

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

// Alliance Picker
@property (nonatomic, retain) IBOutlet UIButton *alliance;
@property (nonatomic, retain) NSMutableArray *allianceList;
@property (nonatomic, retain) AlliancePickerController *alliancePicker;
@property (nonatomic, retain) UIPopoverController *alliancePickerPopover;
-(IBAction)AllianceSelectionChanged:(id)sender;

// Team Picker
-(IBAction)TeamSelectionChanged:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *teamNumber;
@property (nonatomic, retain) NSMutableArray *teamList;
@property (nonatomic, retain) TeamPickerController *teamPicker;
@property (nonatomic, retain) UIPopoverController *teamPickerPopover;

// Other Stuff
//@property (nonatomic, retain) IBOutlet UIButton *matchEdit;
@property (nonatomic, retain) IBOutlet UIButton *teamEdit;
@property (nonatomic, assign) id<MainScoutingPageDelegate> delegate;
- (NSString *)applicationDocumentsDirectory;

// Make It Look Good
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetButtonDefaults:(UIButton *)currentButton;
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
@property (nonatomic, assign) DrawingMode drawMode;
@property (nonatomic, retain) IBOutlet UIButton *drawModeButton;
- (CGPoint)calculatePopOverLocation:(CGPoint)location;
-(IBAction)drawModeChange: (id)sender;
-(void) drawModeSettings:(DrawingMode) mode;

@end
