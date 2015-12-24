package;
import flexlite.core.Injector;
import flexlite.core.Theme;
import flexlite.managers.SystemManager;
import flexlite.skins.themes.VectorTheme;
//import flexlite.utils.Debugger;

/**
 * ...
 * @author 
 */
class AppContainer extends SystemManager
{

	public function new() 
	{
		super();
		Injector.mapClass(Theme,VectorTheme);//这里为了方便调试，一次性注入所有组件的默认皮肤。正式项目中不需要默认皮肤,应当自定义主题。
		//Debugger.initialize(stage);//显示列表调试工具(可选)。
	}
	
}