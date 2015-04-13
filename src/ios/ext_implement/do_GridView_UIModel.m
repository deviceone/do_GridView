//
//  do_GridView_Model.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_GridView_UIModel.h"
#import "doProperty.h"
#import "do_GridView_UIView.h"
#import "doIListData.h"

@implementation do_GridView_UIModel

#pragma mark - 注册属性（--属性定义--）
-(void)OnInit
{
    [super OnInit];    
    //属性声明
	[self RegistProperty:[[doProperty alloc]init:@"cellTemplates" :String :@"" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"hSpacing" :Number :@"" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"isShowbar" :Bool :@"true" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"numColumns" :Number :@"" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"selectedColor" :String :@"" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"vSpacing" :Number :@"" :YES]];

}
-(void) SetModelData:(NSMutableDictionary*) _bindParas :(id) _jsonObject
{
    if([_jsonObject conformsToProtocol:@protocol(doIListData)]){
        do_GridView_UIView* view = (do_GridView_UIView*) self.CurrentUIModuleView;
        [view SetModelData:_jsonObject];
    }
    else
        [super SetModelData:_bindParas :_jsonObject ];
}
@end