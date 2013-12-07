//
//  SettingsData.h
//  UltimateAscent
//
//  Created by FRC on 12/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TournamentData;

@interface SettingsData : NSManagedObject

@property (nonatomic, retain) NSString * adminCode;
@property (nonatomic, retain) NSString * alliance;
@property (nonatomic, retain) NSNumber * master;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSString * overrideCode;
@property (nonatomic, retain) TournamentData *tournament;

@end
