//
//  HttpGet.m
//  jialejia
//
//  Created by lonord on 15/1/1.
//  Copyright (c) 2015年 zjitteam. All rights reserved.
//

#import "HttpGet.h"


@interface HttpGet()
{
    NSURL* theURL;
    NSString* tmp;
    NSDictionary* httpArg;
    NSData* httpData;
    NSError* httpError;
}
@end

@implementation HttpGet
NSString* _sessionId;

- (id)initWithAppendURLString:(NSString*)url arg:(NSDictionary*)dic target:(id)t selector:(SEL)s{
    self=[super init];
    if(self){
        tmp=[[userInfo url] stringByAppendingString:url];
        theURL=[NSURL URLWithString:tmp];
        _tar=t;
        _sel=s;
        httpArg=dic;
//        NSLog(@"theURL:%@",theURL);
    }
    return self;
}

- (void)beginHttpRequest{
    
    //    GET
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    NSMutableURLRequest *request;
//    if(_sessionId){
//        [request setValue:_sessionId forHTTPHeaderField:@"Cookie"];
//    }
//    [request setTimeoutInterval:10.0];
//    if([httpArg count]>0){
//        [request setHTTPMethod:@"GET"];
//        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//        NSString* input=@"";
//        for(NSString* key in [httpArg allKeys]){
//            if([[httpArg objectForKey:key] length]>0){
//                NSString* t=[NSString stringWithFormat:@"%@=%@&",key,[httpArg objectForKey:key]];
//                input=[input stringByAppendingString:t];
//                //[request setValue:[httpArg objectForKey:key] forHTTPHeaderField:key];
//            }
//        }
//        if([input length]>1){
//            input=[input substringToIndex:[input length]-1];
//            tmp=[[tmp stringByAppendingString:@"?"] stringByAppendingString:input];
//            theURL=[NSURL URLWithString:tmp];
//        }
//        request = [NSMutableURLRequest requestWithURL:theURL];
//        NSLog(@"theURL:%@",theURL);
//    }
    
    
    //    POST方法
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
    if(_sessionId){
        [request setValue:_sessionId forHTTPHeaderField:@"Cookie"];
    }
    [request setTimeoutInterval:10.0];
        if([httpArg count]>0){
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            NSString* input=@"";
            for(NSString* key in [httpArg allKeys]){
                if([[httpArg objectForKey:key] length]>0){
                    NSString* t=[NSString stringWithFormat:@"%@=%@&",key,[httpArg objectForKey:key]];
                    input=[input stringByAppendingString:t];
                    //[request setValue:[httpArg objectForKey:key] forHTTPHeaderField:key];
                }
            }            if([input length]>1){
                input=[input substringToIndex:[input length]-1];
//                NSLog(input);
            }
            NSData* sendData=[input dataUsingEncoding:NSUTF8StringEncoding];
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[sendData length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:sendData];
        }
    else{
        [request setHTTPMethod:@"GET"];
    }
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSString* cookie=[[httpResponse allHeaderFields] objectForKey:@"Set-Cookie"];
                               NSString* sessionId=[cookie substringToIndex:[cookie rangeOfString:@";"].location];
                               if(sessionId){
                                   _sessionId=sessionId;
                               }
                               //NSLog(@"Response SessionId:%@",sessionId);
                               httpData=data;
                               httpError=error;
                               [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
                           }];
}

- (void)updateUI{
    NSData* data=httpData;
    NSError* error=httpError;
    if(error){
        [_tar performSelector:_sel withObject:nil];
    }
    else{
        NSError* error;
        NSString* tmp=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(tmp!=nil){
            while ([tmp rangeOfString:@"\n"].location!=NSNotFound) {
                tmp=[tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
            while ([tmp rangeOfString:@"\t"].location!=NSNotFound) {
                tmp=[tmp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            }
            data=[tmp dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* outs = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data   options: NSJSONReadingMutableContainers error:&error];
            if(error){
                NSLog(@"JSON error:%@",error);
                NSLog(@"String:%@",tmp);
            }
            [_tar performSelector:_sel withObject:outs];
        }
        else{
            [_tar performSelector:_sel withObject:nil];
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
