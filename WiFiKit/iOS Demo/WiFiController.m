//
//  PTConnectVC.m
//  WiFiKit
//
//  Created by midmirror on 16/2/24.
//  Copyright © 2016年 midmirror. All rights reserved.
//

#import "WiFiController.h"
#import <WiFiKit/WiFiKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface WiFiController()

@property(strong,nonatomic,readwrite) UITableView *tableView;
@property(strong,nonatomic,readwrite) NSArray *devices;
@property(strong,nonatomic,readwrite) Router *router;

@end

@implementation WiFiController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WiFi Demo";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStyleDone target:self action:@selector(scanWiFiPrinter)];
    self.navigationItem.rightBarButtonItem = scanItem;
}

- (void)closeView {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.  ·
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"connectCell";
    UITableViewCell *tableCell;
    
    tableCell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    }
    
    tableCell.textLabel.text = @"";
    tableCell.detailTextLabel.text = @"";
    tableCell.imageView.image = nil;
    tableCell.accessoryView = nil;

    if (self.router.connected) {
        
        Device *device = self.devices[indexPath.row];
        
        if ([device.ip isEqualToString:self.router.localIP]) { // 如果搜索到的 IP 是本机（iOS） IP
            NSString *thisDevice = [[NSString alloc] initWithFormat:@"%@",[[UIDevice currentDevice] name]];
            tableCell.textLabel.text = thisDevice;
        }
        tableCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",device.mac, device.ip];
    }
    
    return tableCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//取消选中 cell
    
    Device *device = self.devices[indexPath.row];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                   message:[NSString stringWithFormat:@"Connect: %@  Port:9100",device.ip]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [WiFi shared].deviceConnected.name = [[NSString alloc] initWithFormat:@"%@",device.ip];
        
        device.port = @"9100";
        if ([WiFi shared].deviceConnected) {
            [[WiFi shared] unconnectDevice];
        }
        [[WiFi shared] connectDevice:device];
        [[WiFi shared] whenConnectSuccess:^{
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [[WiFi shared] whenConnectFailure:^{
            
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma -mark wifi scan delegate

- (void)scanWiFiPrinter {
    
    [[WiFi shared] scan];
    [[WiFi shared] whenFindDevice:^(NSDictionary *deviceDict) {
        self.devices = deviceDict.allValues;
        [self.tableView reloadData];
    }];
}

@end
