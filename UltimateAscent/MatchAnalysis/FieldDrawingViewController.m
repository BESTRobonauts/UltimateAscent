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

@implementation FieldDrawingViewController
@synthesize currentMatch;
@synthesize currentTeam;
@synthesize prevMatch;
@synthesize nextMatch;
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
    if (currentMatch.tournament) {
        self.title =  [NSString stringWithFormat:@"%@ Match Analysis", currentMatch.tournament];
    }
    else {
        self.title = @"Match Analysis";
    }
    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    [self SetBigButtonDefaults:prevMatch];
    [self SetBigButtonDefaults:nextMatch];
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
    matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
    [matchType setTitle:currentMatch.matchType forState:UIControlStateNormal];
    teamName.text = currentTeam.team.name;
    teamNumber.text = [NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]];

    autonScoreMade.text = [NSString stringWithFormat:@"%d", [currentTeam.autonShotsMade intValue]];
    autonScoreShot.text = [NSString stringWithFormat:@"%d", [currentTeam.totalAutonShots intValue]];
    autonHigh.text = [NSString stringWithFormat:@"%d", [currentTeam.autonHigh intValue]];
    autonMed.text = [NSString stringWithFormat:@"%d", [currentTeam.autonMid intValue]];
    autonLow.text = [NSString stringWithFormat:@"%d", [currentTeam.autonLow intValue]];
    autonMissed.text = [NSString stringWithFormat:@"%d", [currentTeam.autonMissed intValue]];
    
    teleOpScoreMade.text = [NSString stringWithFormat:@"%d", [currentTeam.teleOpShots intValue]];
    teleOpScoreShot.text = [NSString stringWithFormat:@"%d", [currentTeam.totalTeleOpShots intValue]];
    teleOpHigh.text = [NSString stringWithFormat:@"%d", [currentTeam.teleOpHigh intValue]];
    teleOpMed.text = [NSString stringWithFormat:@"%d", [currentTeam.teleOpMid intValue]];
    teleOpLow.text = [NSString stringWithFormat:@"%d", [currentTeam.teleOpLow intValue]];
    teleOpMissed.text = [NSString stringWithFormat:@"%d", [currentTeam.teleOpMissed intValue]];

    pyramidGoals.text = [NSString stringWithFormat:@"%d", [currentTeam.pyramid intValue]];
    wallPickUp.text = [NSString stringWithFormat:@"%d", [currentTeam.wallPickUp intValue]];
    wall1.text = [NSString stringWithFormat:@"%d", [currentTeam.wallPickUp1 intValue]];
    wall2.text = [NSString stringWithFormat:@"%d", [currentTeam.wallPickUp2 intValue]];
    wall3.text = [NSString stringWithFormat:@"%d", [currentTeam.wallPickUp3 intValue]];
    wall4.text = [NSString stringWithFormat:@"%d", [currentTeam.wallPickUp4 intValue]];
    floorPickUp.text = [NSString stringWithFormat:@"%d", [currentTeam.floorPickUp intValue]];
    blocked.text = [NSString stringWithFormat:@"%d", [currentTeam.blocks intValue]];
    discPassed.text = [NSString stringWithFormat:@"%d", [currentTeam.passes intValue]];
    climbLevel.text = [NSString stringWithFormat:@"%d", [currentTeam.climbLevel intValue]];
    climbAttempt.text = ([currentTeam.climbAttempt intValue] == 0) ? @"N":@"Y";
    int timer = [currentTeam.climbTimer intValue];
    climbTime.text = [NSString stringWithFormat:@"%02d:%02d", timer/60, timer%60];
    
    [self loadFieldDrawing];
}

-(void)loadFieldDrawing {
    if (currentTeam.fieldDrawing) {
        // Load file, set file name to the name read, and load it as image
        NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        fieldDrawingFile = currentTeam.fieldDrawing;
        fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]]];
        NSString *path = [fieldDrawingPath stringByAppendingPathComponent:currentTeam.fieldDrawing];
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
        // NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
        NSString *match;
        if ([currentMatch.number intValue] < 10) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [currentMatch.number intValue]]];
        } else if ( [currentMatch.number intValue] < 100) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [currentMatch.number intValue]]];
        } else {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [currentMatch.number intValue]]];
        }
        NSString *team;
        if ([currentTeam.team.number intValue] < 100) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [currentTeam.team.number intValue]]];
        } else if ( [currentTeam.team.number intValue] < 1000) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [currentTeam.team.number intValue]]];
        } else {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]]];
        }
        // Since no field drawing exists, we guess that the user wants to start in auton mode
        fieldDrawingFile = [NSString stringWithFormat:@"%@_%@.png", match, team];
        [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
    }
 
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
