//
//  TeamDetailViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamData;
@class MatchData;
@class TeamScore;

@interface TeamDetailViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) TeamData *team;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UILabel *historyLabel;
@property (nonatomic, retain) IBOutlet UITextField *notesTextField;
@property (nonatomic, retain) IBOutlet UITextField *driveTrainTextField;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UISegmentedControl *stationIntake;
@property (nonatomic, retain) UISegmentedControl *floorIntake;
@property (nonatomic, retain) UISegmentedControl *invertDisks;
@property (nonatomic, retain) UISegmentedControl *orientation;
@property (nonatomic, retain) IBOutlet UIButton *choosePhotoBtn;
@property (nonatomic, retain) IBOutlet UIButton *takePhotoBtn;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSString *photoPath;
@property (nonatomic, assign) BOOL dataChange;
@property (nonatomic, retain) IBOutlet UITableView *matchInfo;
@property (nonatomic, retain) UIView *matchHeader;

-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)createSegments;
-(void)setSegments;
//-(void)SetTextBoxDefaults:(UITextField *)textField;
-(void)getSelection:(id) sender;
-(MatchData *)getMatchData: (TeamScore *) teamScore;

-(IBAction)useCamera: (id)sender;
-(IBAction)useCameraRoll: (id)sender;
-(void)savePhoto: (UIImage *)image;
-(void)getPhoto;


@end
