//
//  TeamDetailViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamDetailPickerController.h"

@class TeamData;
@class MatchData;
@class TeamScore;

@interface TeamDetailViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, TeamDetailPickerDelegate>

@property (nonatomic, retain) TeamData *team;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextView *notesViewField;
@property (nonatomic, retain) IBOutlet UITextField *notesTextField;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *intakeType;
@property (nonatomic, retain) IBOutlet UIButton *climbZone;
@property (nonatomic, retain) IBOutlet UITextField *shootingLevel;
@property (nonatomic, retain) IBOutlet UITextField *auton;
@property (nonatomic, retain) IBOutlet UITextField *minHeight;
@property (nonatomic, retain) IBOutlet UITextField *maxHeight;
@property (nonatomic, retain) IBOutlet UITextField *wheelType;
@property (nonatomic, retain) IBOutlet UITextField *nwheels;
@property (nonatomic, retain) IBOutlet UITextField *wheelDiameter;
@property (nonatomic, retain) IBOutlet UIButton *driveType;
@property (nonatomic, retain) IBOutlet UITextField *cims;
@property (nonatomic, retain) IBOutlet UIButton *choosePhotoBtn;
@property (nonatomic, retain) IBOutlet UIButton *takePhotoBtn;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSString *photoPath;
@property (nonatomic, assign) BOOL dataChange;

typedef enum {
	SelectIntake,
	SelectClimbZone,
	SelectDriveType,
} DetailSelection;

@property (nonatomic, retain) NSMutableArray *intakeList;
@property (nonatomic, retain) NSMutableArray *climbZoneList;
@property (nonatomic, retain) NSMutableArray *driveTypeList;
@property (nonatomic, assign) DetailSelection detailSelection;
@property (nonatomic, retain) TeamDetailPickerController *intakePicker;
@property (nonatomic, retain) TeamDetailPickerController *driveTypePicker;
@property (nonatomic, retain) TeamDetailPickerController *climbZonePicker;
@property (nonatomic, retain) UIPopoverController *detailPickerPopover;
@property (nonatomic, strong) NSArray *regionalList;
-(IBAction)detailChanged:(id)sender;
-(void)detailSelectionPopUp:(UIButton *)button forChoices:(NSMutableArray *)detailChoices;
-(void)changeIntake:(NSString *)newIntake;
-(void)changeDriveType:(NSString *)newDriveType;
-(void)changeClimbZone:(NSString *)newClimbZone;

@property (nonatomic, retain) IBOutlet UITableView *matchInfo;
@property (nonatomic, retain) UIView *matchHeader;

-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)SetBigButtonDefaults:(UIButton *)currentButton;
//-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)getSelection:(id) sender;
-(MatchData *)getMatchData: (TeamScore *) teamScore;

-(IBAction)useCamera: (id)sender;
-(IBAction)useCameraRoll: (id)sender;
-(void)savePhoto: (UIImage *)image;
-(void)getPhoto;


@end
