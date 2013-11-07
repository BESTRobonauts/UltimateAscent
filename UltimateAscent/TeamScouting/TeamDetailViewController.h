//
//  TeamDetailViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class TeamData;
@class MatchData;
@class TeamScore;

@interface TeamDetailViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, PopUpPickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *teamIndex;
@property (nonatomic, strong) TeamData *team;
@property (nonatomic, weak) IBOutlet UIButton *prevTeamButton;
@property (nonatomic, weak) IBOutlet UIButton *nextTeamButton;
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextView *notesViewField;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *intakeType;
@property (nonatomic, weak) IBOutlet UIButton *climbZone;
@property (nonatomic, weak) IBOutlet UITextField *shootingLevel;
@property (nonatomic, weak) IBOutlet UITextField *auton;
@property (nonatomic, weak) IBOutlet UITextField *minHeight;
@property (nonatomic, weak) IBOutlet UITextField *maxHeight;
@property (nonatomic, weak) IBOutlet UITextField *wheelType;
@property (nonatomic, weak) IBOutlet UITextField *nwheels;
@property (nonatomic, weak) IBOutlet UITextField *wheelDiameter;
@property (nonatomic, weak) IBOutlet UIButton *driveType;
@property (nonatomic, weak) IBOutlet UITextField *cims;
@property (nonatomic, weak) IBOutlet UIButton *choosePhotoBtn;
@property (nonatomic, weak) IBOutlet UIButton *takePhotoBtn;
@property (nonatomic, strong) UIPopoverController *pictureController;

@property (nonatomic, strong) PopUpPickerViewController *driveTypePicker;
@property (nonatomic, strong) UIPopoverController *drivePickerPopover;
@property (nonatomic, strong) NSMutableArray *driveTypeList;

@property (nonatomic, strong) PopUpPickerViewController *intakePicker;
@property (nonatomic, strong) UIPopoverController *intakePickerPopover;
@property (nonatomic, strong) NSMutableArray *intakeList;

@property (nonatomic, strong) PopUpPickerViewController *climbZonePicker;
@property (nonatomic, strong) UIPopoverController *climbZonePickerPopover;
@property (nonatomic, strong) NSMutableArray *climbZoneList;

@property (nonatomic, weak) IBOutlet UITableView *matchInfo;
@property (nonatomic, weak) IBOutlet UITableView *regionalInfo;

-(IBAction)PrevButton;
-(IBAction)NextButton;
-(void)checkDataStatus;
-(void)showTeam;
-(NSInteger)getNumberOfTeams;
-(IBAction)detailChanged:(id)sender;
-(void)changeIntake:(NSString *)newIntake;
-(void)changeDriveType:(NSString *)newDriveType;
-(void)changeClimbZone:(NSString *)newClimbZone;

-(void)createRegionalHeader;
-(void)createMatchHeader;
-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
//-(void)SetTextBoxDefaults:(UITextField *)textField;
-(MatchData *)getMatchData: (TeamScore *) teamScore;

-(IBAction)useCamera: (id)sender;
-(IBAction)useCameraRoll: (id)sender;
-(void)savePhoto: (UIImage *)image;
-(void)getPhoto;

- (void)retrieveSettings;


@end
