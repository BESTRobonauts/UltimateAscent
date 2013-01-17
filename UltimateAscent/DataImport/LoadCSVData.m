//
//  LoadCSVData.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "LoadCSVData.h"
#import "parseCSV.h"
#import "CreateTeam.h"
#import "CreateMatch.h"
#import "AddRecordResults.h"

@implementation LoadCSVData

-(void)loadCSVDataFromBundle {
    NSLog(@"loadCSVDataFromBundle");

  DataManager *dataManager = [DataManager new];
    BOOL loadDataFromBundle = [dataManager databaseExists];

    if (loadDataFromBundle) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TeamList" ofType:@"csv"];  
        [self loadTeamFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"MatchList" ofType:@"csv"];  
        [self loadMatchFile:filePath];

        filePath = [[NSBundle mainBundle] pathForResource:@"MatchResults" ofType:@"csv"];  
        [self loadMatchResults:filePath];
    }
 
}

-(void) handleOpenURL:(NSURL *)url {
    NSString *filePath = [url path];
    NSLog(@"Emailed File = %@", filePath);
    NSLog(@"Add decision for team or match file");
    [self loadTeamFile:filePath];
    [self loadMatchFile:filePath];
    [self loadMatchResults:filePath];
}
-(void)loadTeamFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
     [parser openFile: filePath];
     NSMutableArray *csvContent = [parser parseFile];
     if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Team Number"]) {
       CreateTeam *team = [CreateTeam new];
         int c;
         for (c = 1; c < [csvContent count]; c++) {
             NSLog(@"loadTeamFile:TeamNumber = %@", [[csvContent objectAtIndex: c] objectAtIndex:0]);
             AddRecordResults results = [team createTeamFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
        }
     }
     [parser closeFile]; 
}

-(void)loadMatchFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Match"]) {
        CreateMatch *match = [CreateMatch new];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
//            NSLog(@"Match = %@", [csvContent objectAtIndex: c]);
            AddRecordResults results = [match createMatchFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
        }
    }
    [parser closeFile]; 
} 

-(void)loadMatchResults:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    if ([[[csvContent objectAtIndex: 0] objectAtIndex:0] isEqualToString:@"Match"]) {
        CreateMatch *match = [CreateMatch new];
        int c;
        for (c = 1; c < [csvContent count]; c++) {
            //            NSLog(@"Match = %@", [csvContent objectAtIndex: c]);
            AddRecordResults results = [match addMatchResultsFromFile:[csvContent objectAtIndex: 0] dataFields:[csvContent objectAtIndex: c]];
        }
    }
    [parser closeFile];    
}


@end
