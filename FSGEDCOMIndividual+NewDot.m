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
    NSLog(@"%@", [self descriptionWithLocale:nil indent:0]);
    
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
    [[self.elements objectForKey:@"NAME"] enumerateObjectsUsingBlock:^(FSGEDCOMStructure * name, NSUInteger idx, BOOL *stop) {
        NSError * error;
        NSRegularExpression * removeSlashes = [NSRegularExpression regularExpressionWithPattern:@"(?:\\/)([\\w^\\/]+)(?:\\/)" options:0 error:&error];
        if (error)
            [NSException raise:@"Bad regex?" format:@"Seriously shouldn't be able to happen unless there's some catastrophic failure in ICU."];
        
        [[assertions objectForKey:NDFamilyTreeAssertionType.names] addObject:
         [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[removeSlashes stringByReplacingMatchesInString:[name value] options:0 range:NSMakeRange(0, [[name value] length]) withTemplate:@"$1"] forKey:@"fullText"]]
                                     forKey:@"forms"]];
    }];
    /*
     ================================================ events are important, mkay?
     "events" : [
        {
            "value" : {
                "type" : (Adoption, Adult Christening, Baptism, Confirmation, Bar Mitzvah, Bas Mitzvah, Birth, Blessing, Burial, Christening, Cremation, Death, Graduation, Immigration, Military Service, Mission, Move, Naturalization, Probate, Retirement, Will, Census, Circumcision, Emigration, Excommunication, First Communion, First Known Child, Funeral, Hospitalization, Illness, Naming, Miscarriage, Ordination, Other),
                "place" : <place stuff>,
                "date" : <date stuff>
            }
        }
     ]
     */
    [[self.elements objectForKey:@"BIRT"] enumerateObjectsUsingBlock:^(FSGEDCOMStructure * birth, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary * birthEvent = [[NSMutableDictionary alloc] initWithCapacity:3];
        [birthEvent setObject:@"Birth" forKey:@"type"];
        
        FSGEDCOMStructure * dateOfBirth = [[birth.elements objectForKey:@"DATE"] firstObject];
        if (dateOfBirth) {
            [birthEvent setObject:[NSDictionary dictionaryWithObject:[dateOfBirth value] forKey:@"original"] forKey:@"date"];
        }
        FSGEDCOMStructure * placeOfBirth = [[birth.elements objectForKey:@"PLAC"] firstObject];
        if (placeOfBirth) {
            [birthEvent setObject:[NSDictionary dictionaryWithObject:[placeOfBirth value] forKey:@"original"] forKey:@"place"];
        }
        
        [[assertions objectForKey:NDFamilyTreeAssertionType.events] addObject:birthEvent];
    }];
    [[self.elements objectForKey:@"DEAT"] enumerateObjectsUsingBlock:^(FSGEDCOMStructure * death, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary * deathEvent = [[NSMutableDictionary alloc] initWithCapacity:3];
        [deathEvent setObject:@"Death" forKey:@"type"];
        
        FSGEDCOMStructure * dateOfDeath = [[death.elements objectForKey:@"DATE"] firstObject];
        if (dateOfDeath) {
            [deathEvent setObject:[NSDictionary dictionaryWithObject:[dateOfDeath value] forKey:@"original"] forKey:@"date"];
        }
        FSGEDCOMStructure * placeOfDeath = [[death.elements objectForKey:@"PLAC"] firstObject];
        if (placeOfDeath) {
            [deathEvent setObject:[NSDictionary dictionaryWithObject:[placeOfDeath value] forKey:@"original"] forKey:@"place"];
        }
        
        [[assertions objectForKey:NDFamilyTreeAssertionType.events] addObject:deathEvent];
    }];
    /*
     ================================================ gender has meaning
     "genders" : [
        {
            "value" : {
                "type" : (Male, Female, Unknown)
            }
        }
     ]
     */
    [[self.elements objectForKey:@"SEX"] enumerateObjectsUsingBlock:^(FSGEDCOMStructure * gender, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary * genderAssertion = [NSMutableDictionary dictionary];
        NSString * val = [gender value];
        if ([val compare:@"male" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            [genderAssertion setObject:[NSDictionary dictionaryWithObject:@"Male" forKey:@"type"] forKey:@"value"];
        } else if ([val compare:@"female" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            [genderAssertion setObject:[NSDictionary dictionaryWithObject:@"Female" forKey:@"type"] forKey:@"value"];
        } else { // unknown
            [genderAssertion setObject:[NSDictionary dictionaryWithObject:@"Unknown" forKey:@"type"] forKey:@"value"];
        }
        [[assertions objectForKey:NDFamilyTreeAssertionType.genders] addObject:genderAssertion];
    }];
    

    // remove empty ones
    [assertions removeObjectsForKeys:[[assertions keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        if (0==[obj count]) return YES;
        else return NO;
    }] allObjects]];
    
    return [assertions copy]; // immutable copy, for no apparent reason
}

@end
