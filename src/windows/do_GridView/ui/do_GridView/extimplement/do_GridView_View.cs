using doCore.Helper;
using doCore.Helper.JsonParse;
using doCore.Interface;
using doCore.Object;
using do_GridView.extdefine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.UI;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;

namespace do_GridView.extimplement
{
    /// <summary>
    /// 自定义扩展UIView组件实现类，此类必须继承相应控件类或UserControl类，并实现doIUIModuleView,@TYPEID_IMethod接口；
    /// #如何调用组件自定义事件？可以通过如下方法触发事件：
    /// this.model.EventCenter.fireEvent(_messageName, jsonResult);
    /// 参数解释：@_messageName字符串事件名称，@jsonResult传递事件参数对象；
    /// 获取doInvokeResult对象方式new doInvokeResult(model.UniqueKey);
    /// </summary>
    public class do_GridView_View : UserControl, doIUIModuleView, do_GridView_IMethod
    {
        /// <summary>
        /// 每个UIview都会引用一个具体的model实例；
        /// </summary>
        private do_GridView_MAbstract model;
        public do_GridView_View()
        {

        }
        List<string> cellTemplates = new List<string>();
        List<string> cellTemplatecontents = new List<string>();
        doIListData listdata = null;
        int numColumns = 1;
        ScrollViewer sv = new ScrollViewer();
        StackPanel sp = new StackPanel();
        /// <summary>
        /// 初始化加载view准备,_doUIModule是对应当前UIView的model实例
        /// </summary>
        /// <param name="_doComponentUI"></param>
        public void LoadView(doUIModule _doUIModule)
        {
            this.HorizontalAlignment = HorizontalAlignment.Left;
            this.VerticalAlignment = VerticalAlignment.Top;
            this.sv.HorizontalScrollMode = ScrollMode.Disabled;
            this.model = (do_GridView_MAbstract)_doUIModule;
            this.Background = new SolidColorBrush(Colors.Red);
            this.Foreground = new SolidColorBrush(Colors.Blue);
            this.Content = sv;
            sv.Content = sp;
            sp.Orientation = Orientation.Vertical;
            //this.Background =await GetImg("resource.img.png");
        }

        public doUIModule GetModel()
        {
            return this.model;
        }
        /// <summary>
        /// 获取资源图片示例：
        /// 将图片属性设置为嵌入的资源，目录使用.分割，如/resource/img.png==>resource.img.png
        /// 可通过此方法获取该图片资源的ImageBrush
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public async Task<ImageBrush> GetImg(string url)
        {
            System.Reflection.AssemblyName an = new System.Reflection.AssemblyName("doExt_do_GridView");
            var ass = System.Reflection.Assembly.Load(an);
            var abc = ass.GetManifestResourceNames();
            var stream = ass.GetManifestResourceStream("doExt_do_GridView." + url);
            var randomAccessStream = new InMemoryRandomAccessStream();
            var outputStream = randomAccessStream.GetOutputStreamAt(0);
            await RandomAccessStream.CopyAsync(stream.AsInputStream(), outputStream);
            BitmapImage bitmapImage = new BitmapImage();
            bitmapImage.SetSource(randomAccessStream);
            ImageBrush ib = new ImageBrush();
            ib.ImageSource = bitmapImage;
            return ib;
        }
        /// <summary>
        /// 动态修改属性值时会被调用，方法返回值为true表示赋值有效，并执行OnPropertiesChanged，否则不进行赋值；
        /// </summary>
        /// <param name="_changedValues">属性集（key名称、value值）</param>
        /// <returns></returns>
        public bool OnPropertiesChanging(Dictionary<string, string> _changedValues)
        {
            return true;
        }
        /// <summary>
        /// 属性赋值成功后被调用，可以根据组件定义相关属性值修改UIView可视化操作；
        /// </summary>
        /// <param name="_changedValues">属性集（key名称、value值）</param>
        public void OnPropertiesChanged(Dictionary<string, string> _changedValues)
        {
            doUIModuleHelper.HandleBasicViewProperChanged(this.model, _changedValues);
            if (_changedValues.Keys.Contains("cellTemplates"))
            {
                cellTemplates = _changedValues["cellTemplates"].Split(',').ToList();
            }
            if (_changedValues.Keys.Contains("numColumns"))
            {
                this.numColumns = doTextHelper.StrToInt(_changedValues["numColumns"], 1);
            }
            if (_changedValues.Keys.Contains("isShowbar"))
            {
                if (_changedValues["isShowbar"].ToString() == "true")
                {
                    this.sv.VerticalScrollMode = ScrollMode.Enabled;
                    this.sv.VerticalScrollBarVisibility = ScrollBarVisibility.Visible;
                }
                else
                {
                    this.sv.VerticalScrollMode = ScrollMode.Disabled;
                    this.sv.VerticalScrollBarVisibility = ScrollBarVisibility.Hidden;
                }
            }
        }
        /// <summary>
        /// 同步方法，JS脚本调用该组件对象方法时会被调用，可以根据_methodName调用相应的接口实现方法；
        /// </summary>
        /// <param name="_methodName">方法名称</param>
        /// <param name="_dictParas">参数（K,V）</param>
        /// <param name="_scriptEngine">当前Page JS上下文环境对象</param>
        /// <param name="_invokeResult">用于返回方法结果对象</param>
        /// <returns></returns>
        public bool InvokeSyncMethod(string _methodName, doJsonNode _dictParas, doIScriptEngine _scriptEngine, doInvokeResult _invokeResult)
        {
            return false;
        }
        private void bindtemplates()
        {
            foreach (var item in cellTemplates)
            {
                cellTemplatecontents.Add(model.CurrentPage.CurrentApp.SourceFS.GetSourceByFileName(item).TxtContent());
            }
        }
        private async void RefreshList()
        {
            sp.Children.Clear();
            if (listdata == null)
            {
                return;
            }
            for (int i = 0, total = listdata.getCount(); i < total; i++)
            {
                var dataitem = listdata.getData(i) as doJsonValue;
                int _index = doTextHelper.StrToInt(dataitem.GetNode().GetOneText("cellTemplate", "0"), 0);
                string templateUI = cellTemplates[_index];
                string templateUIContent = cellTemplatecontents[_index];
                doUIContainer _doUIContainer = new doUIContainer(model.CurrentPage);
                _doUIContainer.loadFromContent(templateUIContent, null, null);
                _doUIContainer.loadDefalutScriptFile(templateUI);
                doIUIModuleView _doIUIModuleView = null;
                _doIUIModuleView = _doUIContainer.RootView.CurrentComponentUIView;

                if (_doIUIModuleView != null)
                {
                    await _doIUIModuleView.GetModel().SetModelData(null, dataitem);
                    AddChildControl((FrameworkElement)_doIUIModuleView, i);
                }
            }
        }
        private void AddChildControl(FrameworkElement con, int index)
        {
            con.Tag = index;
            con.Tapped += con_Tapped;
            con.Holding += con_Holding;
            var hSpacing = doTextHelper.StrToInt(this.model.GetPropertyValue("hSpacing"), 0);
            var vSpacing = doTextHelper.StrToInt(this.model.GetPropertyValue("vSpacing"), 0);
            con.Margin = new Thickness(0, 0, hSpacing, 0);
            if (sp.Children.Count == 0)
            {
                StackPanel sph = new StackPanel();
                sph.Orientation = Orientation.Horizontal;
                sph.Margin = new Thickness(0, 0, 0, vSpacing);
                sp.Children.Add(sph);
            }
            var splast = sp.Children.Last() as StackPanel;
            if (splast.Children.Count() < this.numColumns)
            {
                splast.Children.Add(con);
            }
            else
            {
                StackPanel sph = new StackPanel();
                sph.Orientation = Orientation.Horizontal;
                sph.Margin = new Thickness(0, 0, 0, vSpacing);
                sph.Children.Add(con);
                sp.Children.Add(sph);
            }
        }

        void con_Holding(object sender, Windows.UI.Xaml.Input.HoldingRoutedEventArgs e)
        {
            doInvokeResult _invokeResult = new doInvokeResult(this.model.UniqueKey);
            _invokeResult.SetResultText((sender as FrameworkElement).Tag.ToString());
            this.model.EventCenter.FireEvent("longTouch", _invokeResult);
        }

        void con_Tapped(object sender, Windows.UI.Xaml.Input.TappedRoutedEventArgs e)
        {
            doInvokeResult _invokeResult = new doInvokeResult(this.model.UniqueKey);
            _invokeResult.SetResultText((sender as FrameworkElement).Tag.ToString());
            this.model.EventCenter.FireEvent("touch", _invokeResult);
        }

        /// <summary>
        /// 异步方法（通常都处理些耗时操作，避免UI线程阻塞），JS脚本调用该组件对象方法时会被调用，
        /// 可以根据_methodName调用相应的接口实现方法；#如何执行异步方法回调？可以通过如下方法：
        /// _scriptEngine.callback(_callbackFuncName, _invokeResult);
        /// 参数解释：@_callbackFuncName回调函数名，@_invokeResult传递回调函数参数对象；
        /// 获取doInvokeResult对象方式new doInvokeResult(model.UniqueKey);
        /// </summary>
        /// <param name="_methodName">方法名称</param>
        /// <param name="_dictParas">参数（K,V）</param>
        /// <param name="_scriptEngine">当前page JS上下文环境</param>
        /// <param name="_callbackFuncName">回调函数名</param>
        /// <returns></returns>
        public bool InvokeAsyncMethod(string _methodName, doJsonNode _dictParas, doIScriptEngine _scriptEngine, string _callbackFuncName)
        {
            doInvokeResult _invokeResult = _scriptEngine.CreateInvokeResult(this.model.UniqueKey);

            return false;
        }

        /// <summary>
        /// 重绘组件，构造组件时由系统框架自动调用；
        /// 或者由前端JS脚本调用组件onRedraw方法时被调用（注：通常是需要动态改变组件（X、Y、Width、Height）属性时手动调用）
        /// </summary>
        public void OnRedraw()
        {
            var tp = doUIModuleHelper.GetThickness(this.model);
            this.Margin = tp.Item1;
            this.Width = tp.Item2;
            this.Height = tp.Item3;
        }
        /// <summary>
        /// 释放资源处理，前端JS脚本调用closePage或执行removeui时会被调用；
        /// </summary>
        public void OnDispose()
        {

        }
        public void setModelData(object _obj)
        {
            if (_obj == null)
                return;
            if (_obj is doIListData)
            {
                listdata = _obj as doIListData;
                bindtemplates();
                RefreshList();
            }

        }
    }
}
