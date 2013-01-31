//
//  Settings.h
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tournament;

@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) Tournament *tournament;

@end
