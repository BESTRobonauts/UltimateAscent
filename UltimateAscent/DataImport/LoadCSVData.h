//
//  LoadCSVData.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadCSVData : NSObject

-(void)loadCSVDataFromBundle;
-(void)handleOpenURL:(NSURL *)url;
-(void)loadTournamentFile:(NSString *)filePath;
-(void)loadSettingsFile:(NSString *)filePath;
-(void)loadTeamFile:(NSString *)filePath;
-(void)loadMatchFile:(NSString *)filePath;
-(void)loadMatchResults:(NSString *)filePath;

@end
