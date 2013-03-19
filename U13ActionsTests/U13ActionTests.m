//
//  U13ActionTests.m
//  U13ActionsTests
//
//  Created by Brane on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

#import "U13ActionTests.h"

#import "U13ActionLog.h"

@implementation U13ActionTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in U13ActionsTests");
}


void testLog() {
    LOG_SET_DEBUG_BREAK_ENABLED( NO );
    LOG_E(@"FMDB_LOG_E");
    LOG_EF(@"%@", @"FMDB_LOG_EF");
    LOG_W(@"FMDB_LOG_W");
    LOG_WF(@"%@", @"FMDB_LOG_WF");
    LOG_I(@"FMDB_LOG_I");
    LOG_IF(@"%@", @"FMDB_LOG_IF");
    LOG_D(@"FMDB_LOG_D");
    LOG_DF(@"%@", @"FMDB_LOG_DF");
    LOG_V(@"FMDB_LOG_V");
    LOG_VF(@"%@", @"FMDB_LOG_VF");
    LOG_A(NO, @"FMDB_LOG_A");
    LOG_AF(NO, @"%@", @"FMDB_LOG_AF");
    LOG_SET_DEBUG_BREAK_ENABLED( YES );
}

@end
