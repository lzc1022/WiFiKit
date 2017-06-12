//
//  WiFi+Scan.m
//  WiFiKit
//
//  Created by ios on 12/06/2017.
//  Copyright © 2017 midmirror. All rights reserved.
//

#import "WiFi+Scan.h"
#if (TARGET_IPHONE_SIMULATOR)
#import <net/if_types.h>
#import <net/route.h>
#import <netinet/if_ether.h>
#elif TARGET_OS_OSX
#import <net/if_types.h>
#import <net/route.h>
#import <netinet/if_ether.h>
#elif TARGET_OS_IPHONE
#import "if_types.h"
#import "route.h"
#import "if_ether.h"
#endif

#import <arpa/inet.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <ifaddrs.h>
#import <net/if_dl.h>
#import <net/if.h>
#import <netinet/in.h>

#import "getgateway.h"

#include <netdb.h>
#import "SimplePingHelper.h"

#import "Device.h"
#import "Router.h"

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

@implementation WiFi (Scan)

/** 更新 mac 地址 */
- (void)updateMACs
{
    size_t needed;
    char *buf, *next;
    
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_LLINFO};
    
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &needed, NULL, 0) < 0)
    {
        NSLog(@"error in route-sysctl-estimate");
        return;
    }
    
    if ((buf = (char*)malloc(needed)) == NULL)
    {
        NSLog(@"error in malloc");
        return;
    }
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), buf, &needed, NULL, 0) < 0)
    {
        NSLog(@"retrieval of routing table");
        return;
    }
    
    self.devices = [[NSMutableDictionary alloc] init];
    for (next = buf; next < buf + needed; next += rtm->rtm_msglen)
    {
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        
        u_char *cp = (u_char*)LLADDR(sdl);
        
        NSString *mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                         cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        
        if (![mac isEqualToString:@"00:00:00:00:00:00"]) {
            
            //find
            Device *device = [[Device alloc] init];
            device.ip = [NSString stringWithFormat:@"%s",inet_ntoa(sin->sin_addr)];
            device.mac = mac;
            device.router = self.router;
            
            [self.devices setObject:device forKey:device.mac];
        }
    }
    
    if ([WiFi shared].findDeviceBlock) {
        [WiFi shared].findDeviceBlock(self.devices);
    }
    
    free(buf);
}

#pragma mark - 深度扫描

- (void)scan {
    
    // 获取网关地址（即路由器地址）
    self.router = [[Router alloc] init];
    if (self.router.connected) {
        NSArray *localIPs = [self.router.localIP componentsSeparatedByString:@"."];
        NSArray *routerNetMasks = [self.router.netmask componentsSeparatedByString:@"."];
        
        self.baseAddress = nil;
        self.pingResultIndex = nil;
        
        if ([self isIpAddressValid:self.router.localIP] && (localIPs.count == 4) && (routerNetMasks.count == 4)) {
            for (int i = 0; i<localIPs.count; i++) {
                long and = [localIPs[i] integerValue] & [routerNetMasks[i] integerValue];
                
                if (i == 0) {
                    self.baseAddress = [NSString stringWithFormat:@"%ld", and];
                } else {
                    
                    if (i == 3) {
                        self.pingIndex = and; // 同网段下的起始地址
                    } else {
                        self.baseAddress = [NSString stringWithFormat:@"%@.%ld", self.baseAddress, and];
                    }
                }
            }
            if (!self.timer) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(pingAddress) userInfo:nil repeats:YES];
            }
        }
    }
}

- (BOOL)isIpAddressValid:(NSString *)ipAddress{
    struct in_addr pin;
    int success = inet_aton([ipAddress UTF8String],&pin);
    if (success == 1) return TRUE;
    return FALSE;
}

- (void)pingAddress {
    __weak typeof(self) weakSelf = self;
    weakSelf.pingIndex++;
    NSString *address = [NSString stringWithFormat:@"%@.%ld", weakSelf.baseAddress, (long)weakSelf.pingIndex];
    [SimplePingHelper ping:address target:self sel:@selector(pingResult:)];
    if (weakSelf.pingIndex>=254) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)pingResult:(NSNumber*)success {
    __weak typeof(self) weakSelf = self;
    weakSelf.pingResultIndex++;
    if (weakSelf.pingResultIndex>=254) {
        
        // 对统一网段的所有 IP 都 Ping 完成之后
        weakSelf.pingResultIndex = 0;
        [self updateMACs];
    }
}

@end
