//
//  HTEmailAutocompleteTextField.m
//  HTTextFieldAutocompletionExample
//
//  Created by Jonathan Sibley on 2/27/13.
//  Copyright (c) 2013 Hotel Tonight. All rights reserved.
//  add xht
//

#import "HTAcountAutoTextField.h"
#import "UIHelper.h"

@implementation HTAcountAutocompleteTextField

- (void)setupAutocompleteTextField
{
    [super setupAutocompleteTextField];
    
    self.actDomains=[XHTUIHelper loadAllUsers];
    self.autocompleteDataSource = self;
}

#pragma mark - HTAutocompleteDataSource

- (NSString *)textField:(HTAutocompleteTextField *)textField completionForPrefix:(NSString *)prefix ignoreCase:(BOOL)ignoreCase
{
    
    // 先检查是否输入到@字符，若是，则只返回邮箱地址。
    NSString* result = [self emailCheck:prefix ignoreCase:YES];
    if (![result isEqualToString:@""]) {
        return result;
    }
    
    // 若没有输入到@字符，进入全字符匹配阶段。
    NSString *stringToLookFor;
    NSArray *componentsString = [prefix componentsSeparatedByString:@","];
    NSString *prefixLastComponent = [componentsString.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (ignoreCase)
    {
        stringToLookFor = [prefixLastComponent lowercaseString];
    }
    else
    {
        stringToLookFor = prefixLastComponent;
    }
    
    for (NSString *stringFromReference in self.actDomains)
    {
        NSString *stringToCompare;
        if (ignoreCase)
        {
            stringToCompare = [stringFromReference lowercaseString];
        }
        else
        {
            stringToCompare = stringFromReference;
        }
        
        if ([stringToCompare hasPrefix:stringToLookFor])
        {
            return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
        }
        
    }
    
    return @"";
}

-(NSString*)emailCheck:(NSString*)prefix ignoreCase:(BOOL)ignoreCase{
    
     NSArray *  autocompleteArray = @[ @"qq.com",@"163.com", @"126.com", @"139.com",@"kingsoft.com",@"gmail.com", @"hotmail.com"];
    
    // Check that text field contains an @
    NSRange atSignRange = [prefix rangeOfString:@"@"];
    if (atSignRange.location == NSNotFound)
    {
        return @"";
    }
    
//    // Stop autocomplete if user types dot after domain
//    NSString *domainAndTLD = [prefix substringFromIndex:atSignRange.location];
//    NSRange rangeOfDot = [domainAndTLD rangeOfString:@"."];
//    if (rangeOfDot.location != NSNotFound)
//    {
//        return @"";
//    }
    
    // Check that there aren't two @-signs
    NSArray *textComponents = [prefix componentsSeparatedByString:@"@"];
    if ([textComponents count] > 2)
    {
        return @"";
    }
    
    if ([textComponents count] > 1)
    {
        // If no domain is entered, use the first domain in the list
        if ([(NSString *)textComponents[1] length] == 0)
        {
            return [autocompleteArray objectAtIndex:0];
        }
        
        NSString *textAfterAtSign = textComponents[1];
        
        NSString *stringToLookFor;
        if (ignoreCase)
        {
            stringToLookFor = [textAfterAtSign lowercaseString];
        }
        else
        {
            stringToLookFor = textAfterAtSign;
        }
        
        for (NSString *stringFromReference in autocompleteArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    return @"";
}
@end
