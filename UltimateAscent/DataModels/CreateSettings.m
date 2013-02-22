//
//  CreateSettings.m
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "CreateSettings.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"

// Current File Order
/*
    1   Mode
    2   Display Tournament
    3   Master iPad
    4   Admin Code
    5   Override Code
 */

@implementation CreateSettings
@synthesize managedObjectContext;

-(AddRecordResults)createSettingsFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    SettingsData *settings;
    NSString *tournament;
    NSError *error;
    
    if (![data count]) return DB_ERROR;
    
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
     
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!settingsRecord) {
        NSLog(@"Karma disruption error");
        return DB_ERROR;
    }
    else {
        if([settingsRecord count] == 0) {  // No Settings Exists
            settings = [NSEntityDescription insertNewObjectForEntityForName:@"SettingsData"
                                                        inManagedObjectContext:managedObjectContext];
         }
        else {
            settings = [settingsRecord objectAtIndex:0];
        }
    }

    switch ([data count]) {
        case 5:
            settings.overrideCode = [data objectAtIndex: 4];
        case 4:
            settings.adminCode = [data objectAtIndex: 3];
        case 3:
            settings.master = [NSNumber numberWithInt:[[data objectAtIndex:2] intValue]];
        case 2:
            tournament = [data objectAtIndex: 1];
        case 1:
            settings.mode = [data objectAtIndex: 0];
    }
    // NSLog(@"createSettingsFromFile:Settings = %@", settings);
            
    // Some day add a check for valid modes. Currently only Test and Tournament are valid.

    // Need to add something to properly "release" the tournament relationship if it already exists
    entity = [NSEntityDescription
              entityForName:@"TournamentData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", tournament];
    [fetchRequest setPredicate:pred];
    NSArray *tournamentData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        settings.tournament = nil;
        // At least save what we did manage to set
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        return DB_ERROR;
    }
    else {
        TournamentData *tournamentRecord = [tournamentData objectAtIndex:0];
        // NSLog(@"Tournament %@ exists", tournamentRecord.name);
        settings.tournament = tournamentRecord;
    }
    if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
    }
    else return DB_ADDED;
    
}

@end
