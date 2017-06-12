//
//  WiFi+Socket.m
//  WiFiKit
//
//  Created by ios on 12/06/2017.
//  Copyright © 2017 midmirror. All rights reserved.
//

#import "WiFi+Socket.h"

@implementation WiFi (Socket)

- (void)connectDevice:(Device *)device {
    self.asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.asyncSocket connectToHost:device.ip onPort:device.port.intValue withTimeout:3 error:&error];
}

- (void)unconnectDevice {
    [self.asyncSocket disconnect];
}

//打开
- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port {
    
    if (![self.asyncSocket isConnected]) {
        [self.asyncSocket connectToHost:addr onPort:port withTimeout:-1 error:nil];
    }
    return 0;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    if ([WiFi shared].connectSuccessBlock) {
        [WiFi shared].connectSuccessBlock();
    }
    
    [sock readDataWithTimeout:-1 tag:0]; //设置为 -1 保持连接
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    if ([WiFi shared].sendSuccessBlock) {
        [WiFi shared].sendSuccessBlock();
        [WiFi shared].sendSuccessBlock = nil;
    }
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag {
    
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    
    //断开连接了
    if ([WiFi shared].unconnectBlock) {
        [WiFi shared].unconnectBlock();
    }
}

@end
