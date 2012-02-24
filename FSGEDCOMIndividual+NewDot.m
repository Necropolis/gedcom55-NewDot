//
//  FSGEDCOMIndividual+NewDot.m
//  GEDCOM 5.5+NewDot
//
//  Created by Christopher Miller on 2/24/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMIndividual+NewDot.h"

#import "FSGEDCOMStructure.h"

#import "NDService.h"
#import "NDService+FamilyTree.h"

@implementation FSGEDCOMIndividual (NewDot)

- (NSDictionary *)nfs_assertionsDescribingIndividual
{
   NSMutableDictionary * assertions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSMutableArray array], NDFamilyTreeAssertionType.characteristics,
                                       [NSMutableArray array], NDFamilyTreeAssertionType.citations,
                                       [NSMutableArray array], NDFamilyTreeAssertionType.events,
                                       [NSMutableArray array], NDFamilyTreeAssertionType.exists,
                                       [NSMutableArray array], NDFamilyTreeAssertionType.genders,
                                       [NSMutableArray array], NDFamilyTreeAssertionType.names,
                                       [NSMutableArray array], NDFamilyTreeAssertionType.ordinances,
                                       [NSMutableArray array], NDFamilyTreeAssertionType.notes, nil];
    
    /*
     ================================================ what's in a name?
     "names" : [
        {
            "forms" : [
                {
                    "fullText" : "API User 1241",
                }
            ]
        },
     ]
     */
    FSGEDCOMStructure * name = [[self.elements objectForKey:@"NAME"] firstObject];
    if (name) {
    
        NSError * error;
        NSRegularExpression * removeSlashes = [NSRegularExpression regularExpressionWithPattern:@"(?:\\/)([\\w^\\/]+)(?:\\/)" options:0 error:&error];
        if (error)
            [NSException raise:@"Bad regex?" format:@"Seriously shouldn't be able to happen unless there's some catastrophic failure in ICU."];
        
        [[assertions objectForKey:NDFamilyTreeAssertionType.names] addObject:
         [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[removeSlashes stringByReplacingMatchesInString:[name value] options:0 range:NSMakeRange(0, [[name value] length]) withTemplate:@"$1"] forKey:@"fullText"]]
                                     forKey:@"forms"]];
        
    }
    
    

    // remove empty ones
    [assertions removeObjectsForKeys:[[assertions keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        if (0==[obj count]) return YES;
        else return NO;
    }] allObjects]];
    
    return [assertions copy]; // immutable copy, for no apparent reason
}

@end
