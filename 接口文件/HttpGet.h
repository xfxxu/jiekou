//
//  HttpGet.h
//  jialejia
//
//  Created by lonord on 15/1/1.
//  Copyright (c) 2015年 zjitteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "userInfo.h"

#define REMOTE_HOST @"http://121.40.158.140:8000/HXLedDemo/Api/API.aspx"

//个是静态的，获取工程:
//http://121.40.158.140:8000/AppInfo/Api/API.aspx
//另外一个是动态的，工程相关：
//http://121.40.158.140:8000/HXLedDemo/Api/API.aspx

@interface HttpGet : NSObject
{
    id _tar;
    SEL _sel;
}



- (id)initWithAppendURLString:(NSString*)url arg:(NSDictionary*)dic target:(id)t selector:(SEL)s;

- (void)beginHttpRequest;


@end
