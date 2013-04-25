//
//  FieldDrawingViewController.m
//  UltimateAscent
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "FieldDrawingViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "SettingsData.h"
#import "TournamentData.h"

@interface FieldDrawingViewController ()
@end

@implementation FieldDrawingViewController {
    TeamScore *currentScore;
    int currentIndex;
}
@synthesize startingIndex = _startingIndex;
@synthesize teamScores = _teamScores;
@synthesize prevMatchButton = _prevMatchButton;
@synthesize nextMatchButton = _nextMatchButton;
@synthesize baseDrawingPath;
@synthesize fieldDrawingPath;
@synthesize fieldDrawingFile;
@synthesize drawDirectory;
@synthesize fieldImage;
@synthesize matchNumber;
@synthesize matchType;
@synthesize teamName;
@synthesize teamNumber;
@synthesize teleOpScoreMade;
@synthesize teleOpScoreShot;
@synthesize teleOpHigh;
@synthesize teleOpMed;
@synthesize teleOpLow;
@synthesize teleOpMissed;
@synthesize autonScoreMade;
@synthesize autonScoreShot;
@synthesize autonHigh;
@synthesize autonMed;
@synthesize autonLow;
@synthesize autonMissed;
@synthesize pyramidGoals;
@synthesize discPassed;
@synthesize wallPickUp;
@synthesize wall1, wall2, wall3, wall4;
@synthesize floorPickUp;
@synthesize blocked;
@synthesize climbAttempt;
@synthesize climbLevel;
@synthesize climbTime;
@synthesize notes;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentIndex = _startingIndex;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    if (currentScore.tournament) {
        self.title =  [NSString stringWithFormat:@"%@ Match Analysis", currentScore.tournament.name];
    }
    else {
        self.title = @"Match Analysis";
    }
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextMatch:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.delegate = self;
    [self.view addGestureRecognizer:swipeLeft];
 
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPrevMatch:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.delegate = self;
    [self.view addGestureRecognizer:swipeRight];

    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    [self SetBigButtonDefaults:_prevMatchButton];
    [self SetBigButtonDefaults:_nextMatchButton];
    [self SetTextBoxDefaults:teamName];
    [self SetTextBoxDefaults:teamNumber];
    [self SetSmallTextBoxDefaults:autonScoreMade];
    [self SetSmallTextBoxDefaults:autonScoreShot];
    [self SetSmallTextBoxDefaults:autonHigh];
    [self SetSmallTextBoxDefaults:autonMed];
    [self SetSmallTextBoxDefaults:autonLow];
    [self SetSmallTextBoxDefaults:autonMissed];

    [self SetSmallTextBoxDefaults:teleOpScoreMade];
    [self SetSmallTextBoxDefaults:teleOpScoreShot];
    [self SetSmallTextBoxDefaults:teleOpHigh];
    [self SetSmallTextBoxDefaults:teleOpMed];
    [self SetSmallTextBoxDefaults:teleOpLow];
    [self SetSmallTextBoxDefaults:teleOpMissed];

    [self SetSmallTextBoxDefaults:pyramidGoals];
    
    [self SetSmallTextBoxDefaults:discPassed];
    [self SetSmallTextBoxDefaults:wallPickUp];
    [self SetSmallTextBoxDefaults:floorPickUp];
    [self SetSmallTextBoxDefaults:blocked];
    [self SetSmallTextBoxDefaults:wall1];
    [self SetSmallTextBoxDefaults:climbAttempt];
    [self SetSmallTextBoxDefaults:climbLevel];
    [self SetSmallTextBoxDefaults:climbTime];
    [self SetSmallTextBoxDefaults:wall2];
    [self SetSmallTextBoxDefaults:wall3];
    [self SetSmallTextBoxDefaults:wall4];
    baseDrawingPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/FieldDrawings/%@", drawDirectory]];


    [self setDisplayData];
}

-(void)setDisplayData {
    matchNumber.text = [NSString stringWithFormat:@"%d", [currentScore.match.number intValue]];
    [matchType setTitle:currentScore.match.matchType forState:UIControlStateNormal];
    teamName.text = currentScore.team.name;
    teamNumber.text = [NSString stringWithFormat:@"%d", [currentScore.team.number intValue]];

    autonScoreMade.text = [NSString stringWithFormat:@"%d", [currentScore.autonShotsMade intValue]];
    autonScoreShot.text = [NSString stringWithFormat:@"%d", [currentScore.totalAutonShots intValue]];
    autonHigh.text = [NSString stringWithFormat:@"%d", [currentScore.autonHigh intValue]];
    autonMed.text = [NSString stringWithFormat:@"%d", [currentScore.autonMid intValue]];
    autonLow.text = [NSString stringWithFormat:@"%d", [currentScore.autonLow intValue]];
    autonMissed.text = [NSString stringWithFormat:@"%d", [currentScore.autonMissed intValue]];
    
    teleOpScoreMade.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpShots intValue]];
    teleOpScoreShot.text = [NSString stringWithFormat:@"%d", [currentScore.totalTeleOpShots intValue]];
    teleOpHigh.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpHigh intValue]];
    teleOpMed.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpMid intValue]];
    teleOpLow.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpLow intValue]];
    teleOpMissed.text = [NSString stringWithFormat:@"%d", [currentScore.teleOpMissed intValue]];

    pyramidGoals.text = [NSString stringWithFormat:@"%d", [currentScore.pyramid intValue]];
    wallPickUp.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp intValue]];
    wall1.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp1 intValue]];
    wall2.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp2 intValue]];
    wall3.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp3 intValue]];
    wall4.text = [NSString stringWithFormat:@"%d", [currentScore.wallPickUp4 intValue]];
    floorPickUp.text = [NSString stringWithFormat:@"%d", [currentScore.floorPickUp intValue]];
    blocked.text = [NSString stringWithFormat:@"%d", [currentScore.blocks intValue]];
    discPassed.text = [NSString stringWithFormat:@"%d", [currentScore.passes intValue]];
    climbLevel.text = [NSString stringWithFormat:@"%d", [currentScore.climbLevel intValue]];
    climbAttempt.text = ([currentScore.climbAttempt intValue] == 0) ? @"N":@"Y";
    int timer = [currentScore.climbTimer intValue];
    climbTime.text = [NSString stringWithFormat:@"%02d:%02d", timer/60, timer%60];
    
    [self loadFieldDrawing];
}

-(void)loadFieldDrawing {
    if (currentScore.fieldDrawing) {
        // Load file, set file name to the name read, and load it as image
        NSLog(@"Field Drawing= %@", currentScore.fieldDrawing);
        fieldDrawingFile = currentScore.fieldDrawing;
        fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentScore.team.number intValue]]];
        NSString *path = [fieldDrawingPath stringByAppendingPathComponent:currentScore.fieldDrawing];
        NSLog(@"Full path = %@", path);
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [fieldImage setImage:[UIImage imageWithContentsOfFile:path]];
        }
        else {
            [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
            NSLog(@"Error reading field drawing file %@", fieldDrawingFile);
        }
    }
    else {
        // No field drawing name set in data base. Check default name just in case.
        [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];

        NSString *match;
        if ([currentScore.match.number intValue] < 10) {
            match = [NSString stringWithFormat:@"M%c%@", [currentScore.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [currentScore.match.number intValue]]];
        } else if ( [currentScore.match.number intValue] < 100) {
            match = [NSString stringWithFormat:@"M%c%@", [currentScore.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [currentScore.match.number intValue]]];
        } else {
            match = [NSString stringWithFormat:@"M%c%@", [currentScore.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [currentScore.match.number intValue]]];
        }
        NSString *team;
        if ([currentScore.team.number intValue] < 100) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [currentScore.team.number intValue]]];
        } else if ( [currentScore.team.number intValue] < 1000) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [currentScore.team.number intValue]]];
        } else {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [currentScore.team.number intValue]]];
        }
        fieldDrawingFile = [NSString stringWithFormat:@"%@_%@.png", match, team];
        fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentScore.team.number intValue]]];
        NSString *path = [fieldDrawingPath stringByAppendingPathComponent:fieldDrawingFile];
        NSLog(@"Full path = %@", path);
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [fieldImage setImage:[UIImage imageWithContentsOfFile:path]];
        }
        else {
            [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
            NSLog(@"Error reading field drawing file %@", fieldDrawingFile);
        }
 
    }
}

- (IBAction)nextMatch:(id)sender {
    if (currentIndex < ([_teamScores count]-1)) currentIndex++;
    else currentIndex = 0;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

- (IBAction)prevMatch:(id)sender {
    if (currentIndex == 0) currentIndex = [_teamScores count] - 1;
    else currentIndex--;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

-(void)gotoNextMatch:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (currentIndex < ([_teamScores count]-1)) currentIndex++;
    else currentIndex = 0;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

-(void)gotoPrevMatch:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (currentIndex == 0) currentIndex = [_teamScores count] - 1;
    else currentIndex--;
    currentScore = [_teamScores objectAtIndex:currentIndex];
    [self setDisplayData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetSmallTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:18.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
