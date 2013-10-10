//
//  LoadCSVData.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "LoadCSVData.h"
#import "parseCSV.h"
#import "TeamDataInterfaces.h"
#import "CreateMatch.h"
#import "CreateTournament.h"
#import "CreateSettings.h"
#import "AddRecordResults.h"

@implementation LoadCSVData {
    BOOL loadDataFromBundle;
}

@synthesize dataManager = _dataManager;
@synthesize settings = _settings;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(void)loadCSVDataFromBundle {
    // NSLog(@"loadCSVDataFromBundle");

    if (_dataManager == nil) {
        _dataManager = [DataManager new];
        loadDataFromBundle = [_dataManager databaseExists];
    }
    else {
        loadDataFromBundle = _dataManager.loadDataFromBundle;
    }
    
    if (loadDataFromBundle) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TournamentList" ofType:@"csv"];
        [self loadTournamentFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"csv"];
        [self loadSettingsFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"TeamList" ofType:@"csv"];
        [self loadTeamFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"TeamHistory" ofType:@"csv"];
        [self loadTeamHistory:filePath];
        
        filePath = [[NSBundle mainBundle] pathForResource:@"MatchList" ofType:@"csv"];
        [self loadMatchFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"MatchResults" ofType:@"csv"];
        [self loadMatchResults:filePath];
    }
 
}

-(void) handleOpenURL:(NSURL *)url {
    if (_dataManager == nil) {
        _dataManager = [DataManager new];
    }
    NSString *filePath = [url path];
    NSLog(@"Emailed File = %@", filePath);
    NSLog(@"Add decision for team or match file");
    [self loadTournamentFile:filePath];
    [self loadSettingsFile:filePath];
    [self loadTeamFile:filePath];
    [self loadTeamHistory:filePath];
    NSLog(@"loaded history");
    [self loadMatchFile:filePath];
//    [self loadMatchResults:filePath];
}

-(void)loadTournamentFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Tournament"]) {
        CreateTournament *tournament = [[CreateTournament alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
            // NSLog(@"loadTournamentFile:Tournament = %@", [[csvContent objectAtIndex: c] objectAtIndex:0]);
            AddRecordResults results = [tournament createTournamentFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_ADDED) {
                NSLog(@"Check database - Tournament Add Code %d", results);
            }
        }
    }
    [parser closeFile];
}

-(void)loadSettingsFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Mode"]) {
        CreateSettings *settings = [[CreateSettings alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
             NSLog(@"loadSettingsFile:Mode = %@", [[csvContent objectAtIndex: c] objectAtIndex:0]);
            AddRecordResults results = [settings createSettingsFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_ADDED) {
                NSLog(@"Check database - Settings Add Code %d", results);
            }
        }
    }
    [parser closeFile];
}

-(void)loadTeamFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Team Number"]) {
        TeamDataInterfaces *team = [[TeamDataInterfaces alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
            // NSLog(@"loadTeamFile:TeamNumber = %@", [[csvContent objectAtIndex: c] objectAtIndex:0]);
            AddRecordResults results = [team createTeamFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_ADDED) {
                NSLog(@"Check database - Team Add Code %d", results);
            }
        }
#ifdef TEST_MODE
        [team testTeamInterfaces];
#endif
    }
    [parser closeFile]; 
}

-(void)loadTeamHistory:(NSString *)filePath {
    NSLog(@"Team History");
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];

    if (![csvContent count]) return;
    
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Team History"]) {
        TeamDataInterfaces *team = [[TeamDataInterfaces alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
            // NSLog(@"loadTeamFile:TeamNumber = %@", [[csvContent objectAtIndex: c] objectAtIndex:0]);
            AddRecordResults results = [team addTeamHistoryFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_MATCHED) {
                NSLog(@"Check database - Team History Add Code %d", results);
            }
        }
#ifdef TEST_MODE
        [team testTeamInterfaces];
#endif
    }
    [parser closeFile];
}

-(void)loadMatchFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Match"]) {
        CreateMatch *match = [[CreateMatch alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
//            NSLog(@"Match = %@", [csvContent objectAtIndex: c]);
            AddRecordResults results = [match createMatchFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_ADDED) {
                NSLog(@"Check database - Match Add Code %d", results);
            }
        }
    }
    [parser closeFile]; 
} 

-(void)loadMatchResults:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Tournament"]) {
        CreateMatch *match = [[CreateMatch alloc] initWithDataManager:_dataManager];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
            // NSLog(@"Match = %@", [csvContent objectAtIndex: c]);
            AddRecordResults results = [match addMatchResultsFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
            if (results != DB_ADDED) {
                NSLog(@"Check database - Match Results Code %d", results);
            }
        }
    }
    [parser closeFile];    
}

-(void)retrieveSettings {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!settingsRecord) {
        NSLog(@"Karma disruption error");
        _settings = Nil;
    }
    else {
        if([settingsRecord count] == 0) {  // No Settings Exists
            NSLog(@"Karma disruption error");
            _settings = Nil;
        }
        else {
            _settings = [settingsRecord objectAtIndex:0];
        }
    }
}

@end
