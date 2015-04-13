//
//  do_GridView_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_GridView_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doIListData.h"
#import "doIPage.h"
#import "doIApp.h"
#import "doISourceFS.h"
#import "doTextHelper.h"
#import "doUIContainer.h"

@implementation do_GridView_UIView
{
    NSMutableDictionary *_cellTemplatesDics;
    id<doIListData> _dataArrays;
    int _row;
    int _column;
    float _vSpace;
    float _hSpace;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.bounces=NO;//禁止拖动
    _cellTemplatesDics = [[NSMutableDictionary alloc]init];
    self.delegate = self;
    self.dataSource = self;

}
//销毁所有的全局对象
- (void) OnDispose
{
    _model = nil;
    //自定义的全局属性
    [ (doModule*)_dataArrays Dispose];
    for(int i =0;i<_cellTemplatesDics.count;i++){
        [(doModule*) _cellTemplatesDics Dispose];
    }
    [_cellTemplatesDics removeAllObjects];
    _cellTemplatesDics = nil;
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_cellTemplates:(NSString *)newValue
{
    //自己的代码实现
    NSArray *arrays = [newValue componentsSeparatedByString:@","];
    [_cellTemplatesDics removeAllObjects];
    for(int i=0;i<arrays.count;i++)
    {
        NSString *modelStr = arrays[i];
        if(modelStr != nil && ![modelStr isEqualToString:@""])
        {
            doSourceFile *source = [[[_model.CurrentPage CurrentApp] SourceFS] GetSourceByFileName:modelStr];
            if(!source)
                [NSException raise:@"gridview" format:@"试图使用无效的页面文件",nil];
            doUIContainer* _container = [[doUIContainer alloc] init:_model.CurrentPage];
            
            [_container LoadFromFile:source:nil:nil];
            doUIModule* _insertViewModel = _container.RootView;
            if (_insertViewModel == nil) {
                [NSException raise:@"gridview" format:@"创建view失败",nil];
            }
            _cellTemplatesDics[modelStr] = _insertViewModel;
            
        }
    }
}
- (void)change_hSpacing:(NSString *)newValue
{
    //自己的代码实现
    _hSpace = [[doTextHelper Instance] StrToFloat:newValue :0];
}
- (void)change_isShowbar:(NSString *)newValue
{
    //自己的代码实现
}
- (void)change_numColumns:(NSString *)newValue
{
    //自己的代码实现
    _column = [[doTextHelper Instance] StrToInt:newValue :1];
    _row = (int)([_dataArrays GetCount]/_column);
}
- (void)change_selectedColor:(NSString *)newValue
{
    //自己的代码实现
}
- (void)change_vSpacing:(NSString *)newValue
{
    //自己的代码实现
    _vSpace = [[doTextHelper Instance] StrToFloat:newValue :0];
}

#pragma mark -
#pragma mark - private
-(void) SetModelData:(id<doIListData>) _jsonObject
{
    if(_dataArrays!= _jsonObject)
        _dataArrays = _jsonObject;
    [self reloadData];
}
#pragma mark - tableView sourcedelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArrays GetCount]/_column;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* indentify = @"";
    NSMutableArray* fileNames = [[NSMutableArray alloc] initWithCapacity:_column];
    NSMutableArray* modules = [[NSMutableArray alloc] initWithCapacity:_column];
    for(int i=0;i<_column;i++)
    {
        doJsonValue *jsonValue = [_dataArrays GetData:((int)indexPath.row)*_column+i];
        doJsonNode *dataNode = [jsonValue GetNode];
        int cellIndex = [dataNode GetOneInteger:@"cellTemplate" :0];
        fileNames[i] = [_cellTemplatesDics allKeys][cellIndex];
        indentify = [indentify stringByAppendingString:fileNames[i]];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
        float width = (self.frame.size.width - (_column+1)*_hSpace*_model.XZoom)/_column;
        for(int i=0;i<_column;i++)
        {
            doSourceFile *source = [[[_model.CurrentPage CurrentApp] SourceFS] GetSourceByFileName:fileNames[i]];
            id<doIPage> pageModel = _model.CurrentPage;
            doUIContainer *container = [[doUIContainer alloc] init:pageModel];
            [container LoadFromFile:source:nil:nil];
            modules[i] = container.RootView;
            [container LoadDefalutScriptFile:fileNames[i]];
            UIView *insertView = (UIView*)(((doUIModule*)modules[i]).CurrentUIModuleView);
            id<doIUIModuleView> modelView =((doUIModule*) modules[i]).CurrentUIModuleView;
            [modelView OnRedraw];
            insertView.frame = CGRectMake(_hSpace*_model.XZoom+width*i, _vSpace*_model.YZoom, width, insertView.frame.size.height);
            [[cell contentView] addSubview:insertView];
        }
    }
    else
    {
        for(int i=0;i<_column;i++)
        {
        modules[i] = [(id<doIUIModuleView>)[cell.contentView.subviews objectAtIndex:i] GetModel];
        }
    }
    for(int i=0;i<_column;i++)
    {
        doJsonValue *jsonValue = [_dataArrays GetData:((int)indexPath.row)*_column+i];
        [modules[i] SetModelData:nil :jsonValue];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%s",__func__);
    //不能响应一行的点击事件，需要相应每一行多个item单独的点击事件
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float maxHeight = 0;
    for(int i=0;i<_column;i++)
    {
        doJsonValue *jsonValue = [_dataArrays GetData:((int)indexPath.row)*_column+i];
        doJsonNode *dataNode = [jsonValue GetNode];
        int cellIndex = [dataNode GetOneInteger:@"cellTemplate" :0];
        NSString* indentify = [_cellTemplatesDics allKeys][cellIndex];
        doUIModule*  model = _cellTemplatesDics[indentify];
        [model SetModelData:nil :jsonValue ];
        [model.CurrentUIModuleView OnRedraw];
        float height = ((UIView*)model.CurrentUIModuleView).frame.size.height;
        if(height>maxHeight)
            maxHeight = height;
    }
    return maxHeight+_vSpace*_model.YZoom;
}

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (doJsonNode *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (doJsonNode *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
