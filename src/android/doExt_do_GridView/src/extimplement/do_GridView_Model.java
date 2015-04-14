package extimplement;

import java.util.Map;

import core.helper.jsonparse.DoJsonValue;
import core.interfaces.DoIListData;
import extdefine.do_GridView_MAbstract;

/**
 * 自定义扩展组件Model实现，继承do_GridView_MAbstract抽象类；
 *
 */
public class do_GridView_Model extends do_GridView_MAbstract {

	public do_GridView_Model() throws Exception {
		super();
	}
	
	@Override
	public void setModelData(Map<String, DoJsonValue> _bindParas, Object _obj) throws Exception {
		if (_obj instanceof DoIListData) {
			do_GridView_View _view = (do_GridView_View) this.getCurrentUIModuleView();
			_view.setModelData(_obj);
		} else {
			super.setModelData(_bindParas, _obj);
		}
	}
}
