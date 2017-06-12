//
//  PTDevice.h
//  WiFiKit
//
//  Created by midmirror on 16/9/9.
//  Copyright © 2016年 midmirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Router.h"

@interface Device: NSObject

@property(strong,nonatomic,readwrite) NSString *name;       // Device's name
@property(strong,nonatomic,readwrite) NSString *mac;        // Device's BLE or WiFi MAC address

// WiFi
@property(strong,nonatomic,readwrite) Router *router;
@property(strong,nonatomic,readwrite) NSString *ip;
@property(strong,nonatomic,readwrite) NSString *port;

@end
