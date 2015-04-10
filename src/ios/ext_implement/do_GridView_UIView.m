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

@implementation do_GridView_UIView
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
}
//销毁所有的全局对象
- (void) OnDispose
{
    _model = nil;
    //自定义的全局属性
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
}

#pragma mark - doUIModuleCollection类及其子类允许在自身View上添加view，由于前端设计器是IDE实现。在运行时需要用代码将子组件添加到对应的容器中
- (void)setChildsView
{
    for (doUIModule *childModel in _model.ChildUIModules)
    {
        UIView *childView = (UIView *)childModel.CurrentUIModuleView;
        [self addSubview:childView];
    }
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
}
- (void)change_hSpacing:(NSString *)newValue
{
    //自己的代码实现
}
- (void)change_isShowbar:(NSString *)newValue
{
    //自己的代码实现
}
- (void)change_numColumns:(NSString *)newValue
{
    //自己的代码实现
}
- (void)change_selectedColor:(NSString *)newValue
{
    //自己的代码实现
}
- (void)change_vSpacing:(NSString *)newValue
{
    //自己的代码实现
}

#pragma mark -
#pragma mark - 同步异步方法的实现
/*
    1.参数节点
        doJsonNode *_dictParas = [parms objectAtIndex:0];
        在节点中，获取对应的参数
        NSString *title = [_dictParas GetOneText:@"title" :@"" ];
        说明：第一个参数为对象名，第二为默认值
 
    2.脚本运行时的引擎
        id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
    3.同步回调对象(有回调需要添加如下代码)
        doInvokeResult *_invokeResult = [parms objectAtIndex:2];
        回调信息
        如：（回调一个字符串信息）
        [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
    3.获取回调函数名(异步方法都有回调)
        NSString *_callbackName = [parms objectAtIndex:2];
        在合适的地方进行下面的代码，完成回调
        新建一个回调对象
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        填入对应的信息
        如：（回调一个字符串）
        [_invokeResult SetResultText: @"异步方法完成"];
        [_scritEngine Callback:_callbackName :_invokeResult];
 */
//同步
 - (void)bindData:(NSArray *)parms
 {
     doJsonNode *_dictParas = [parms objectAtIndex:0];
     id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
     doInvokeResult *_invokeResult = [parms objectAtIndex:2];
     //构建_invokeResult的内容
     
     //自己的代码实现
 }
 - (void)refresh:(NSArray *)parms
 {
     doJsonNode *_dictParas = [parms objectAtIndex:0];
     id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
     doInvokeResult *_invokeResult = [parms objectAtIndex:2];
     //构建_invokeResult的内容
     
     //自己的代码实现
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
