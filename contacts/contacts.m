//
//  main.m
//  contacts
//
//  Created by Tim Gray on 8/18/12.
//  Copyright (c) 2012 Tim Gray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

NSString *slugName(NSString *fullName, int emailCount) {
    // don't really need to remove the space here since the non-alpha line scrubs them, but it's useful to have an example anyway
    NSString *tmpName = [[fullName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    // scrub name for crazy characters
    NSData *decode = [tmpName dataUsingEncoding:NSASCIIStringEncoding
                            allowLossyConversion:YES];
    tmpName = [[NSString alloc] initWithData:decode encoding:NSASCIIStringEncoding];
    // remove non-alphanumeric characters
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet]
                                          invertedSet];
    NSString *trimmedReplacement = [[tmpName componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];

    // add a digit to the end if there are more than one address per person
    if (emailCount > 0) {
        return [trimmedReplacement stringByAppendingString:
                [NSString stringWithFormat:@"%d",emailCount]];
    } else {
        return trimmedReplacement;
    }
}

void printAddresses(NSArray *resultsArray, NSString *theArg, NSString *queryStr, BOOL aliasPrint, BOOL emailPrint) {
    ABPerson *person;
    int i;
    BOOL emailMatch;

    NSEnumerator *results = [resultsArray objectEnumerator];
    while (person = (ABPerson*)[results nextObject]) {
        
        
        NSString *fullNameStr = [NSString stringWithFormat:@"%@ %@",
                                 [[person valueForProperty:kABFirstNameProperty] description],
                                 [[person valueForProperty:kABLastNameProperty] description]];
        NSString *nickStr = [[person valueForProperty:kABNicknameProperty] description];
        ABMultiValue *emails = [person valueForProperty: kABEmailProperty];
        int emailCount = (int)[emails count];
        for (i = 0; i < emailCount; i++ ) {
            NSString *thisEmail = [emails valueAtIndex: i];
            // emailPrint will only print the matched email address, not every address for the matched person
            if (emailPrint) {
                emailMatch = ([thisEmail rangeOfString:theArg options:NSCaseInsensitiveSearch].location != NSNotFound);
                if (emailMatch) {
                    if (aliasPrint) {
                        printf("alias %s\t%s <%s>%s\n", [slugName(fullNameStr, i+1) UTF8String],
                               [fullNameStr UTF8String], [thisEmail UTF8String],
                               [queryStr UTF8String]);
                        if (nickStr) {
                            printf("alias %s\t%s <%s>%s\n", [slugName(nickStr, i+1) UTF8String],
                                   [fullNameStr UTF8String], [thisEmail UTF8String],
                                   [queryStr UTF8String]);
                        }
                    } else {
                    printf("%s\t%s%s\n", [thisEmail UTF8String], [fullNameStr UTF8String], [queryStr UTF8String]);
                    }
                }
            } else {
                if (aliasPrint) {
                    printf("alias %s\t%s <%s>%s\n", [slugName(fullNameStr, i+1) UTF8String],
                           [fullNameStr UTF8String], [thisEmail UTF8String],
                           [queryStr UTF8String]);
                    if (nickStr) {
                        printf("alias %s\t%s <%s>%s\n", [slugName(nickStr, i+1) UTF8String],
                               [fullNameStr UTF8String], [thisEmail UTF8String],
                               [queryStr UTF8String]);
                    }
                    printf("%s", [queryStr UTF8String]);
                    
                } else {
                    printf("%s\t%s%s\n", [thisEmail UTF8String], [fullNameStr UTF8String], [queryStr UTF8String]);
                }
            }
        }
    }
}

//void printGroupsOld(NSString *theGroup, NSArray *resultsArray, BOOL aliasPrint) {
//    NSMutableArray* people = [[NSMutableArray alloc] init];
//    int groupCount = (int)[resultsArray count] - 1;
//    while ( groupCount >= 0 ) {
//        NSArray* members = [ [resultsArray objectAtIndex:groupCount] members ];
//        [ people addObjectsFromArray : members ];
//        groupCount--;
//    }
//    if (aliasPrint) {
//        printf("group -group %s -addr ", [theGroup UTF8String]);
//    }
//    int count = (int)[people count];
//    int i;
//    int j;
//    for (i = 0; i < count; i++) {
//        ABPerson * person = [people objectAtIndex:i];
//        ABMultiValue *emails = [person valueForProperty: kABEmailProperty];
//
//        int emailCount = (int)[emails count];
//        for (j = 0; j < emailCount; j++ ) {
//            NSString *thisEmail = [emails valueAtIndex: j];
//            printf("%s ", [thisEmail UTF8String]);
//        }
//    }
//}

//void printGroups3(NSArray *resultsArray, BOOL aliasPrint) {
//    NSMutableArray* people = [[NSMutableArray alloc] init];
//    int i;
//    int j;
//    int k;
//    NSArray *members = nil;
//    int groupCount = (int)[resultsArray count];
//    for (i = 0; i < groupCount; i++) {
//        ABGroup *theGroup = [resultsArray objectAtIndex: i];
//        printf("group -group %s -addr ", [slugName([theGroup valueForProperty: kABGroupNameProperty], 0)  UTF8String]);
//
//        members = [ theGroup members ];
//        [people addObjectsFromArray : members ];
//        int count = (int)[people count];
//        if (count == 0) continue;
//        for (j = 0; j < count; j++) {
//            ABPerson * person = [people objectAtIndex: j];
//            ABMultiValue *emails = [person valueForProperty: kABEmailProperty];
//            int emailCount = (int)[emails count];
//            for (k = 0; k < emailCount; k++ ) {
//                NSString *thisEmail = [emails valueAtIndex: k];
//                printf("%s ", [thisEmail UTF8String]);
//            }
//        }
//        [people removeAllObjects];
//    printf("\n");
//    printf("\n");
//    }
//}

void printGroups(NSArray *resultsArray, BOOL aliasPrint) {
    int i;
    int j;
    int k;
    NSArray *members = nil;
    int groupCount = (int)[resultsArray count];
    for (i = 0; i < groupCount; i++) {
        ABGroup *theGroup = [resultsArray objectAtIndex: i];
        members = [ theGroup members ];
        int count = (int)[members count];
        if (count == 0) continue;
        if (aliasPrint) {
            printf("group -group %s -addr ", [slugName([theGroup valueForProperty: kABGroupNameProperty], 0)  UTF8String]);
        }
        for (j = 0; j < count; j++) {
            ABPerson * person = [members objectAtIndex: j];
            ABMultiValue *emails = [person valueForProperty: kABEmailProperty];
            int emailCount = (int)[emails count];
            for (k = 0; k < emailCount; k++ ) {
                NSString *thisEmail = [emails valueAtIndex: k];
                printf("%s ", [thisEmail UTF8String]);
            }
        }
        printf("\n");
    }
}

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        // set up some variables
        int i;
        NSString *theArg;
        NSString *queryStr = @"";

        // cli options
        BOOL muttFormat = false;
        BOOL groupList = false;
        BOOL printAll = false;
        BOOL aliasFormat = false;

        
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

        NSArray *muttArg = [NSArray arrayWithObjects: @"--mutt", @"-m",
                nil];

        NSArray *groupArg = [NSArray arrayWithObjects: @"--group", @"-g",
                            nil];
        NSArray *allArg = [NSArray arrayWithObjects: @"--all",
                             nil];
        NSArray *aliasArg = [NSArray arrayWithObjects: @"--alias", @"-a",
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
                    
                    printf("  -h, --help        display this help\n");
                    printf("  -v, --version     display version\n");
                    /* printf("  -f, --format      format output\n"); */
                    printf("  -a, --alias       results in mutt alias format\n");
                    printf("      --all         prints all entries\n");
                    printf("  -g, --group       prints email addresses of GROUP members\n");
                    printf("  -m, --mutt        print results in mutt query compatible format (adds header line)\n");
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
                // mutt format
                else if ([muttArg containsObject: theArg] == YES) {
                    [indexesToRemove addIndex: i];
                    muttFormat = true;
                }
                // groups format
                else if ([groupArg containsObject: theArg] == YES) {
                    [indexesToRemove addIndex: i];
                    groupList = true;
                }
                // print all
                else if ([allArg containsObject: theArg] == YES) {
                    [indexesToRemove addIndex: i];
                    printAll = true;
                }
                // alias format
                else if ([aliasArg containsObject: theArg] == YES) {
                    [indexesToRemove addIndex: i];
                    aliasFormat = true;
                }
            }
        }
        [args removeObjectsAtIndexes: indexesToRemove];

        // process the search term argument
        if ([args count] > 1) {
            for (i = 1; i < [args count]; i++) {
                theArg = [NSString stringWithString: [args objectAtIndex: i]];
           }
        } else {
            theArg = nil;
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

        ABSearchElement *orgSearch =
        [ABPerson searchElementForProperty:kABOrganizationProperty
                                     label:nil
                                       key:nil
                                     value:theArg
                                comparison:kABContainsSubStringCaseInsensitive];

        ABSearchElement *groupSearch =
        [ABGroup searchElementForProperty:kABGroupNameProperty
                                     label:nil
                                       key:nil
                                     value:theArg
                                comparison:kABEqualCaseInsensitive];
        
        if (groupList) {
            NSArray *groupsFound = nil;
            if (theArg) {
                groupsFound = [AB recordsMatchingSearchElement:groupSearch];
                printGroups(groupsFound, aliasFormat);
          } else {
                groupsFound = [AB groups];
                printGroups(groupsFound, aliasFormat);
            }
            
        } else {
            NSArray *peopleFound = nil;
            NSArray *emailResults = nil;
            if (printAll || ! theArg) {
                peopleFound = [AB people];
            } else {

                // perform our two searches, one for email...
                NSArray *emailsFound = [AB recordsMatchingSearchElement:emailSearch];
                NSMutableArray *uniqueElementsEmail = [emailsFound mutableCopy];
                
                // ... and one for everything else
                ABSearchElement *multiSearch = [ABSearchElement
                                                searchElementForConjunction:
                                                kABSearchOr
                                                children:
                                                [NSArray arrayWithObjects:
                                                 firstNameSearch,
                                                 lastNameSearch, nicknameSearch,
                                                 orgSearch, nil]];
                peopleFound = [AB recordsMatchingSearchElement: multiSearch];
                
                // We are going to remove any results that we found in non-email
                // properties from the email results.
                [uniqueElementsEmail removeObjectsInArray:peopleFound];
                
                emailResults = [NSArray arrayWithArray: uniqueElementsEmail];
                // let's print the results where the string is found directly in the
                // email address first.  Then we will print the results where the
                // string is found in another property.
            }
            if (muttFormat && ! aliasFormat ) {
                printf("Results:\n");
            }

            if (emailResults) {
                printAddresses(emailResults, theArg, queryStr, aliasFormat, true);
            }
            printAddresses(peopleFound, theArg, queryStr, aliasFormat, false);
        }
    }
    return 0;
}
