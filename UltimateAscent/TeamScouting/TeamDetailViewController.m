//
//  TeamDetailViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "DataManager.h"

@implementation TeamDetailViewController
@synthesize team;
@synthesize numberLabel, nameTextField, notesTextField;
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
@synthesize matchInfo, matchHeader;

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
    NSLog(@"Team Detail viewDidLoad");
    
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
 
    _intakeList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"Floor", @"Human", @"Both", nil];
    _driveTypeList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"Mech", @"Omni", @"Swerve", @"Traction", @"Multi", nil];
    _climbZoneList = [[NSMutableArray alloc] initWithObjects:@"Unknown", @"One", @"Two", @"Three", nil];

    matchHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    matchHeader.backgroundColor = [UIColor lightGrayColor];
    matchHeader.opaque = YES;
    
	UILabel *matchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	matchLabel.text = @"Match";
    matchLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:matchLabel];
    
	UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 200, 50)];
	typeLabel.text = @"Type";
    typeLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:typeLabel];
    
 	UILabel *hybridLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 0, 200, 50)];
	hybridLabel.text = @"HP";
    hybridLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:hybridLabel];
    
	UILabel *teleOpLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 200, 50)];
	teleOpLabel.text = @"TP";
    teleOpLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:teleOpLabel];
    
	UILabel *autonAccLabel = [[UILabel alloc] initWithFrame:CGRectMake(331, 0, 200, 50)];
	autonAccLabel.text = @"Auton Accuracy";
    autonAccLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:autonAccLabel];

	UILabel *teleOpAccLabel = [[UILabel alloc] initWithFrame:CGRectMake(485, 0, 200, 50)];
	teleOpAccLabel.text = @"TeleOp Accuracy";
    teleOpAccLabel.backgroundColor = [UIColor clearColor];
    [matchHeader addSubview:teleOpAccLabel];
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"team = %@", team);
    self.title = [NSString stringWithFormat:@"%d - %@", [team.number intValue], team.name];
    numberLabel.text = [NSString stringWithFormat:@"%d", [team.number intValue]];
    nameTextField.text = team.name;
    notesTextField.text = team.notes;
//    shootingLevel.text = team.goalHeight;
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
    
    NSString *path = [NSString stringWithFormat:@"Library/RobotPhotos/%@", [NSString stringWithFormat:@"%d", [team.number intValue]]];
    photoPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    [self getPhoto];
    dataChange = NO;
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
		team.notes = notesTextField.text;
	}
	else if (textField == auton) {
		team.auton = [NSNumber numberWithInt:[auton.text floatValue]];
	}
	else if (textField == shootingLevel) {
//		team.goalHeight = shootingLevel.text;
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

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return matchHeader;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int x = [team.match count];
//    NSLog(@"Matchscore count = %d", x);
    return x; 
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray* objectsArray = [team.match allObjects];
    TeamScore *score = [objectsArray objectAtIndex:indexPath.row];
    NSLog(@"Match Notes = %@", score.notes);
       // Configure the cell...
       // Set a background for the cell
     // UIImageView *tableBackground = [[UIImageView alloc] initWithFrame:cell.frame];
     // UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
     // tableBackground.image = image;
    //  cell.backgroundView = imageView; Change Varable Name "soon" 
    
	UILabel *matchNumber = (UILabel *)[cell viewWithTag:10];
	matchNumber.text = [NSString stringWithFormat:@"%d", [score.match.number intValue]];
    
	UILabel *typeLabel = (UILabel *)[cell viewWithTag:20];
    typeLabel.text = [score.match.matchType substringToIndex:4];

    int autonPoints = [score.autonHigh intValue]*6 + [score.autonMid intValue]*5 + [score.autonLow intValue]*4;
	UILabel *autonLabel = (UILabel *)[cell viewWithTag:30];
	autonLabel.text = [NSString stringWithFormat:@"%d", autonPoints];

    int teleOpPoints = [score.teleOpHigh intValue]*3 + [score.teleOpMid intValue]*2 + [score.teleOpLow intValue];
	UILabel *teleOpLabel = (UILabel *)[cell viewWithTag:40];
    teleOpLabel.text = [NSString stringWithFormat:@"%d", teleOpPoints];


    int basketsMade = [score.autonHigh intValue] + [score.autonMid intValue] + [score.autonLow intValue];
    int totalBaskets = basketsMade + [score.autonMissed intValue];
    int autonAccuracy;
    if (totalBaskets) autonAccuracy = 100 * basketsMade / (basketsMade + [score.autonMissed intValue]);
    else autonAccuracy = 0;
    UILabel *autonAccLabel = (UILabel *)[cell viewWithTag:50];
	autonAccLabel.text = [NSString stringWithFormat:@"%d%%", autonAccuracy];

    basketsMade = [score.teleOpHigh intValue] + [score.teleOpMid intValue] + [score.teleOpLow intValue];
    totalBaskets = basketsMade + [score.teleOpMissed intValue];
    int teleOpAccuracy;
    if (totalBaskets) teleOpAccuracy = 100 * basketsMade / (basketsMade + [score.teleOpMissed intValue]);
    else teleOpAccuracy = 0;
    
	UILabel *teleOpAccLabel = (UILabel *)[cell viewWithTag:60];
	teleOpAccLabel.text = [NSString stringWithFormat:@"%d%%", teleOpAccuracy]; 

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"MatchSchedule"];
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated { // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
    NSLog(@"view will disappear");
    if (dataChange) {
        team.saved = [NSNumber numberWithInt:1];
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
