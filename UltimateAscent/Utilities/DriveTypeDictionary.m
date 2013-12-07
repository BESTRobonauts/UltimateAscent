//
//  DriveTypeDictionary.m
//  UltimateAscent
//
//  Created by FRC on 10/10/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "DriveTypeDictionary.h"

@implementation DriveTypeDictionary {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:DriveUnknown],
                         [NSNumber numberWithInt:Mech],
                         [NSNumber numberWithInt:Omni],
                         [NSNumber numberWithInt:Swerve],
                         [NSNumber numberWithInt:Traction],
                         [NSNumber numberWithInt:Multi],
                         [NSNumber numberWithInt:Tank],
                         [NSNumber numberWithInt:WestCoast],
                         nil];
        
        objects = [NSArray arrayWithObjects:@"Unknown", @"Mech", @"Omni", @"Swerve", @"Traction", @"Multi", @"Tank", @"West Coast", nil];
        
        dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	}
	return self;
}

-(NSString *)getDriveTypeString:(id) key {
    NSString *result = [dictionary objectForKey:key];
    if (!result) result = @"Other";
    return result;
}

-(id)getDriveTypeEnum:(NSString *) value {
    NSArray *temp = [dictionary allKeysForObject:value];
    NSNumber *val = [temp objectAtIndex:0];
    return val;
}

-(NSArray *)getDriveTypes {
    return objects;
}

- (void)dealloc
{
    dictionary = nil;
    objects = nil;
#ifdef TEST_MODE
	NSLog(@"dealloc %@", self);
#endif
}
@end
