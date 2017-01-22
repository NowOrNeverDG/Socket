//
//  ViewController.m
//  SocketServer
//
//  Created by 丁戈 on 2017/1/22.
//  Copyright © 2017年 BTeam. All rights reserved.
//

#import "ViewController.h"
#include <arpa/inet.h>
#import <ifaddrs.h>
#include <sys/event.h>
#include <sys/socket.h>
#import  <AVFoundation/AVFoundation.h>
#define LENGTH_OF_LISTEN_QUEUE 20
#define BUFFER_SIZE 1024

@implementation ViewController
{
    int _iSocketServer;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //创建Socket
    _iSocketServer = socket(AF_INET, SOCK_STREAM, 0);
    if (_iSocketServer < 0) {
        printf("创建socket失败\n");
        return;
    }
    
    //绑定Socket
    struct sockaddr_in serverAddr;
    bzero(&serverAddr,sizeof(serverAddr)); //把一段内存区的内容全部设置为0
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_len = sizeof(serverAddr);
    serverAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    serverAddr.sin_port = htons(60526);
    int opt =bind(_iSocketServer,(struct sockaddr*)&serverAddr,sizeof(serverAddr));
    if (opt < 0) {
        printf("服务器绑定失败\n");
        return;
    }
    NSLog(@"服务器绑定成功\n");
    
    //服务器端开始监听
    if (listen(_iSocketServer, LENGTH_OF_LISTEN_QUEUE) == -1) {
        printf("服务器监听失败\n");
        close(_iSocketServer);
        return;
    }

    //定义客户端的socket地址结构client_addr
    struct sockaddr_in clientAddr;
    socklen_t iLength = sizeof(clientAddr);

    int clientSocket = 0;
    
    while (1) {//服务器端要一直运行
    /*接受一个到server_socket代表的socket的一个连接
     如果没有连接请求,就等待到有连接请求--这是accept函数的特性
     accept函数返回一个新的socket,这个socket(new_server_socket)用于同连接到的客户的通信
     newServerSocket代表了服务器和客户端之间的一个通信通道
     accept函数把连接到的客户端信息填写到客户端的socket地址结构client_addr中*/
        printf("服务器准备接收!\n");
        clientSocket = accept(_iSocketServer,(struct sockaddr*)&clientAddr,&iLength);
        if (clientSocket < 0) {
            printf("服务器接受失败\n");
            close(_iSocketServer);
            break;
        }
        printf("服务器完成接收!\n");
            
        while(1) {
            //接收数据
            char recvbuffer[BUFFER_SIZE];
            bzero(recvbuffer, BUFFER_SIZE);
            ssize_t length = recv(clientSocket,recvbuffer,BUFFER_SIZE,0);
            NSLog(@"从客户端接收的数据长度为：%zd",length);//接受的长度
        }
    }
}

-(void)viewWillDisappear {
    [super viewWillDisappear];
    
    close(_iSocketServer);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
