//
//  MatchTypeDictionary.m
//  UltimateAscent
//
//  Created by FRC on 2/18/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MatchTypeDictionary.h"

@interface MatchTypeDictionary () {
    NSDictionary *dictionary;
    NSArray *objects;
}

@end
@implementation MatchTypeDictionary

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:Practice],
                         [NSNumber numberWithInt:Seeding],
                         [NSNumber numberWithInt:Elimination],
                         [NSNumber numberWithInt:Testing],
                         [NSNumber numberWithInt:Other],
                         nil];
                         
        objects = [NSArray arrayWithObjects:@"Practice", @"Seeding", @"Elimination", @"Testing", @"Other", nil];

        dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	}
	return self;
}

-(NSString *)getMatchTypeString:(id) key {
    return [dictionary objectForKey:key];
}

-(id)getMatchTypeEnum:(NSString *) value {
    NSArray *temp = [dictionary allKeysForObject:value];
    NSNumber *val = [temp objectAtIndex:0];
    return val;
}

-(NSArray *)getMatchTypes {
    return objects;

}

@end




