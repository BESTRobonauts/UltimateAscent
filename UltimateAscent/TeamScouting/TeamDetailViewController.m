//
//  TeamDetailViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "CreateMatch.h"
#import "MatchData.h"
#import "DataManager.h"
#import "Regional.h"
#import "FieldDrawingViewController.h"

@implementation TeamDetailViewController {
    SettingsData *settings;
    NSArray *matchList;
}
@synthesize dataManager = _dataManager;
@synthesize team;
@synthesize numberLabel, nameTextField, notesTextField;
@synthesize notesViewField = _notesViewField;
@synthesize intakeType, climbZone, shootingLevel; 
@synthesize auton, maxHeight, minHeight;
@synthesize wheelType, nwheels, wheelDiameter;
@synthesize driveType, cims;
@synthesize intakeList = _intakeList;
@synthesize driveTypePicker = _driveTypePicker;
@synthesize intakePicker = _intakePicker;
@synthesize climbZonePicker = _climbZonePicker;
@synthesize detailPickerPopover = _detailPickerPopover;
@synthesize detailSelection = _detailSelection;
@synthesize imageView, choosePhotoBtn, takePhotoBtn;
@synthesize popoverController;
@synthesize photoPath;
@synthesize dataChange;
@synthesize matchInfo = _matchInfo;
@synthesize matchHeader = _matchHeader;
@synthesize regionalInfo = _regionalInfo;
@synthesize regionalHeader = _regionalHeader;
@synthesize regionalList = _regionalList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
} 

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self retrieveSettings];
    numberLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
    [self SetTextBoxDefaults:nameTextField];
    [self SetTextBoxDefaults:notesTextField];
    [self SetTextBoxDefaults:shootingLevel];
    [self SetTextBoxDefaults:auton];
    [self SetTextBoxDefaults:minHeight];
    [self SetTextBoxDefaults:maxHeight];
    [self SetTextBoxDefaults:wheelType];
    [self SetTextBoxDefaults:nwheels];
    [self SetTextBoxDefaults:wheelDiameter];
    [self SetTextBoxDefaults:cims];
//    [takePhotoBtn setTitle:@"Take Photo" forState:UIControlStateNormal];
//    takePhotoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];

    [self createRegionalHeader];
    [self createMatchHeader];
    
    _intakeList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"Floor", @"Human", @"Both", nil];
    _driveTypeList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"Mech", @"Omni", @"Swerve", @"Traction", @"Multi", @"Tank", @"West Coast", nil];
    _climbZoneList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"One", @"Two", @"Three", nil];

    NSSortDescriptor *regionalSort = [NSSortDescriptor sortDescriptorWithKey:@"reg1" ascending:YES];
    _regionalList = [[team.regional allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:regionalSort]];
    
    matchList = [[[CreateMatch alloc] initWithDataManager:_dataManager] getMatchListTournament:team.number forTournament:settings.tournament.name];
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.title = [NSString stringWithFormat:@"%d - %@", [team.number intValue], team.name];
    numberLabel.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    nameTextField.text = team.name;
    notesTextField.text = team.notes;
    _notesViewField.text = team.notes;
    shootingLevel.text = team.shootsTo;
    auton.text = [NSString stringWithFormat:@"%d", [team.auton intValue]];
    minHeight.text = [NSString stringWithFormat:@"%.1f", [team.minHeight floatValue]];
    maxHeight.text = [NSString stringWithFormat:@"%.1f", [team.maxHeight floatValue]];
    wheelType.text = team.wheelType;
    nwheels.text = [NSString stringWithFormat:@"%d", [team.nwheels intValue]];
    wheelDiameter.text = [NSString stringWithFormat:@"%.1f", [team.wheelDiameter floatValue]];
    cims.text = [NSString stringWithFormat:@"%.0f", [team.cims floatValue]];

    if ([team.intake intValue] == -1) {
        [intakeType setTitle:@"Unknown" forState:UIControlStateNormal];
    }
    else if ([team.intake intValue] == 0) {
        [intakeType setTitle:@"Floor" forState:UIControlStateNormal];
    }
    else if ([team.intake intValue] == 1) {
        [intakeType setTitle:@"Human" forState:UIControlStateNormal];
    }
    else if ([team.intake intValue] == 2) {
        [intakeType setTitle:@"Both" forState:UIControlStateNormal];
    }
    
    if ([team.climbLevel intValue] == -1) {
        [climbZone setTitle:@"Unknown" forState:UIControlStateNormal];
    }
    else if ([team.climbLevel intValue] == 0) {
        [climbZone setTitle:@"One" forState:UIControlStateNormal];
    }
    else if ([team.climbLevel intValue] == 1) {
        [climbZone setTitle:@"Two" forState:UIControlStateNormal];
    }
    else if ([team.climbLevel intValue] == 2) {
        [climbZone setTitle:@"Three" forState:UIControlStateNormal];
    }

    if ([team.driveTrainType intValue] == -1) {
        [driveType setTitle:@"Unknown" forState:UIControlStateNormal];
    }
    else if ([team.driveTrainType intValue] == 0) {
        [driveType setTitle:@"Mech" forState:UIControlStateNormal];
    }
    else if ([team.driveTrainType intValue] == 1) {
        [driveType setTitle:@"Omni" forState:UIControlStateNormal];
    }
    else if ([team.driveTrainType intValue] == 2) {
        [driveType setTitle:@"Swerve" forState:UIControlStateNormal];
    }
    else if ([team.driveTrainType intValue] == 3) {
        [driveType setTitle:@"Traction" forState:UIControlStateNormal];
    }
    else if ([team.driveTrainType intValue] == 4) {
        [driveType setTitle:@"Multi" forState:UIControlStateNormal];
    }
    else if ([team.driveTrainType intValue] == 5) {
        [driveType setTitle:@"Tank" forState:UIControlStateNormal];
    }
    else if ([team.driveTrainType intValue] == 6) {
        [driveType setTitle:@"West Coast" forState:UIControlStateNormal];
    }
    
    NSString *path = [NSString stringWithFormat:@"Library/RobotPhotos/%@", [NSString stringWithFormat:@"%d", [team.number intValue]]];
    photoPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    [self getPhoto];
    dataChange = NO;
}

-(void)createRegionalHeader {
    _regionalHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,35)];
    _regionalHeader.backgroundColor = [UIColor lightGrayColor];
    _regionalHeader.opaque = YES;
    
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 35)];
	label1.text = @"Week";
    label1.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label1];
    
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, 200, 35)];
	label2.text = @"Regional";
    label2.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label2];
    
 	UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(205, 0, 200, 35)];
	label3.text = @"Rank";
    label3.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label3];
    
	UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(270, 0, 200, 35)];
	label4.text = @"Record";
    label4.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label4];
    
	UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(365, 0, 200, 35)];
	label5.text = @"CCWM";
    label5.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label5];
    
	UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(460, 0, 200, 35)];
	label6.text = @"OPR";
    label6.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label6];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(555, 0, 200, 35)];
	label7.text = @"Elim Position";
    label7.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label7];
    
    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(730, 0, 200, 35)];
	label8.text = @"Awards";
    label8.backgroundColor = [UIColor clearColor];
    [_regionalHeader addSubview:label8];
}

-(void)createMatchHeader {
    _matchHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _matchHeader.backgroundColor = [UIColor lightGrayColor];
    _matchHeader.opaque = YES;
    
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 35)];
	label1.text = @"Match";
    label1.backgroundColor = [UIColor clearColor];
    [_matchHeader addSubview:label1];
    
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 200, 35)];
	label2.text = @"Type";
    label2.backgroundColor = [UIColor clearColor];
    [_matchHeader addSubview:label2];
    
 	UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(235, 0, 200, 35)];
	label3.text = @"Results";
    label3.backgroundColor = [UIColor clearColor];
    [_matchHeader addSubview:label3];
    
}

-(IBAction)detailChanged:(id)sender {
    UIButton * PressedButton = (UIButton*)sender;
    if (PressedButton == intakeType) {
        _detailSelection = SelectIntake;
        if (_intakePicker == nil) {
            _intakePicker = [[TeamDetailPickerController alloc]
                             initWithStyle:UITableViewStylePlain];
            _intakePicker.delegate = self;
        }
        _intakePicker.detailChoices = _intakeList;
        self.detailPickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:_intakePicker];
    }
    else if (PressedButton == driveType) {
        _detailSelection = SelectDriveType;
        if (_driveTypePicker == nil) {
            _driveTypePicker = [[TeamDetailPickerController alloc]
                             initWithStyle:UITableViewStylePlain];
            _driveTypePicker.delegate = self;
        }
        _driveTypePicker.detailChoices = _driveTypeList;
        self.detailPickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:_driveTypePicker];
    }
    else if (PressedButton == climbZone) {
        _detailSelection = SelectClimbZone;
        if (_climbZonePicker == nil) {
            _climbZonePicker = [[TeamDetailPickerController alloc]
                                initWithStyle:UITableViewStylePlain];
            _climbZonePicker.delegate = self;
        }
        _climbZonePicker.detailChoices = _climbZoneList;
        self.detailPickerPopover = [[UIPopoverController alloc]
                                        initWithContentViewController:_climbZonePicker];
    }
    [self.detailPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)detailSelected:(NSString *)newDetails {
    [_detailPickerPopover dismissPopoverAnimated:YES];
    switch (_detailSelection) {
        case SelectIntake:
            [self changeIntake:newDetails];
            break;
        case SelectDriveType:
            [self changeDriveType:newDetails];
            break;
        case SelectClimbZone:
            [self changeClimbZone:newDetails];
            break;
        default:
            break;
    }
}

-(void)changeIntake:(NSString *)newIntake {
   for (int i = 0 ; i < [_intakeList count] ; i++) {
        if ([newIntake isEqualToString:[_intakeList objectAtIndex:i]]) {
            [intakeType setTitle:newIntake forState:UIControlStateNormal];
            team.intake = [NSNumber numberWithInt:(i-1)];
            dataChange = YES;
            break;
        }
    }
}

-(void)changeDriveType:(NSString *)newDriveType {
    for (int i = 0 ; i < [_driveTypeList count] ; i++) {
        if ([newDriveType isEqualToString:[_driveTypeList objectAtIndex:i]]) {
            [driveType setTitle:newDriveType forState:UIControlStateNormal];
            team.driveTrainType = [NSNumber numberWithInt:(i-1)];
            dataChange = YES;
            break;
        }
    }
}

-(void)changeClimbZone:(NSString *)newClimbZone {
    for (int i = 0 ; i < [_climbZoneList count] ; i++) {
        if ([newClimbZone isEqualToString:[_climbZoneList objectAtIndex:i]]) {
            [climbZone setTitle:newClimbZone forState:UIControlStateNormal];
            team.climbLevel = [NSNumber numberWithInt:(i-1)];
            dataChange = YES;
            break;
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    dataChange = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSLog(@"team should end editing");
    if (textField == nameTextField) {
		team.name = nameTextField.text;
	}
	else if (textField == notesTextField) {
//		team.notes = notesTextField.text;
	}
	else if (textField == auton) {
		team.auton = [NSNumber numberWithInt:[auton.text floatValue]];
	}
	else if (textField == shootingLevel) {
		team.shootsTo = shootingLevel.text;
	}
	else if (textField == minHeight) {
		team.minHeight = [NSNumber numberWithFloat:[minHeight.text floatValue]];
	}
	else if (textField == maxHeight) {
		team.maxHeight = [NSNumber numberWithFloat:[maxHeight.text floatValue]];
	}
	else if (textField == wheelType) {
		team.wheelType = wheelType.text;
	}
	else if (textField == nwheels) {
		team.nwheels = [NSNumber numberWithInt:[nwheels.text floatValue]];
	}
	else if (textField == wheelDiameter) {
		team.wheelDiameter = [NSNumber numberWithFloat:[wheelDiameter.text floatValue]];
	}
	else if (textField == cims) {
		team.cims = [NSNumber numberWithInt:[cims.text intValue]];
	}

	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == nameTextField || textField == notesTextField || textField == wheelType || textField == shootingLevel)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    if (textField == cims || textField == nwheels) {
        NSInteger holder;
        NSScanner *scan = [NSScanner scannerWithString: resultingString];
        
        return [scan scanInteger: &holder] && [scan isAtEnd];
    }
    else {
        float holder;
        NSScanner *scan = [NSScanner scannerWithString: resultingString];
        
        return [scan scanFloat: &holder] && [scan isAtEnd];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    dataChange = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    team.notes = _notesViewField.text;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView; {
    return YES;
}

-(IBAction) useCamera: (id)sender
{   NSLog(@"Take photo");
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //          imagePicker.mediaTypes = [NSArray arrayWithObjects:
        //                                    (NSString *) kUTTypeImage,
        //                                    nil];
                  imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker
                                animated:YES];
         //         newMedia = YES;
    }
}

-(void)getPhoto {
    NSError *fileError = nil;
    NSArray *dirList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:photoPath error:&fileError];
    int dirCount = [dirList count];
    if (dirCount) {
        NSString  *jpgPath = [photoPath stringByAppendingPathComponent:[dirList objectAtIndex:(dirCount-1)]];
        [imageView setImage:[UIImage imageWithContentsOfFile:jpgPath]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (IBAction) useCameraRoll: (id)sender
{
    if ([self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated:YES];
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            //            imagePicker.mediaTypes = [NSArray arrayWithObjects:
            //                                      (NSString *) kUTTypeImage,
            //                                      nil];
            imagePicker.allowsEditing = NO;
            
            self.popoverController = [[UIPopoverController alloc]
                                      initWithContentViewController:imagePicker];
            
            popoverController.delegate = self;
            
            [popoverController presentPopoverFromRect:choosePhotoBtn.bounds inView:choosePhotoBtn 
                             permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            //            newMedia = NO;
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	imageView.image = img;
    [self savePhoto:img];
    [self.popoverController dismissPopoverAnimated:true];
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)savePhoto: (UIImage *)image {
    // Check if robot directory exists, if not, create it  
    if (![[NSFileManager defaultManager] fileExistsAtPath:photoPath isDirectory:NO]) {
        if (![[NSFileManager defaultManager]createDirectoryAtPath:photoPath 
                                      withIntermediateDirectories: YES 
                                                       attributes: nil 
                                                            error: NULL]) {
            NSLog(@"Dreadful error creating directory to save photos");
            return;
        }
    }
    // Create paths to output images
    NSString *number;
    if ([team.number intValue] < 100) {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [team.number intValue]]];
    } else if ( [team.number intValue] < 1000) {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [team.number intValue]]];
    } else {
        number = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [team.number intValue]]];
    }
    //    NSString  *imgName = [NSString stringWithFormat:@"%d", [team.number intValue], @"img001"];
//    NSString  *pngPath = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_img001.png", number]];
    NSString  *jpgPath;
    NSError *fileError;
    NSArray *dirList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:photoPath error:&fileError];
    int dirCount = [dirList count];
    if (dirCount) {
        if (dirCount < 10) {
            jpgPath = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_img00%d.jpg", number, dirCount+1]];
        } else if (dirCount < 100) {
            jpgPath = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_img0%d.jpg", number, dirCount+1]];
        }
        else {
            jpgPath = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_img%d.jpg", number, dirCount+1]];
        }
    }
    else {
        jpgPath = [photoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_img001.jpg", number]];
    }
    // NSLog(@"jpgPath = %@", jpgPath);
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
    
    // Write image to PNG
 //   [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [ self.matchInfo indexPathForCell:sender];
    [segue.destinationViewController setDrawDirectory:settings.tournament.directory];
    [segue.destinationViewController setTeamScores:matchList];
    [_matchInfo deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == _regionalInfo) return _regionalHeader;
    if (tableView == _matchInfo) return _matchHeader;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _regionalInfo) return [_regionalList count];
    else return [matchList count];
 
}

- (void)configureRegionalCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Regional *regional = [_regionalList objectAtIndex:indexPath.row];
       // Configure the cell...
       // Set a background for the cell
     // UIImageView *tableBackground = [[UIImageView alloc] initWithFrame:cell.frame];
     // UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
     // tableBackground.image = image;
    //  cell.backgroundView = imageView; Change Varable Name "soon" 
    
	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [regional.reg1 intValue]];

	UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = regional.name;

	UILabel *label3 = (UILabel *)[cell viewWithTag:30];
	label3.text = [NSString stringWithFormat:@"%d", [regional.rank intValue]];

	UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = regional.seedingRecord;

    // CCWM
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
	label5.text = [NSString stringWithFormat:@"%.1f", [regional.reg3 floatValue]];

	UILabel *label6 = (UILabel *)[cell viewWithTag:60];
	label6.text = [NSString stringWithFormat:@"%.1f", [regional.opr floatValue]];

	UILabel *label7 = (UILabel *)[cell viewWithTag:70];
	label7.text = regional.finishPosition;

	UILabel *label8 = (UILabel *)[cell viewWithTag:80];
	label8.text = regional.reg5;
}

- (void)configureMatchCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TeamScore *score = [matchList objectAtIndex:indexPath.row];

	UILabel *label1 = (UILabel *)[cell viewWithTag:10];
	label1.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];

    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
	label2.text = score.match.matchType;

    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    if ([score.saved intValue] || [score.synced intValue]) label3.text = @"Y";
    else label3.text = @"N";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == _regionalInfo) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Regional"];
        // Set up the cell...
        [self configureRegionalCell:cell atIndexPath:indexPath];
    }
    else if (tableView == _matchInfo) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchSchedule"];
        // Set up the cell...
        [self configureMatchCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)retrieveSettings {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!settingsRecord) {
        NSLog(@"Karma disruption error");
        settings = Nil;
    }
    else {
        if([settingsRecord count] == 0) {  // No Settings Exists
            NSLog(@"Karma disruption error");
            settings = Nil;
        }
        else {
            settings = [settingsRecord objectAtIndex:0];
        }
    }
    
}

-(MatchData *)getMatchData: (TeamScore *) teamScore {
/*  if (teamScore.red1) return teamScore.red1;
    if (teamScore.red2) return teamScore.red2;
    if (teamScore.red3) return teamScore.red3;
    if (teamScore.blue1) return teamScore.blue1;
    if (teamScore.blue2) return teamScore.blue2;
    if (teamScore.blue3) return teamScore.blue3; */
    
    return nil; 
}

- (void)viewDidUnload
{
    [self setMatchHeader:nil];
    [self setRegionalHeader:nil];
    [self setRegionalInfo:nil];
    [self setRegionalHeader:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated { // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
    if (dataChange) {
        team.saved = [NSNumber numberWithInt:1];
        team.stacked = [NSNumber numberWithInt:0];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:22.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:22.0];
}



@end
