//
//  WiFi+Socket.h
//  WiFiKit
//
//  Created by ios on 12/06/2017.
//  Copyright © 2017 midmirror. All rights reserved.
//

#import "WiFi.h"
#import "Device.h"

@interface WiFi (Socket)

- (void)connectDevice:(Device *)device;
- (void)unconnectDevice;

@end
