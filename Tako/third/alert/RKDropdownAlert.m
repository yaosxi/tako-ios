//
//  RKDropdownAlert.m
//  SlingshotDropdownAlert
//
//  Created by Richard Kim on 8/26/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  objective-c objc obj c

#import "RKDropdownAlert.h"

NSString *const RKDropdownAlertDismissAllNotification = @"RKDropdownAlertDismissAllNotification";

//%%% CUSTOMIZE FOR DEFAULT SETTINGS
// These values specify what the view will look like
static int HEIGHT = 40; //height of the alert view
static float ANIMATION_TIME = .4; //time it takes for the animation to complete in seconds
static int X_BUFFER = 10; //buffer distance on each side for the text
static int Y_BUFFER = 60; //buffer distance on top/bottom for the text
static int TIME = 3; //default time in seconds before the view is hidden
static int STATUS_BAR_HEIGHT = 5;
static int FONT_SIZE = 13;

static int CORNER_RADIUS = 5;// add xht
static int X_SPACE = 20;// add xht
NSString *DEFAULT_TITLE;

@implementation RKDropdownAlert{
    UILabel *titleLabel;
    UILabel *messageLabel;
}
@synthesize defaultTextColor;
@synthesize defaultViewColor;

#pragma mark CUSTOMIZABLE

//%%% CUSTOMIZE DEFAULT VALUES
// These are the default value. For example, if you don't specify a color, then
// your default color will be used (which is currently orange)
-(void)setupDefaultAttributes
{
//    defaultViewColor = [UIColor colorWithRed:(float)70/255 green:(float)130/255 blue:(float)180/255 alpha:0.8];//%%% default color from slingshot
//    defaultViewColor = [UIColor blackColor];
    
    defaultViewColor = [UIColor colorWithRed:(float)0/255 green:(float)0/255 blue:(float)0/255 alpha:0.75];// modify xht


    defaultTextColor = [UIColor whiteColor];
//    defaultTextColor = [UIColor blackColor];
    DEFAULT_TITLE = @"提示"; //%%% this text can only be edited if you do not use the pod solution. check the repo's README for more information
    
    //%%% to change the default time, height, animation speed, fonts, etc check the top of the this file
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultAttributes];
        
        self.layer.cornerRadius = CORNER_RADIUS; // add by xht
        
        self.backgroundColor = defaultViewColor;
        
        //%%% title setup (the bolded text at the top of the view)
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(X_BUFFER, STATUS_BAR_HEIGHT, frame.size.width-2*X_BUFFER, 30)];
        [titleLabel setFont:[UIFont fontWithName:@"Arial" size:FONT_SIZE]];
        titleLabel.textColor = defaultTextColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        //%%% message setup (the regular text below the title)
        messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(X_BUFFER, STATUS_BAR_HEIGHT +Y_BUFFER*2.3, frame.size.width-2*X_BUFFER, 35)];
        messageLabel.textColor = defaultTextColor;
        messageLabel.font = [messageLabel.font fontWithSize:FONT_SIZE];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.numberOfLines = 2; // 2 lines ; 0 - dynamic number of lines
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:messageLabel];
        
        [self addTarget:self action:@selector(hideView:) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismissAlertView)
                                                     name:RKDropdownAlertDismissAllNotification
                                                   object:nil];
        self.isShowing = NO;

    }
    return self;
}

- (void)dismissAlertView {
    [self hideView:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RKDropdownAlertDismissAllNotification
                                                  object:nil];
}

//%%% button method (what happens when you touch the drop down view)
-(void)viewWasTapped:(UIButton *)alertView
{
    if (self.delegate) {
        if ([self.delegate dropdownAlertWasTapped:self]) {
            [self hideView:alertView];
        }
    } else {
        [self hideView:alertView];
    }
}

-(void)hideView:(UIButton *)alertView
{
    if (alertView) {
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            
        int y = -HEIGHT;
            if (self.isFromBottom) {
                y = [[UIScreen mainScreen]bounds].size.height+HEIGHT;
            }
            CGRect frame = alertView.frame;
            frame.origin.y = y;
            alertView.frame = frame;
        }];
        [self performSelector:@selector(removeView:) withObject:alertView afterDelay:ANIMATION_TIME];
    }
}

-(void)removeView:(UIButton *)alertView
{
    if (alertView){
        [alertView removeFromSuperview];
        self.isShowing = NO;
        if (self.delegate){
            [self.delegate dropdownAlertWasDismissed];
        }
    }
}



#pragma mark IGNORE THESE

//%%% these are necessary methods that call each other depending on which method you call. Generally shouldn't edit these unless you know what you're doing

// add xht , tip from bottom


+(void)title:(NSString*)title message:(NSString*)message time:(NSInteger)seconds isFromBottom:(BOOL)flag{
    [[self alertViewWithOption:flag] title:title message:message backgroundColor:nil textColor:nil time:seconds];
}

+(RKDropdownAlert*)alertViewWithOption:(BOOL)isBottom {
    int y = -HEIGHT;
    if (isBottom) {
        y = [[UIScreen mainScreen]bounds].size.height+HEIGHT;
    }
    RKDropdownAlert *alert = [[self alloc]initWithFrame:CGRectMake(X_SPACE, y, [[UIScreen mainScreen]bounds].size.width-X_SPACE*2, HEIGHT)];
    alert.isFromBottom=isBottom;
    return alert;
}

+(RKDropdownAlert*)alertView {
    int y = -HEIGHT;
    RKDropdownAlert *alert = [[self alloc]initWithFrame:CGRectMake(X_SPACE, y, [[UIScreen mainScreen]bounds].size.width-X_SPACE*2, HEIGHT)];
    return alert;
}

+(RKDropdownAlert*)alertViewWithDelegate:(id<RKDropdownAlertDelegate>)delegate
{
    RKDropdownAlert *alert = [[self alloc]initWithFrame:CGRectMake(0, -HEIGHT, [[UIScreen mainScreen]bounds].size.width, HEIGHT)];
    alert.delegate = delegate;
    return alert;
}

//%%% shows all the default stuff
+(void)show
{
    [[self alertView]title:DEFAULT_TITLE message:nil backgroundColor:nil textColor:nil time:-1];
}

+(void)title:(NSString*)title
{
    [[self alertView]title:title message:nil backgroundColor:nil textColor:nil time:-1];
}

+(void)title:(NSString*)title time:(NSInteger)seconds
{
    [[self alertView]title:title message:nil backgroundColor:nil textColor:nil time:seconds];
}

+(void)title:(NSString*)title backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor
{
    [[self alertView]title:title message:nil backgroundColor:backgroundColor textColor:textColor time:-1];
}

+(void)title:(NSString*)title backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor time:(NSInteger)seconds
{
    [[self alertView]title:title message:nil backgroundColor:backgroundColor textColor:textColor time:seconds];
}

+(void)title:(NSString*)title message:(NSString*)message
{
    [[self alertView]title:title message:message backgroundColor:nil textColor:nil time:-1];
}

+(void)title:(NSString*)title message:(NSString*)message time:(NSInteger)seconds
{
    [[self alertView]title:title message:message backgroundColor:nil textColor:nil time:seconds];
}

+(void)title:(NSString*)title message:(NSString*)message backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor
{
    [[self alertView]title:title message:message backgroundColor:backgroundColor textColor:textColor time:-1];
}

+(void)title:(NSString*)title message:(NSString*)message backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor time:(NSInteger)seconds
{
    [[self alertView]title:title message:message backgroundColor:backgroundColor textColor:textColor time:seconds];
}



+(void)showWithDelegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:DEFAULT_TITLE message:nil backgroundColor:nil textColor:nil time:-1];
}

+(void)title:(NSString*)title delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:nil backgroundColor:nil textColor:nil time:-1];
}

+(void)title:(NSString*)title time:(NSInteger)seconds delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:nil backgroundColor:nil textColor:nil time:seconds];
}

+(void)title:(NSString*)title backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:nil backgroundColor:backgroundColor textColor:textColor time:-1];
}

+(void)title:(NSString*)title backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor time:(NSInteger)seconds delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:nil backgroundColor:backgroundColor textColor:textColor time:seconds];
}

+(void)title:(NSString*)title message:(NSString*)message delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:message backgroundColor:nil textColor:nil time:-1];
}

+(void)title:(NSString*)title message:(NSString*)message time:(NSInteger)seconds delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:message backgroundColor:nil textColor:nil time:seconds];
}

+(void)title:(NSString*)title message:(NSString*)message backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:message backgroundColor:backgroundColor textColor:textColor time:-1];
}

+(void)title:(NSString*)title message:(NSString*)message backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor time:(NSInteger)seconds delegate:(id<RKDropdownAlertDelegate>)delegate
{
    [[self alertViewWithDelegate:delegate]title:title message:message backgroundColor:backgroundColor textColor:textColor time:seconds];
}

+(void)dismissAllAlert{
    [[NSNotificationCenter defaultCenter] postNotificationName:RKDropdownAlertDismissAllNotification object:nil];
}

-(void)title:(NSString*)title message:(NSString*)message backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor time:(NSInteger)seconds
{
    NSInteger time = seconds;
    titleLabel.text = title;
    
    if (message && message.length > 0) {
        messageLabel.text = message;
        if ([self messageTextIsOneLine]) {
            CGRect frame = titleLabel.frame;
            frame.origin.y = STATUS_BAR_HEIGHT;// add xht
            titleLabel.frame = frame;
        }
    } else {
        CGRect frame = titleLabel.frame;
        frame.size.height = HEIGHT-2*Y_BUFFER-STATUS_BAR_HEIGHT;
        frame.origin.y = Y_BUFFER+STATUS_BAR_HEIGHT;// add xht
        titleLabel.frame = frame;
    }
    
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    if (textColor) {
        titleLabel.textColor = textColor;
        messageLabel.textColor = textColor;
    }
    
    if (seconds == -1) {
        time = TIME;
    }
    
    if(!self.superview){
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows)
            if (window.windowLevel == UIWindowLevelNormal && !window.hidden) {
                [window addSubview:self];
                break;
            }
    }
    
    self.isShowing = YES;

    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        CGRect frame = self.frame;
        int y = 0;
        if (self.isFromBottom) {
            y = [UIScreen mainScreen].bounds.size.height - HEIGHT - Y_BUFFER;
        }
        frame.origin.y = y;
        self.frame = frame;
    }];
    
    [self performSelector:@selector(viewWasTapped:) withObject:self afterDelay:time+ANIMATION_TIME];
}




-(BOOL)messageTextIsOneLine
{
    CGSize size = [messageLabel.text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:FONT_SIZE]}];
    if (size.width > messageLabel.frame.size.width) {
        return NO;
    }
    
    return YES;
}

@end
