//
//  NSURL+CDKNetwork.m
//  CDKLibrary
//
//  Created by Mike Neill on 8/19/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import "NSURL+CDKNetwork.h"
#import "CDKNetworkParameter.h"

@implementation NSURL (NSURL_CDKNetwork)

- (NSURL *)URLByAppendingParameters:(NSArray *)parameters
{
    NSMutableString *mUrlStr = [[NSMutableString alloc] initWithString:self.absoluteString];
    
    // append parameters if any exist
    for (CDKNetworkParameter *p in parameters)
    {
        if (p.key != nil && p.value != nil)
        {
            if (![mUrlStr containsString:@"?"])
                [mUrlStr appendString:@"?"];
            else
                [mUrlStr appendString:@"&"];
            
            [mUrlStr appendFormat:@"%@=%@", p.key, [p.value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return [[NSURL alloc] initWithString:mUrlStr];
}

@end
