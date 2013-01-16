//
//  CreateTeam.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class TeamData;

@interface CreateTeam : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(TeamData *)GetTeam:(NSNumber *)teamNumber;
-(void)setTeamDefaults:(TeamData *)blankTeam;

@end
