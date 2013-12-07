//
//  Photo.h
//  UltimateAscent
//
//  Created by FRC on 12/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) TeamData *teamPhoto;

@end
