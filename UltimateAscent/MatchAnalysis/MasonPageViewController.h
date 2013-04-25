//
//  MasonPageViewController.h
//  UltimateAscent
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchTypePickerController.h"

@class MatchData;
@class SettingsData;
@class TeamScore;
@class TeamData;
@class Statistics;
@class DataManager;

@interface MasonPageViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MatchTypePickerDelegate>

@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) SettingsData *settings;
@property (nonatomic, assign) MatchType currentSectionType;
@property (nonatomic, assign) NSUInteger sectionIndex;
@property (nonatomic, assign) NSUInteger rowIndex;
@property (nonatomic, assign) NSUInteger teamIndex;
@property (nonatomic, retain) MatchData *currentMatch;

// Match Control
@property (nonatomic, retain) IBOutlet UIButton *prevMatch;
@property (nonatomic, retain) IBOutlet UIButton *nextMatch;
@property (nonatomic, retain) IBOutlet UIButton *ourPrevMatch;
@property (nonatomic, retain) IBOutlet UIButton *ourNextMatch;
-(IBAction)PrevButton;
-(IBAction)OurNextButton;
-(IBAction)OurPrevButton;
-(IBAction)NextButton;
-(NSUInteger)GetNextSection:(MatchType) currentSection;
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection;
-(int)getNumberOfMatches:(NSUInteger)section;
-(MatchData *)getCurrentMatch;
-(NSMutableArray *)getMatchTypeList;
-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection;

// Match Number
@property (nonatomic, retain) IBOutlet UITextField *matchNumber;
-(IBAction)MatchNumberChanged;

// Match Type
@property (nonatomic, retain) IBOutlet UIButton *matchType;
@property (nonatomic, retain) NSMutableArray *matchTypeList;
@property (nonatomic, retain) MatchTypePickerController *matchTypePicker;
@property (nonatomic, retain) UIPopoverController *matchTypePickerPopover;
-(IBAction)MatchTypeSelectionChanged:(id)sender;

// Team Statistics Table
@property (nonatomic, retain) NSMutableArray *teamData;
@property (nonatomic, retain) NSMutableArray *teamList;
@property (nonatomic, retain) NSMutableArray *teamMatches;
@property (nonatomic, retain) NSMutableArray *teamAuton;
@property (nonatomic, retain) NSMutableArray *teamTeleOp;
@property (nonatomic, retain) NSMutableArray *teamHang;
@property (nonatomic, retain) NSMutableArray *teamHangLevel;
@property (nonatomic, retain) NSMutableArray *teamDriving;
@property (nonatomic, retain) NSMutableArray *teamDefense;
@property (nonatomic, retain) NSMutableArray *teamSpeed;
@property (nonatomic, retain) NSMutableArray *teamHeight;

@property (nonatomic, retain) IBOutlet UITableView *teamInfo;
@property (nonatomic, retain) UIView *teamHeader;

// Team Match List Table
@property (nonatomic, retain) NSArray *red1Matches;
@property (nonatomic, retain) NSArray *red1;
@property (nonatomic, retain) NSArray *red2;
@property (nonatomic, retain) NSArray *red3;
@property (nonatomic, retain) Statistics *red1Stats;

// Team tables
@property (nonatomic, retain) IBOutlet UILabel *red1Team;
@property (weak, nonatomic) IBOutlet UILabel *red2Team;
@property (weak, nonatomic) IBOutlet UILabel *red3Team;
@property (weak, nonatomic) IBOutlet UILabel *blue1Team;
@property (weak, nonatomic) IBOutlet UILabel *blue2Team;
@property (weak, nonatomic) IBOutlet UILabel *blue3Team;

@property (nonatomic, retain) IBOutlet UITableView *red1Table;
@property (nonatomic, retain) IBOutlet UITableView *red2Table;
@property (weak, nonatomic) IBOutlet UITableView *red3Table;
@property (weak, nonatomic) IBOutlet UITableView *blue1Table;
@property (weak, nonatomic) IBOutlet UITableView *blue2Table;
@property (weak, nonatomic) IBOutlet UITableView *blue3Table;

// Team Scores for Segue
@property (nonatomic, retain) NSMutableArray *red1Scores;
@property (nonatomic, retain) NSMutableArray *red2Scores;
@property (nonatomic, retain) NSMutableArray *red3Scores;
@property (nonatomic, retain) NSMutableArray *blue1Scores;
@property (nonatomic, retain) NSMutableArray *blue2Scores;
@property (nonatomic, retain) NSMutableArray *blue3Scores;


// Data Handling
-(void)ShowMatch;
-(void)setTeamList;
-(NSMutableArray *)getScoreList:(TeamData *)team;

// Make It Look Good
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
-(void)SetSmallButtonDefaults:(UIButton *)currentButton;

- (NSString *)applicationDocumentsDirectory;
- (void)retrieveSettings;

@end
