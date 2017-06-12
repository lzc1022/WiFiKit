//
//  PTRouter.m
//  WiFiKit
//
//  Created by midmirror on 16/9/18.
//  Copyright © 2016年 midmirror. All rights reserved.
//

#import "Router.h"
#import "getgateway.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation Router

- (id)init {
    
    if (self = [super init]) {
        
        self.connected = NO;
        /** 获取路由器状态，获取路由器的 SSID，MAC 地址 */
        [self routerStatus];
        
        /** 必须要成功连接到路由器后，才能获取本机地址、路由器子网掩码、网关等信息 */
        if (self.connected) {
            [self routerInfo];
        }
    }
    return self;
}

- (void)routerInfo {
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    //NSString *broadcastIP,*currentDeviceIP,*netmask,*interface;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *netType = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if([netType isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    self.localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    // 当 netType 是 pdp_ip0 的时候，是蜂窝数据地址
                    
                    //routerIP----192.168.1.255 广播地址
                    //--192.168.1.106 本机地址
                    //--255.255.255.0 子网掩码地址
                    //--en0 端口地址
                    
                    self.broadcastIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    self.netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    self.interface = [NSString stringWithUTF8String:temp_addr->ifa_name];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    in_addr_t i =inet_addr([self.localIP cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x =&i;
    
    unsigned char *s = getdefaultgateway(x);
    self.gateway = [NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    
    free(s);
}

- (void)routerStatus
{
    // 获取路由器的名字
    NSArray *itf = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *name in itf) {
        
    #if TARGET_OS_IOS
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)name);
    #elif TARGET_OS_MAC
        info = [[NSDictionary alloc] init];
    #endif

        self.MAC = info[@"BSSID"];
        self.SSID = info[@"SSID"];
        self.SSIDDATA = info[@"SSIDDATA"];
        if (self.MAC) {
            self.connected = YES;
        }
    }
}

@end
