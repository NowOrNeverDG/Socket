//
//  ViewController.m
//  Client
//
//  Created by BioGo on 2016/11/3.
//  Copyright © 2016年 BioGo. All rights reserved.
//

#import "ViewController.h"
#import <arpa/inet.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <ifaddrs.h>

#define BUFFER_SIZE 1024

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"当前IP：%@",[self getIPAddress]);
    
    //创建socket：socket（协议族IPv4，socket类型TCP、UDP、协议）
    int iSocketClient = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == iSocketClient) {
        NSLog(@"创建socket失败\n");
        return;
    }
    
    //连接服务器
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr.s_addr = inet_addr("192.168.0.113");
    socketParameters.sin_port = htons(60526);
    socketParameters.sin_len = sizeof(socketParameters);
    
    //connect(socket描述符、属性结构体、结构体长度)
    int iTmp = connect(iSocketClient, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == iTmp) {
        NSLog(@"连接socket失败\n");
        close(iSocketClient);
        return;
    }

    //接受数据
    char recvbuffer[BUFFER_SIZE] = {0};
    bzero(recvbuffer, BUFFER_SIZE);
    ssize_t length = recv(iSocketClient, recvbuffer, BUFFER_SIZE,0);
    NSLog(@"从客户端接收的数据长度为：%zd",length);

    //关闭连接
    close(iSocketClient);

}

//获取IP地址的方法
- (NSString *)getIPAddress {
    NSString *address = @"getIPAddress";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
