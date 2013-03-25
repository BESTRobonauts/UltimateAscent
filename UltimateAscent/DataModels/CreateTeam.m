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
 4  Drive Train Type
 5  Intake
 6  Wheel Diameter
 7  CIMS
 8  Minimum Height
 9  Maximum Height
 10  Shooter Height
 11 Pyramid Dump
 12 Climb Level
 13 Climb Speed
 14 Notes
 15 Saved
 16 Auton
 17 Number of Wheels
 18 Wheel Type
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
    TournamentData *tournamentRecord;
    if (team) {
        // NSLog(@"createTeamFromFile:Team %@ already exists", teamNumber);
        // NSLog(@"createTeamFromFile:************************************* Really need to add new tournament");
        tournament = [data objectAtIndex: 2];
        tournamentRecord = [self getTournamentRecord:tournament];
        [team addTournamentObject:tournamentRecord];
        // NSLog(@"Team = %@", team);
        return DB_MATCHED;
    }
    else {
        TeamData *team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                                           inManagedObjectContext:managedObjectContext];
        [self setTeamDefaults:team]; 
        switch ([data count]) {
            case 19:
                team.wheelType = [data objectAtIndex:18];
            case 17:
                team.nwheels = [NSNumber numberWithInt:[[data objectAtIndex:16] intValue]];
            case 16:
                team.auton = [NSNumber numberWithInt:[[data objectAtIndex:15] intValue]];
            case 15:
                team.saved = [NSNumber numberWithInt:[[data objectAtIndex:14] intValue]];
            case 14:
                team.notes = [data objectAtIndex: 13];
            case 13:
                team.climbSpeed = [NSNumber numberWithFloat:[[data objectAtIndex:12] floatValue]];
            case 12:
                team.climbLevel = [NSNumber numberWithInt:[[data objectAtIndex:11] intValue]];
            case 11:
                team.pyramidDump = [NSNumber numberWithInt:[[data objectAtIndex:10] intValue]];
            case 10:
                team.shooterHeight = [NSNumber numberWithFloat:[[data objectAtIndex:9] floatValue]];
            case 9:
                team.maxHeight = [NSNumber numberWithFloat:[[data objectAtIndex:8] floatValue]];
            case 8:
                team.minHeight = [NSNumber numberWithFloat:[[data objectAtIndex:7] floatValue]];
            case 7:
                team.cims = [NSNumber numberWithInt:[[data objectAtIndex:6] intValue]];
            case 6:
                team.wheelDiameter = [NSNumber numberWithFloat:[[data objectAtIndex:5] floatValue]];
            case 5:
                team.intake = [NSNumber numberWithInt:[[data objectAtIndex:4] intValue]];
            case 4:
                team.driveTrainType = [NSNumber numberWithInt:[[data objectAtIndex:3] intValue]];
            case 3:
                tournament = [data objectAtIndex: 2];
                if (tournament && ![tournament isEqualToString:@""]) {
                    tournamentRecord = [self getTournamentRecord:tournament];
                    [team addTournamentObject:tournamentRecord];
                }
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
