//
//  Created by midmirror on 16/2/23.
//  Copyright © 2016年 midmirror. All rights reserved.
//

#import "WiFi.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#include <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>
#import "getgateway.h"
#import <arpa/inet.h>
#import <net/if.h>
#import "WiFi+Socket.h"

#define CTL_NET         4               /* network, see socket.h */

@interface WiFi()

@end

@implementation WiFi

static WiFi *instance = nil;
+ (WiFi *)shared
{
    if (instance == nil) {
        instance = [[WiFi alloc] init];
    }
    return instance;
}

- (void)sendData:(NSData *)data {
    [_asyncSocket writeData:data withTimeout:-1 tag:0];
}

- (void)whenFindDevice:(ScanDeviceBlock)findDeviceBlock; {
    
    self.findDeviceBlock = findDeviceBlock;
}

- (void)whenUnconnect:(UnconnectBlock)unconnectBlock {
    self.unconnectBlock = unconnectBlock;
}

- (void)whenConnectSuccess:(ConnectSuccessBlock)connectSuccessBlock {
    self.connectSuccessBlock = connectSuccessBlock;
}

- (void)whenConnectFailure:(ConnectFailureBlock)connectFailureBlock {
    self.connectFailureBlock = connectFailureBlock;
}

- (void)whenSendSuccess:(SendSuccessBlock)sendSuccessBlock {
    self.sendSuccessBlock = sendSuccessBlock;
}

- (void)whenSendFailure:(SendFailureBlock)sendFailureBlock {
    self.sendFailureBlock = sendFailureBlock;
}

- (void)whenSendProgressUpdate:(SendProgressBlock)sendProgressBlock {
    self.sendProgressBlock = sendProgressBlock;
}

- (void)whenReceiveData:(ReceiveDataBlock)receiveDataBlock {
    self.receiveDataBlock = receiveDataBlock;
}

@end
