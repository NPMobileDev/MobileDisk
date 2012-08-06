//
//  IPResolver.m
//  MobileDisk
//
//  Created by Mac-mini Nelson on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPResolver.h"
#import <ifaddrs.h>
#import <netinet/in.h>
#import <sys/socket.h>

@implementation IPResolver

#pragma mark - Resolve IP
+(void)resolveIP
{
    NSMutableDictionary *resultIP = [[NSMutableDictionary alloc] init];
    
    /**
     http://www.qnx.com/developers/docs/6.5.0/index.jsp?topic=/com.qnx.doc.neutrino_lib_ref/i/ifaddrs.html
     **/
    struct ifaddrs *addrs;
    
    //get back addrs
    BOOL success = (getifaddrs(&addrs) == 0);
    
    if(success)
    {
        const struct ifaddrs* cursor = addrs;
        
        while(cursor != NULL)
        {
            NSMutableString *ip;
            
            //check address family
            if(cursor->ifa_addr->sa_family == AF_INET)
            {
                
                const struct sockaddr_in* dlAddr = (const struct sockaddr_in*)cursor->ifa_addr;
                //get address
                const uint8_t* base = (const uint8_t*)&dlAddr->sin_addr;
                ip = [[NSMutableString alloc] init];
                
                //construct address string
                for(int i=0; i<4; i++)
                {
                    if(i!=0)
                    {
                        [ip appendString:@"."];
                    }
                    
                    [ip appendFormat:@"%d", base[i]];
                }
                
                //add to dictionary if it is wifi
                if([[NSString stringWithUTF8String:cursor->ifa_name] isEqualToString:@"en0"])
                {
                    [resultIP setObject:(NSString*)ip forKey:[NSString stringWithFormat:@"%s", cursor->ifa_name]];                    
                }

            }
            
            //change current pointer to next ifaddrs
            cursor = cursor->ifa_next;
        }
        
        //free ifaddrs
        freeifaddrs(addrs);
    }
    
    /**
     kResolveIPNotification check out MobileDisk-Prefix.pch
     **/
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kResolveIPNotification object:resultIP];
}

@end
