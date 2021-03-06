//
//  RouteVO.m
//  CycleStreets
//
//  Created by neil on 17/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteVO.h"
#import "SegmentVO.h"
#import "SettingsManager.h"
#import "AppConstants.h"
#import "GlobalUtilities.h"
#import "NSDate+Helper.h"
#import "CycleStreets.h"

@implementation RouteVO
@synthesize segments;
@synthesize routeid;
@synthesize northEast;
@synthesize southWest;
@synthesize name;
@synthesize speed;
@synthesize length;
@synthesize plan;
@synthesize time;
@synthesize date;
@synthesize userRouteName;
@synthesize calorie;
@synthesize cosaved;



- (id)init {
    if (self = [super init]) {
		
    }
    return self;
}




- (SegmentVO *) segmentAtIndex:(NSInteger)index {
	return [segments objectAtIndex:index];
}


#pragma mark - getters
//
/***********************************************
 * @description			getters
 ***********************************************/
//

- (NSInteger) numSegments {
	return [segments count];
}


-(NSInteger)coordCount{
	
	NSInteger count=0;
	
	for (int i = 0; i < [self numSegments]; i++) {
		
		if (i == 0)
			count++;
		
		SegmentVO *segment = [self segmentAtIndex:i];
		NSArray *allPoints = [segment allPoints];
		for (int i = 1; i < [allPoints count]; i++) {
			count++;
		}
	}
	
	return count;
	
}



- (NSString *) nameString {
	
	if(userRouteName==nil || [userRouteName isEqualToString:EMPTYSTRING]){
		return name;
	}else{
		return userRouteName;
	}
}


-(NSString*)timeString{
	
	NSInteger h = [self time] / 3600;
	NSInteger m = ([self time] / 60) % 60;
	NSInteger s = [self time] % 60;
	
	if ([self time]>3600) {
		return [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h,(unsigned long)m,(unsigned long)s];
	}else {
		return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m,(unsigned long)s];
	}
}

-(NSString*)lengthString{
	
	return [CycleStreets formattedDistanceString:[self.length doubleValue]];
	
}



-(NSString*)lengthPercentStringForPercent:(float)percent{
	
	
	double percentValue=[self.length doubleValue]*(double)percent;
	return [CycleStreets formattedDistanceString:percentValue];
	
	
}




-(NSString*)speedString{
	
	NSNumber *kmSpeed = [NSNumber numberWithInteger:[self speed]];
	if([SettingsManager sharedInstance].routeUnitisMiles==YES) {
		NSInteger mileSpeed = [[NSNumber numberWithDouble:([kmSpeed doubleValue] / 1.6)] integerValue];
		return [NSString stringWithFormat:@"%2ld mph", (long)mileSpeed];
	}else {
		return [NSString stringWithFormat:@"%@ km/h", kmSpeed];
	}
}

-(NSString*)dateString{
	
	NSDate *newdate=[NSDate dateFromString:[self date] withFormat:[NSDate dbFormatString]];
	return [NSDate stringFromDate:newdate withFormat:@"eee d MMMM y HH:mm"];
	
}

-(NSString*)dateOnlyString{
	
	NSDate *newdate=[NSDate dateFromString:[self date] withFormat:[NSDate dbFormatString]];
	return [NSDate stringFromDate:newdate withFormat:@"y-MM-dd 00:00:00"];
	
}

-(NSDate*)dateObject{
	
	return [NSDate dateFromString:[self date] withFormat:[NSDate dbFormatString]];	
	
}

-(NSString*)planString{
	
	return [[self plan] capitalizedString];
	
}

-(NSString*)calorieString{
	
	if(calorie!=nil && ![calorie isEqualToString: EMPTYSTRING]){
		return [NSString stringWithFormat:@"%@ kcal",calorie];
	}else{
		return @"N/A";
	}
	
	
}
-(NSString*)coString{
	
	if(cosaved!=nil && ![cosaved isEqualToString:EMPTYSTRING]){
		return [NSString stringWithFormat:@"%@ gms",cosaved];
	}else{
		return @"N/A";
	}
	
}

-(NSURL*)csrouteurl{
	return [NSURL URLWithString:self.csiOSRouteurlString];
}


-(NSString*)csiOSRouteurlString{
	return [NSString stringWithFormat:@"cyclestreets://route/%@",self.routeid];
}
-(NSString*)csBrowserRouteurlString{
	return [NSString stringWithFormat:@"http://www.cyclestreets.net/journey/%@",self.routeid];
}

-(BOOL)containsWalkingSections{
	
	for (SegmentVO *segment in segments) {
		
		if(segment.isWalkingSection==YES)
			return YES;
	}
	return NO;
}



#pragma mark - waypoints

-(BOOL)hasWaypoints{
	return _waypoints!=nil;
}

-(NSMutableArray*)createCorrectedWaypointArray{
	
	NSMutableArray *arr=[_waypoints mutableCopy];
	
	if(arr.count>2){
		[arr exchangeObjectAtIndex:arr.count-1 withObjectAtIndex:1];
	}
	
	return _waypoints;
	
}



#pragma mark - pois
-(BOOL)hasPOIs{
	return _poiArray!=nil || _poiArray.count!=0;
}



#pragma mark - Elevation

-(int)maxElevation{
	
	int value=0;
	
	for(SegmentVO *segment in segments){
		value=MAX(value, segment.segmentElevation);
	}
	return value;
}


-(BOOL)hasElevationData{
	
	SegmentVO *segment=segments[0];
	return segment.elevations!=nil;
	
}





//
/***********************************************
 * @description			CL getters: note use of CLLocation so NSCoding is optimised.
 ***********************************************/
//

- (CLLocationCoordinate2D) basicNorthEast {
	CLLocationCoordinate2D location;
	location.latitude = northEast.coordinate.latitude;
	location.longitude = northEast.coordinate.longitude;
	return location;
}

- (CLLocationCoordinate2D) basicSouthWest {
	CLLocationCoordinate2D location;
	location.latitude = southWest.coordinate.latitude;
	location.longitude = southWest.coordinate.longitude;
	return location;	
}

- (CLLocationCoordinate2D) insetNorthEast {
	CLLocationCoordinate2D location;
	location.latitude = northEast.coordinate.latitude+0.002;
	location.longitude = northEast.coordinate.longitude+0.002;
	return location;
}

- (CLLocationCoordinate2D) insetSouthWest {
	CLLocationCoordinate2D location;
	location.latitude = southWest.coordinate.latitude-0.002;
	location.longitude = southWest.coordinate.longitude-0.002;
	return location;	
}


//
/***********************************************
 * @description			Mthods to create ne/sw bounding locations for 2 points
 ***********************************************/
//
-(CLLocationCoordinate2D)maxNorthEastForLocation:(CLLocation*)comparelocation{
	
	CLLocationCoordinate2D location;
	
	CLLocation *routelocation=self.northEast;
	
	// compare n>n, max is lower
	double selflatitude=routelocation.coordinate.latitude;
	double comparelatitude=comparelocation.coordinate.latitude;
	location.latitude=MAX(selflatitude, comparelatitude)+0.002;
	
	
	// compare e>e, max is higher
	double selflongtitude=routelocation.coordinate.longitude;
	double comparelongtitude=comparelocation.coordinate.longitude;
	location.longitude=MAX(selflongtitude, comparelongtitude)+0.002;
	
	return location;
}


-(CLLocationCoordinate2D)maxSouthWestForLocation:(CLLocation*)comparelocation{
	
	CLLocationCoordinate2D location;
	
	CLLocation *routelocation=self.southWest;
	
	// compare s>s, max is lower
	double selflatitude=routelocation.coordinate.latitude;
	double comparelatitude=comparelocation.coordinate.latitude;
	location.latitude=MIN(selflatitude, comparelatitude)-0.006;
	
	
	// compare w>w, max is higher
	double selflongtitude=routelocation.coordinate.longitude;
	double comparelongtitude=comparelocation.coordinate.longitude;
	location.longitude=MIN(selflongtitude, comparelongtitude)-0.002;
	
	return location;
}



-(NSString*)fileid{
	return [NSString stringWithFormat:@"%@_%@",routeid,plan];
}


//
/***********************************************
 * @description			NSCODING
 ***********************************************/
//


static NSString *kSEGMENTS_KEY = @"segments";
static NSString *kROUTEID_KEY = @"routeid";
static NSString *kNORTH_EAST_KEY = @"northEast";
static NSString *kSOUTH_WEST_KEY = @"southWest";
static NSString *kNAME_KEY = @"name";
static NSString *kSPEED_KEY = @"speed";
static NSString *kLENGTH_KEY = @"length";
static NSString *kPLAN_KEY = @"plan";
static NSString *kTIME_KEY = @"time";
static NSString *kDATE_KEY = @"date";
static NSString *kUSER_ROUTE_NAME_KEY = @"userRouteName";
static NSString *kCALORIE_KEY = @"calorie";
static NSString *kCOSAVED_KEY = @"cosaved";
static NSString *kWAYPOINTS_KEY = @"waypoints";
static NSString *POIS_KEY = @"poiArray";



//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.segments forKey:kSEGMENTS_KEY];
    [encoder encodeObject:self.routeid forKey:kROUTEID_KEY];
    [encoder encodeObject:self.northEast forKey:kNORTH_EAST_KEY];
    [encoder encodeObject:self.southWest forKey:kSOUTH_WEST_KEY];
    [encoder encodeObject:self.name forKey:kNAME_KEY];
    [encoder encodeInteger:self.speed forKey:kSPEED_KEY];
    [encoder encodeObject:self.length forKey:kLENGTH_KEY];
    [encoder encodeObject:self.plan forKey:kPLAN_KEY];
    [encoder encodeInteger:self.time forKey:kTIME_KEY];
    [encoder encodeObject:self.date forKey:kDATE_KEY];
    [encoder encodeObject:self.userRouteName forKey:kUSER_ROUTE_NAME_KEY];
    [encoder encodeObject:self.calorie forKey:kCALORIE_KEY];
    [encoder encodeObject:self.cosaved forKey:kCOSAVED_KEY];
	[encoder encodeObject:self.waypoints forKey:kWAYPOINTS_KEY];
	[encoder encodeObject:self.poiArray forKey:POIS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.segments = [decoder decodeObjectForKey:kSEGMENTS_KEY];
        self.routeid = [decoder decodeObjectForKey:kROUTEID_KEY];
        self.northEast = [decoder decodeObjectForKey:kNORTH_EAST_KEY];
        self.southWest = [decoder decodeObjectForKey:kSOUTH_WEST_KEY];
        self.name = [decoder decodeObjectForKey:kNAME_KEY];
        self.speed = [decoder decodeIntegerForKey:kSPEED_KEY];
        self.length = [decoder decodeObjectForKey:kLENGTH_KEY];
        self.plan = [decoder decodeObjectForKey:kPLAN_KEY];
        self.time = [decoder decodeIntegerForKey:kTIME_KEY];
        self.date = [decoder decodeObjectForKey:kDATE_KEY];
        self.userRouteName = [decoder decodeObjectForKey:kUSER_ROUTE_NAME_KEY];
        self.calorie = [decoder decodeObjectForKey:kCALORIE_KEY];
        self.cosaved = [decoder decodeObjectForKey:kCOSAVED_KEY];
		self.waypoints=[decoder decodeObjectForKey:kWAYPOINTS_KEY];
		self.poiArray=[decoder decodeObjectForKey:POIS_KEY];
    }
    return self;
}

@end
