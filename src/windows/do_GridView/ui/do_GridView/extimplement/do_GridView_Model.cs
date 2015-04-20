using do_GridView.extdefine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using doCore.Helper.JsonParse;
using doCore.Interface;
using doCore.Object;


namespace do_GridView.extimplement
{
    /// <summary>
    /// 自定义扩展组件Model实现，继承@TYPEID_MAbstract抽象类；
    /// </summary>
    public class do_GridView_Model : do_GridView_MAbstract
    {
        public do_GridView_Model():base()
        {

        }
        public override void OnInit()
        {
            base.OnInit();
            //注册属性
            this.RegistProperty(new doProperty("cellTemplates", PropertyDataType.String, "", false));
			this.RegistProperty(new doProperty("hSpacing", PropertyDataType.Number, "0", false));
			this.RegistProperty(new doProperty("isShowbar", PropertyDataType.Bool, "true", false));
			this.RegistProperty(new doProperty("numColumns", PropertyDataType.Number, "", false));
			this.RegistProperty(new doProperty("selectedColor", PropertyDataType.String, "", false));
			this.RegistProperty(new doProperty("vSpacing", PropertyDataType.Number, "0", false));

        }
        //处理成员方法
        public override bool InvokeSyncMethod(string _methodName, doJsonNode _dictParas,
            doIScriptEngine _scriptEngine, doInvokeResult _invokeResult)
        {
            if (base.InvokeSyncMethod(_methodName, _dictParas, _scriptEngine, _invokeResult)) return true;


            return false;
        }

        public override async Task<bool> InvokeAsyncMethod(string _methodName, doJsonNode _dictParas,
            doIScriptEngine _scriptEngine, string _callbackFuncName)
        {
            if (await base.InvokeAsyncMethod(_methodName, _dictParas, _scriptEngine, _callbackFuncName)) return true;

            return false;
        }
        public override async Task SetModelData(Dictionary<string, doJsonValue> _bindParas, object _obj)
        {
            if (_obj is doIListData)
            {
                do_GridView_View _view = (do_GridView_View)this.CurrentComponentUIView;
                _view.setModelData(_obj);
            }
            else
            {
                await base.SetModelData(_bindParas, _obj);
            }
        }
    }
}
