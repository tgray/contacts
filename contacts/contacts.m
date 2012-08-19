//
//  main.m
//  contacts
//
//  Created by Tim Gray on 8/18/12.
//  Copyright (c) 2012 Tim Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        // set up some variables
        NSEnumerator *addressEnum;
        ABPerson *person;
        int i;
        NSString *muttQueryStr = @"";
        NSString *theArg;

        
        // get cli arguments
        NSProcessInfo *proc = [NSProcessInfo processInfo];
        NSArray *allArgs = [[NSProcessInfo processInfo] arguments];
        NSMutableArray *args;
        NSString *usageStr = [NSString stringWithFormat:@"Usage: %s <options> search_term\n", [[proc processName] UTF8String]];
        NSBundle *bundle = [NSBundle mainBundle];
        id versionNum = [bundle objectForInfoDictionaryKey: (NSString*) @"CFBundleShortVersionString"];
        id buildNum = [bundle objectForInfoDictionaryKey: (NSString*) kCFBundleVersionKey];
        NSString *versionStr = [NSString stringWithFormat:@"%s %@ (%@)\n", [[proc processName] UTF8String], versionNum, buildNum];
        
        // set up some arguments stuff
        args = [[NSMutableArray alloc] initWithCapacity: 2];
        [args setArray: allArgs];
        NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
        
        NSArray *helpArg = [NSArray arrayWithObjects: @"--help", @"--h", @"-h",
                @"-help", nil];
        NSArray *versionArg = [NSArray arrayWithObjects: @"--version", @"-v",
                              nil];
        NSArray *formatArg = [NSArray arrayWithObjects: @"--format", @"-f",
                nil];
        
        // not enough arguments to continue
        if ([args count] <= 1) {
            printf("%s", [usageStr UTF8String]);
            return 1;
        }

        // process the cli arguments
        for (i = 1; i < [args count]; i++ ) {
            theArg = [[NSString alloc] initWithString: [args objectAtIndex: i]];

            if ([theArg hasPrefix: @"-"] == YES) {
                // help
                if ([helpArg containsObject: theArg] == YES) {
                    printf("%s", [usageStr UTF8String]);
                    return 0;
                }
                // version
                else if ([versionArg containsObject: theArg] == YES) {
                    printf("%s", [versionStr UTF8String]);
                    return 0;
                }
                // format
                else if ([formatArg containsObject: theArg] == YES) {
                    [indexesToRemove addIndex: i];
                }
            }
        }
        [args removeObjectsAtIndexes: indexesToRemove];

        // process the search term argument
        if ([args count] > 1) {
            for (i = 1; i < [args count]; i++) {
                theArg = [NSString stringWithString: [args objectAtIndex: i]];
            }
        } 
        
        // get our address book
        ABAddressBook *AB = [ABAddressBook sharedAddressBook];

        ABSearchElement *firstNameSearch =
        [ABPerson searchElementForProperty:kABFirstNameProperty
                                     label:nil
                                       key:nil
                                     value:theArg
                                comparison:kABContainsSubStringCaseInsensitive];

        ABSearchElement *lastNameSearch =
        [ABPerson searchElementForProperty:kABLastNameProperty
                                     label:nil
                                       key:nil
                                     value:theArg
                                comparison:kABContainsSubStringCaseInsensitive];

        ABSearchElement *nicknameSearch =
        [ABPerson searchElementForProperty:kABNicknameProperty
                                     label:nil
                                       key:nil
                                     value:theArg
                                comparison:kABContainsSubStringCaseInsensitive];

        ABSearchElement *emailSearch =
        [ABPerson searchElementForProperty:kABEmailProperty
                                     label:nil
                                       key:nil
                                     value:theArg
                                comparison:kABContainsSubStringCaseInsensitive];
        ABSearchElement *multiSearch = [ABSearchElement searchElementForConjunction:kABSearchOr children: [NSArray arrayWithObjects:firstNameSearch, lastNameSearch, nicknameSearch, emailSearch, nil]];
        
        NSArray *peopleFound = [AB recordsMatchingSearchElement:multiSearch];
        addressEnum = [peopleFound objectEnumerator];
        
        while (person = (ABPerson*)[addressEnum nextObject]) {
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                  [[person valueForProperty:kABFirstNameProperty] description],
                  [[person valueForProperty:kABLastNameProperty] description]];
            ABMultiValue *emails = [person valueForProperty: kABEmailProperty];
            int emailCount = (int)[emails count];
            BOOL nameMatch = ([fullName rangeOfString:theArg options:NSCaseInsensitiveSearch].location != NSNotFound);
            BOOL nickMatch = ([[person valueForProperty:kABNicknameProperty] rangeOfString:theArg options:NSCaseInsensitiveSearch].location != NSNotFound);
            if (nameMatch || nickMatch) {
                for (i = 0; i < emailCount; i++ ) {
                    NSString *thisEmail = [emails valueAtIndex: i];
                    printf("%s\t%s%s\n", [thisEmail UTF8String], [fullName UTF8String], [muttQueryStr UTF8String]);}
            } else {
                for (i = 0; i < emailCount; i++ ) {
                    NSString *thisEmail = [emails valueAtIndex: i];
                    BOOL emailMatch = ([thisEmail rangeOfString:theArg options:NSCaseInsensitiveSearch].location != NSNotFound);
                    if (emailMatch) {
                        printf("%s\t%s%s\n", [thisEmail UTF8String], [fullName UTF8String], [muttQueryStr UTF8String]);
                    }
                }
            }
        }
        
    }
    return 0;
}


