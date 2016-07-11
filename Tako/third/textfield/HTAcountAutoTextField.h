//
//  HTEmailAutocompleteTextField.h
//  HTTextFieldAutocompletionExample
//
//  Created by Jonathan Sibley on 2/27/13.
//  Copyright (c) 2013 Hotel Tonight. All rights reserved.
//  add xht
//

#import "HTAutocompleteTextField.h"

@interface HTAcountAutocompleteTextField : HTAutocompleteTextField <HTAutocompleteDataSource>

/*
 * A list of account domains to suggest
 */
@property (nonatomic, copy) NSArray *actDomains;

@end
