//
//  ApigeeMonitoringOptions.m
//  ApigeeiOSSDK
//
//  Copyright (c) 2013 Apigee. All rights reserved.
//

#import "ApigeeMonitoringOptions.h"

@implementation ApigeeMonitoringOptions

@synthesize monitoringEnabled;
@synthesize crashReportingEnabled;
@synthesize interceptNetworkCalls;
@synthesize uploadListener;

- (id)init
{
    self = [super init];
    if( self )
    {
        self.monitoringEnabled = YES;
        self.crashReportingEnabled = YES;
        self.interceptNetworkCalls = YES;
        self.uploadListener = nil;
    }
    
    return self;
}

@end
