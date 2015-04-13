//
//  do_GridView_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_GridView_IView.h"
#import "do_GridView_UIModel.h"
#import "doIUIModuleView.h"
#import "doIListData.h"

@interface do_GridView_UIView : UITableView<do_GridView_IView, doIUIModuleView,UITableViewDataSource,UITableViewDelegate>
//可根据具体实现替换UIView
{
	@private
		__weak do_GridView_UIModel *_model;
}
-(void) SetModelData:(id<doIListData>) _jsonObject;
@end
