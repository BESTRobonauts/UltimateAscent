//
//  SettingsData.h
//  UltimateAscent
//
//  Created by FRC on 2/1/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TournamentData;

@interface SettingsData : NSManagedObject

@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) TournamentData *tournament;

@end
