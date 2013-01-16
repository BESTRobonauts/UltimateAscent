//
//  MatchData.h
//  UltimateAscent
//
//  Created by FRC on 1/12/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MatchData : NSManagedObject

@property (nonatomic, retain) NSNumber * blueScore;
@property (nonatomic, retain) NSNumber * redScore;
@property (nonatomic, retain) NSString * matchType;
@property (nonatomic, retain) NSNumber * number;

@end
