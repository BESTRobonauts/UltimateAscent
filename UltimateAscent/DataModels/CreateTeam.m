//
//  CreateTeam.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/24/12.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import "CreateTeam.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TournamentData.h"

// Current File Order
/*
 1  Number
 2  Name
 3  Tournament
 4  Climbing
 5  Intake
 6  Upside Down
 7  Notes
 8  History

 Things to add yet
    Drive Train Notes
    
*/
@implementation CreateTeam
@synthesize managedObjectContext;

-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *teamNumber;
    NSString *tournament;

    if (![data count]) return DB_ERROR;

    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }

    teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    // NSLog(@"createTeamFromFile:Team Number = %@", teamNumber);
    TeamData *team = [self GetTeam:teamNumber];
    if (team) {
        NSLog(@"createTeamFromFile:Team %@ already exists", teamNumber);
        NSLog(@"createTeamFromFile:************************************* Really need to add new tournament");
        return DB_MATCHED;
    }
    else {
        NSNumber *number;
        TournamentData *tournamentRecord;
        TeamData *team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                                           inManagedObjectContext:managedObjectContext];
        [self setTeamDefaults:team];
        switch ([data count]) {
            case 5:
                team.history = [data objectAtIndex: 4];
            case 4:
                 team.notes = [data objectAtIndex: 3];
/*
            case 6:
                number = [NSNumber numberWithInt:[[data objectAtIndex:4] intValue]];
                team.intakeInverted = number;
            case 5:
                number = [NSNumber numberWithInt:[[data objectAtIndex:3] intValue]];
                team.intakeFloor = number;
            case 5:
                number = [NSNumber numberWithInt:[[data objectAtIndex:3] intValue]];
                team.intakeStation = number;
            case 4:
                number = [NSNumber numberWithInt:[[data objectAtIndex:2] intValue]];
                team.climbType = number;
 */
            case 3:
                tournament = [data objectAtIndex: 2];
                tournamentRecord = [self getTournamentRecord:tournament];
                [team addTournamentObject:tournamentRecord];
            case 2:
                team.name = [data objectAtIndex: 1];
            case 1:
                team.number = teamNumber;
        }
        // NSLog(@"Added Team Record %@", team);
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
        }
        else return DB_ADDED;
    }
}

-(TeamData *)GetTeam:(NSNumber *)teamNumber {
    TeamData *team;

    // NSLog(@"Searching for team = %@", teamNumber);
    NSError *error;
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", teamNumber];    
    [fetchRequest setPredicate:pred];   
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
        return Nil;
    } 
    else {
        if([teamData count] > 0) {  // Team Exists
            team = [teamData objectAtIndex:0];
            // NSLog(@"Team %@ exists", team.number);
            return team;
        }
        else {
            return Nil;
        }
    }
}

-(TournamentData *)getTournamentRecord:(NSString *)tournamentName {
    NSError *error;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
              entityForName:@"TournamentData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", tournamentName];
    [fetchRequest setPredicate:pred];

    NSArray *tournamentData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([tournamentData count] > 0) {  // Tournament Exists
            TournamentData *tournamentRecord = [tournamentData objectAtIndex:0];
            // NSLog(@"Tournament %@ exists", tournamentRecord.name);
            return tournamentRecord;
        }
        else return Nil;
    }
}

-(void)setTeamDefaults:(TeamData *)blankTeam {
    blankTeam.number = [NSNumber numberWithInt:0];
    blankTeam.name = @"";
    blankTeam.climbLevel = [NSNumber numberWithInt:-1];
    blankTeam.driveTrainType = [NSNumber numberWithInt:-1];
    blankTeam.history = @"";
    blankTeam.intake = [NSNumber numberWithInt:-1];
    blankTeam.climbSpeed = [NSNumber numberWithFloat:0.0];
    blankTeam.notes = @"";
    blankTeam.wheelDiameter = [NSNumber numberWithFloat:0.0];
    blankTeam.cims = [NSNumber numberWithInt:0];
    blankTeam.minHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.maxHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.shooterHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.pyramidDump = [NSNumber numberWithInt:-1];
    blankTeam.saved = [NSNumber numberWithInt:0];
}


@end
