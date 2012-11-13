//
//  CDocument.h
//  ACVViewer
//
//  Created by Jonathan Wight on 3/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CACVObject;

@interface CACVDocument : NSDocument

@property (readwrite, nonatomic, strong) CACVObject *ACVObject;

@end
