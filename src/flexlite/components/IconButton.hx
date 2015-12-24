package flexlite.components;


/**
 * @example
 * var iconButton:IconButton = new IconButton();
 * iconButton.skinName = IconButtonSkin;
 * iconButton.icon = Class,String, or DisplayObject
 *
 * @author foodyi
 *
 */
class IconButton extends Button
{
	/**
	 * [SkinPart]图标显示对象
	 */
	@SkinPart
	public var iconDisplay : UIAsset;
	
	public var icon(get, set):Dynamic;
	
	/**
	 * 构造函数
	 */
	public function new()
	{
		super();
	}

	private var _icon : Dynamic;
	
	

	/**
	 * 要显示的图标，可以是类定义，位图数据，显示对象或路径字符。
	 */
	public function get_icon() : Dynamic
	{
		return _icon;
	}

	public function set_icon( value : Dynamic ) : Dynamic
	{
		if ( _icon == value )
			return _icon;
		_icon = value;
		if ( iconDisplay != null )
			iconDisplay.skinName = _icon;
		return _icon;
	}

	override private function partAdded( partName : String, instance : Dynamic ) : Void
	{
		super.partAdded( partName, instance );
		if ( instance == iconDisplay )
		{
			iconDisplay.skinName = _icon;
		}

	}
}
