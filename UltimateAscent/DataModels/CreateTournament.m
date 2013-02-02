//
//  CreateTournament.m
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "CreateTournament.h"
#import "DataManager.h"
#import "TournamentData.h"

// Current File Order
/*
 1  Tournament
 2  Directory Name 
*/

@implementation CreateTournament
@synthesize managedObjectContext;

-(AddRecordResults)createTournamentFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSString *name;
    
    if (![data count]) return DB_ERROR;
    
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
    
    name = [data objectAtIndex: 0];
    NSLog(@"createTournamentFromFile:Tournament = %@", name);
    TournamentData *tournament = [self GetTournament:name];
    if (tournament) {
        NSLog(@"createTournamentFromFile:Tournament %@ already exists", tournament);
        return DB_MATCHED;
    }
    else {
        TournamentData *tournament = [NSEntityDescription insertNewObjectForEntityForName:@"TournamentData"
                                                       inManagedObjectContext:managedObjectContext];
        switch ([data count]) {
            case 2:
                tournament.directory = [data objectAtIndex: 1];
            case 1:
                tournament.name = name;
        }
        NSLog(@"Added Tournament Record %@", tournament);
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
        }
        else return DB_ADDED;
    }
}

-(TournamentData *)GetTournament:(NSString *)name {
    TournamentData *tournament;
    
    NSLog(@"Searching for tournament = %@", name);
    NSError *error;
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", name];
    [fetchRequest setPredicate:pred];
    NSArray *tournamentData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([tournamentData count] > 0) {  // Tournament Exists
            tournament = [tournamentData objectAtIndex:0];
            NSLog(@"Tournament %@ exists", tournament.name);
            return tournament;
        }
        else {
            return Nil;
        }
    }
}

@end
