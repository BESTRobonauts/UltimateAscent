//
//  MatchResultsObject.m
//  UltimateAscent
//
//  Created by FRC on 3/14/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "MatchResultsObject.h"
#import "TournamentData.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "MatchData.h"

@implementation MatchResultsObject
@synthesize alliance;
@synthesize autonHigh;
@synthesize autonLow;
@synthesize autonMid;
@synthesize autonMissed;
@synthesize autonShotsMade;
@synthesize blocks;
@synthesize climbAttempt;
@synthesize climbLevel;
@synthesize climbTimer;
@synthesize defenseRating;
@synthesize driverRating;
@synthesize fieldDrawing;
@synthesize floorPickUp;
@synthesize notes;
@synthesize otherRating;
@synthesize passes;
@synthesize pyramid;
@synthesize saved;
@synthesize teleOpHigh;
@synthesize teleOpLow;
@synthesize teleOpMid;
@synthesize teleOpMissed;
@synthesize teleOpShots;
@synthesize totalAutonShots;
@synthesize totalTeleOpShots;
@synthesize wallPickUp;
@synthesize wallPickUp1;
@synthesize wallPickUp2;
@synthesize wallPickUp3;
@synthesize wallPickUp4;
@synthesize synced;
@synthesize robotSpeed;
@synthesize match;
@synthesize matchType;
@synthesize tournament;
@synthesize team;
@synthesize fieldDrawingImage;

- (id)initWithScore:(TeamScore *)score {
    self.alliance = score.alliance;
    self.autonHigh = score.autonHigh;
    self.autonLow = score.autonLow;
    self.autonMid = score.autonMid;
    self.autonMissed = score.autonMissed;
    self.autonShotsMade = score.autonShotsMade;
    self.blocks = score.blocks;
    self.climbAttempt = score.climbAttempt;
    self.climbLevel = score.climbLevel;
    self.climbTimer = score.climbTimer;
    self.defenseRating = score.defenseRating;
    self.driverRating = score.driverRating;
    self.fieldDrawing = score.fieldDrawing;
    self.floorPickUp = score.floorPickUp;
    self.notes = score.notes;
    self.otherRating = score.otherRating;
    self.passes = score.passes;
    self.pyramid = score.pyramid;
    self.saved = score.saved;
    self.teleOpHigh = score.teleOpHigh;
    self.teleOpLow = score.teleOpLow;
    self.teleOpMid = score.teleOpMid;
    self.teleOpMissed = score.teleOpMissed;
    self.teleOpShots = score.teleOpShots;
    self.totalAutonShots = score.totalAutonShots;
    self.totalTeleOpShots = score.totalTeleOpShots;
    self.wallPickUp = score.wallPickUp;
    self.wallPickUp1 = score.wallPickUp1;
    self.wallPickUp2 = score.wallPickUp2;
    self.wallPickUp3 = score.wallPickUp3;
    self.wallPickUp4 = score.wallPickUp4;
    self.synced = score.synced;
    self.robotSpeed = score.robotSpeed;
    self.match = score.match.number;
    self.matchType = score.match.matchType;
    self.tournament = score.tournament.name;
    self.team = score.team.number;
    
    NSString *baseDrawingPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/FieldDrawings/%@/%d/%@", score.tournament.directory, [score.team.number intValue], score.fieldDrawing]];
    self.fieldDrawingImage = UIImagePNGRepresentation([UIImage imageNamed:baseDrawingPath]);
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.alliance = [decoder decodeObjectForKey:@"alliance"];
        self.autonHigh = [decoder decodeObjectForKey:@"autonHigh"];
        self.autonLow = [decoder decodeObjectForKey:@"autonLow"];
        self.autonMid = [decoder decodeObjectForKey:@"autonMid"];
        self.autonMissed = [decoder decodeObjectForKey:@"autonMissed"];
        self.autonShotsMade = [decoder decodeObjectForKey:@"autonShotsMade"];
        self.blocks = [decoder decodeObjectForKey:@"blocks"];
        self.climbAttempt = [decoder decodeObjectForKey:@"climbAttempt"];
        self.climbLevel = [decoder decodeObjectForKey:@"climbLevel"];
        self.climbTimer = [decoder decodeObjectForKey:@"climbTimer"];
        self.defenseRating = [decoder decodeObjectForKey:@"defenseRating"];
        self.driverRating = [decoder decodeObjectForKey:@"driverRating"];
        self.fieldDrawing = [decoder decodeObjectForKey:@"fieldDrawing"];
        self.floorPickUp = [decoder decodeObjectForKey:@"floorPickUp"];
        self.notes = [decoder decodeObjectForKey:@"notes"];
        self.otherRating = [decoder decodeObjectForKey:@"otherRating"];
        self.passes = [decoder decodeObjectForKey:@"passes"];
        self.pyramid = [decoder decodeObjectForKey:@"pyramid"];
        self.saved = [decoder decodeObjectForKey:@"saved"];
        self.teleOpHigh = [decoder decodeObjectForKey:@"teleOpHigh"];
        self.teleOpLow = [decoder decodeObjectForKey:@"teleOpLow"];
        self.teleOpMid = [decoder decodeObjectForKey:@"teleOpMid"];
        self.teleOpMissed = [decoder decodeObjectForKey:@"teleOpMissed"];
        self.teleOpShots = [decoder decodeObjectForKey:@"teleOpShots"];
        self.totalAutonShots = [decoder decodeObjectForKey:@"totalAutonShots"];
        self.totalTeleOpShots = [decoder decodeObjectForKey:@"totalTeleOpShots"];
        self.wallPickUp = [decoder decodeObjectForKey:@"wallPickUp"];
        self.wallPickUp1 = [decoder decodeObjectForKey:@"wallPickUp1"];
        self.wallPickUp2 = [decoder decodeObjectForKey:@"wallPickUp2"];
        self.wallPickUp3 = [decoder decodeObjectForKey:@"wallPickUp3"];
        self.wallPickUp4 = [decoder decodeObjectForKey:@"wallPickUp4"];
        self.synced = [decoder decodeObjectForKey:@"synced"];
        self.robotSpeed = [decoder decodeObjectForKey:@"robotSpeed"];
        self.fieldDrawingImage = [decoder decodeObjectForKey:@"fieldDrawingImage"];
        self.match = [decoder decodeObjectForKey:@"match"];
        self.matchType = [decoder decodeObjectForKey:@"matchType"];
        self.tournament = [decoder decodeObjectForKey:@"tournament"];
        self.team = [decoder decodeObjectForKey:@"team"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:alliance forKey:@"alliance"];
    [encoder encodeObject:autonHigh forKey:@"autonHigh"];
    [encoder encodeObject:autonLow forKey:@"autonLow"];
    [encoder encodeObject:autonMid forKey:@"autonMid"];
    [encoder encodeObject:autonMissed forKey:@"autonMissed"];
    [encoder encodeObject:autonShotsMade forKey:@"autonShotsMade"];
    [encoder encodeObject:blocks forKey:@"blocks"];
    [encoder encodeObject:climbAttempt forKey:@"climbAttempt"];
    [encoder encodeObject:climbLevel forKey:@"climbLevel"];
    [encoder encodeObject:climbTimer forKey:@"climbTimer"];
    [encoder encodeObject:defenseRating forKey:@"defenseRating"];
    [encoder encodeObject:driverRating forKey:@"driverRating"];
    [encoder encodeObject:fieldDrawing forKey:@"fieldDrawing"];
    [encoder encodeObject:floorPickUp forKey:@"floorPickUp"];
    [encoder encodeObject:notes forKey:@"notes"];
    [encoder encodeObject:otherRating forKey:@"otherRating"];
    [encoder encodeObject:passes forKey:@"passes"];
    [encoder encodeObject:pyramid forKey:@"pyramid"];
    [encoder encodeObject:saved forKey:@"saved"];
    [encoder encodeObject:teleOpHigh forKey:@"teleOpHigh"];
    [encoder encodeObject:teleOpLow forKey:@"teleOpLow"];
    [encoder encodeObject:teleOpMid forKey:@"teleOpMid"];
    [encoder encodeObject:teleOpMissed forKey:@"teleOpMissed"];
    [encoder encodeObject:teleOpShots forKey:@"teleOpShots"];
    [encoder encodeObject:totalAutonShots forKey:@"totalAutonShots"];
    [encoder encodeObject:totalTeleOpShots forKey:@"totalTeleOpShots"];
    [encoder encodeObject:wallPickUp forKey:@"wallPickUp"];
    [encoder encodeObject:wallPickUp1 forKey:@"wallPickUp1"];
    [encoder encodeObject:wallPickUp2 forKey:@"wallPickUp2"];
    [encoder encodeObject:wallPickUp3 forKey:@"wallPickUp3"];
    [encoder encodeObject:wallPickUp4 forKey:@"wallPickUp4"];
    [encoder encodeObject:synced forKey:@"synced"];
    [encoder encodeObject:robotSpeed forKey:@"robotSpeed"];
    [encoder encodeObject:match forKey:@"match"];
    [encoder encodeObject:matchType forKey:@"matchType"];
    [encoder encodeObject:tournament forKey:@"tournament"];
    [encoder encodeObject:team forKey:@"team"];
    [encoder encodeObject:fieldDrawingImage forKey:@"fieldDrawingImage"];
}

@end
