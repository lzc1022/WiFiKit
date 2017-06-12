//
//  Created by midmirror on 16/2/23.
//  Copyright © 2016年 midmirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "Device.h"


/** 发现新蓝牙 */
typedef void(^ScanDeviceBlock)(NSDictionary *deviceDict);

/** 连接成功、失败 */
typedef void(^ConnectSuccessBlock)();
typedef void(^ConnectFailureBlock)();

/** 可以发送、发送成功、发送失败、接收到返回值 */
typedef void(^SendSuccessBlock)();
typedef void(^SendFailureBlock)();
typedef void(^SendProgressBlock)(NSNumber *progress);
typedef void(^ReceiveDataBlock)(NSData *data);

/** 断开 */
typedef void(^UnconnectBlock)();

/**
 *  功能：用于和打印机的 WiFi 建立连接实现通讯。使用了 AsyncSocket 第三方框架。
 */
@interface WiFi : NSObject<AsyncSocketDelegate>

+ (WiFi *)shared;

@property(copy,nonatomic,readwrite) SendSuccessBlock     sendSuccessBlock;        //发送结束时的 Block
@property(copy,nonatomic,readwrite) SendFailureBlock     sendFailureBlock;
@property(copy,nonatomic,readwrite) SendProgressBlock    sendProgressBlock;
@property(copy,nonatomic,readwrite) ReceiveDataBlock     receiveDataBlock;
@property(copy,nonatomic,readwrite) ScanDeviceBlock      findDeviceBlock;
@property(copy,nonatomic,readwrite) ConnectSuccessBlock  connectSuccessBlock;
@property(copy,nonatomic,readwrite) ConnectFailureBlock  connectFailureBlock;
@property(copy,nonatomic,readwrite) UnconnectBlock       unconnectBlock;

@property(strong,nonatomic,readwrite) AsyncSocket *asyncSocket;

@property NSString *baseAddress;
@property NSInteger pingIndex;
@property NSTimer *timer;
@property NSInteger pingResultIndex;
@property(strong,nonatomic,readwrite) NSMutableDictionary *devices;
@property(strong,nonatomic,readwrite) Device *deviceConnected;
@property(strong,nonatomic,readwrite) Router *router;

- (void)sendData:(NSData *)data;

- (void)whenFindDevice:(ScanDeviceBlock)findDeviceBlock;

/** 当连接成功时 */
- (void)whenConnectSuccess:(ConnectSuccessBlock)connectSuccessBlock;

/** 当连接失败时 */
- (void)whenConnectFailure:(ConnectFailureBlock)connectFailureBlock;

/** 当断开连接时 */
- (void)whenUnconnect:(UnconnectBlock)unconnectBlock;

/** 发送数据 */
- (void)whenSendSuccess:(SendSuccessBlock)sendSuccessBlock; // 成功
- (void)whenSendFailure:(SendFailureBlock)sendFailureBlock; // 失败
- (void)whenSendProgressUpdate:(SendProgressBlock)sendProgressBlock;    // 发送进度
- (void)whenReceiveData:(ReceiveDataBlock)receiveDataBlock;

@end
