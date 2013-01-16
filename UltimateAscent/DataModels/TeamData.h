//
//  TeamData.h
//  UltimateAscent
//
//  Created by FRC on 1/12/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TeamData : NSManagedObject

@property (nonatomic, retain) NSString * history;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * saved;

@end
