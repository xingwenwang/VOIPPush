//
//  AppDelegate.m
//  VoipDemo
//
//  Created by kevin on 2023/1/19.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor =[UIColor purpleColor];
    
    ViewController *viewControll = [ViewController new];
    self.window.rootViewController = viewControll;
    
    return YES;
}



@end
