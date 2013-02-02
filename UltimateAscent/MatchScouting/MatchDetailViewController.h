//
//  MatchDetailViewController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MatchData;
@class TeamScore;
@class TeamData;
@class SpecificGameData;
@class EndGameData;

@interface MatchDetailViewController : UIViewController <UITextFieldDelegate> 
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) MatchData *match;

@property (nonatomic, assign) BOOL textChangeDetected;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *roundType;
@property (nonatomic, retain) IBOutlet UITextField *red1TextField;
@property (nonatomic, retain) IBOutlet UITextField *red2TextField;
@property (nonatomic, retain) IBOutlet UITextField *red3TextField;
@property (nonatomic, retain) IBOutlet UITextField *blue1TextField;
@property (nonatomic, retain) IBOutlet UITextField *blue2TextField;
@property (nonatomic, retain) IBOutlet UITextField *blue3TextField;

-(TeamScore *)EditTeam:(int)teamNumber;
-(TeamData *)GetTeam:(int)teamNumber;
-(SpecificGameData *)CreateGameData;
-(EndGameData *)CreateEndGameData;

@end
