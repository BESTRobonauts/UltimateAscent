//
//  CreateSettings.h
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class SettingsData;

@interface CreateSettings : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(AddRecordResults)createSettingsFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(SettingsData *)GetSettings;


@end
