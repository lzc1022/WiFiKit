//
//  AsyncSocket.h
//  
//  This class is in the public domain.
//  Originally created by Dustin Voss on Wed Jan 29 2003.
//  Updated and maintained by Deusty Designs and the Mac development community.
//
//  http://code.google.com/p/cocoaasyncsocket/
//

#import <Foundation/Foundation.h>

@class AsyncSocket;
@class AsyncReadPacket;
@class AsyncWritePacket;

extern NSString *const AsyncSocketException;
extern NSString *const AsyncSocketErrorDomain;

typedef NS_ENUM(NSInteger, AsyncSocketError) {
	AsyncSocketCFSocketError = kCFSocketError,	// From CFSocketError enum.
	AsyncSocketNoError = 0,						// Never used.
	AsyncSocketCanceledError,					// onSocketWillConnect: returned NO.
	AsyncSocketConnectTimeoutError,
	AsyncSocketReadMaxedOutError,               // Reached set maxLength without completing
	AsyncSocketReadTimeoutError,
	AsyncSocketWriteTimeoutError
};

@protocol AsyncSocketDelegate
@optional


- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket;
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock;
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag;
- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length;
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length;
- (void)onSocketDidSecure:(AsyncSocket *)sock;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface AsyncSocket : NSObject
{
	CFSocketNativeHandle theNativeSocket4;
	CFSocketNativeHandle theNativeSocket6;
	
	CFSocketRef theSocket4;            // IPv4 accept or connect socket
	CFSocketRef theSocket6;            // IPv6 accept or connect socket
	
	CFReadStreamRef theReadStream;
	CFWriteStreamRef theWriteStream;

	CFRunLoopSourceRef theSource4;     // For theSocket4
	CFRunLoopSourceRef theSource6;     // For theSocket6
	CFRunLoopRef theRunLoop;
	CFSocketContext theContext;
	NSArray *theRunLoopModes;
	
	NSTimer *theConnectTimer;

	NSMutableArray *theReadQueue;
	AsyncReadPacket *theCurrentRead;
	NSTimer *theReadTimer;
	NSMutableData *partialReadBuffer;
	
	NSMutableArray *theWriteQueue;
	AsyncReadPacket *theCurrentWrite;
	NSTimer *theWriteTimer;

	id theDelegate;
	UInt16 theFlags;
	
	long theUserData;
}

- (id)init;
- (id)initWithDelegate:(id)delegate;
- (id)initWithDelegate:(id)delegate userData:(long)userData;

- (NSString *)description;
- (id)delegate;
- (BOOL)canSafelySetDelegate;
- (void)setDelegate:(id)delegate;

- (long)userData;
- (void)setUserData:(long)userData;

- (CFSocketRef)getCFSocket;
- (CFReadStreamRef)getCFReadStream;
- (CFWriteStreamRef)getCFWriteStream;

- (BOOL)acceptOnPort:(UInt16)port error:(NSError **)errPtr;
- (BOOL)acceptOnInterface:(NSString *)interface port:(UInt16)port error:(NSError **)errPtr;
- (BOOL)connectToHost:(NSString *)hostname onPort:(UInt16)port error:(NSError **)errPtr;
- (BOOL)connectToHost:(NSString *)hostname
			   onPort:(UInt16)port
		  withTimeout:(NSTimeInterval)timeout
				error:(NSError **)errPtr;

- (BOOL)connectToAddress:(NSData *)remoteAddr error:(NSError **)errPtr;
- (BOOL)connectToAddress:(NSData *)remoteAddr withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;

- (BOOL)connectToAddress:(NSData *)remoteAddr
     viaInterfaceAddress:(NSData *)interfaceAddr
             withTimeout:(NSTimeInterval)timeout
                   error:(NSError **)errPtr;

- (void)disconnect;
- (void)disconnectAfterReading;
- (void)disconnectAfterWriting;
- (void)disconnectAfterReadingAndWriting;
- (BOOL)isConnected;

- (NSString *)connectedHost;
- (UInt16)connectedPort;

- (NSString *)localHost;
- (UInt16)localPort;

- (NSData *)connectedAddress;
- (NSData *)localAddress;

- (BOOL)isIPv4;
- (BOOL)isIPv6;

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataWithTimeout:(NSTimeInterval)timeout
					 buffer:(NSMutableData *)buffer
			   bufferOffset:(NSUInteger)offset
						tag:(long)tag;

- (void)readDataWithTimeout:(NSTimeInterval)timeout
                     buffer:(NSMutableData *)buffer
               bufferOffset:(NSUInteger)offset
                  maxLength:(NSUInteger)length
                        tag:(long)tag;

- (void)readDataToLength:(NSUInteger)length withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataToLength:(NSUInteger)length
             withTimeout:(NSTimeInterval)timeout
                  buffer:(NSMutableData *)buffer
            bufferOffset:(NSUInteger)offset
                     tag:(long)tag;

- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataToData:(NSData *)data
           withTimeout:(NSTimeInterval)timeout
                buffer:(NSMutableData *)buffer
          bufferOffset:(NSUInteger)offset
                   tag:(long)tag;

- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout maxLength:(NSUInteger)length tag:(long)tag;

- (void)readDataToData:(NSData *)data
           withTimeout:(NSTimeInterval)timeout
                buffer:(NSMutableData *)buffer
          bufferOffset:(NSUInteger)offset
             maxLength:(NSUInteger)length
                   tag:(long)tag;

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (float)progressOfReadReturningTag:(long *)tag bytesDone:(NSUInteger *)done total:(NSUInteger *)total;
- (float)progressOfWriteReturningTag:(long *)tag bytesDone:(NSUInteger *)done total:(NSUInteger *)total;

- (void)startTLS:(NSDictionary *)tlsSettings;

- (void)enablePreBuffering;

- (BOOL)moveToRunLoop:(NSRunLoop *)runLoop;

- (BOOL)setRunLoopModes:(NSArray *)runLoopModes;
- (BOOL)addRunLoopMode:(NSString *)runLoopMode;
- (BOOL)removeRunLoopMode:(NSString *)runLoopMode;

- (NSArray *)runLoopModes;


- (NSData *)unreadData;

/* A few common line separators, for use with the readDataToData:... methods. */
+ (NSData *)CRLFData;   // 0x0D0A
+ (NSData *)CRData;     // 0x0D
+ (NSData *)LFData;     // 0x0A
+ (NSData *)ZeroData;   // 0x00

@end
