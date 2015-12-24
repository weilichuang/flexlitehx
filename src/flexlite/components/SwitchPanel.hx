package flexlite.components;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.Vector;

/**
 * 颜色选择器
 */
class SwitchPanel extends SkinnableComponent
{
	public static var SWITCH_COLORS : Vector<Int> = Vector.ofArray([ 0, 0, 0, 13056, 26112, 39168, 52224, 65280, 3342336, 3355392, 3368448, 3381504, 3394560, 3407616, 6684672, 6697728, 6710784, 6723840, 6736896, 6749952, 3355443, 0, 51, 13107, 26163, 39219, 52275, 65331, 3342387, 3355443, 3368499, 3381555, 3394611, 3407667, 6684723, 6697779, 6710835, 6723891, 6736947, 6750003, 6710886, 0, 102, 13158, 26214, 39270, 52326, 65382, 3342438, 3355494, 3368550, 3381606, 3394662, 3407718, 6684774, 6697830, 6710886, 6723942, 6736998, 6750054, 10066329, 0, 153, 13209, 26265, 39321, 52377, 65433, 3342489, 3355545, 3368601, 3381657, 3394713, 3407769, 6684825, 6697881, 6710937, 6723993, 6737049, 6750105, 13421772, 0, 204, 13260, 26316, 39372, 52428, 65484, 3342540, 3355596, 3368652, 3381708, 3394764, 3407820, 6684876, 6697932, 6710988, 6724044, 6737100, 6750156, 16777215, 0, 255, 13311, 26367, 39423, 52479, 65535, 3342591, 3355647, 3368703, 3381759, 3394815, 3407871, 6684927, 6697983, 6711039, 6724095, 6737151, 6750207, 16711680, 0, 10027008, 10040064, 10053120, 10066176, 10079232, 10092288, 13369344, 13382400, 13395456, 13408512, 13421568, 13434624, 16711680, 16724736, 16737792, 16750848, 16763904, 16776960, 65280, 0, 10027059, 10040115, 10053171, 10066227, 10079283, 10092339, 13369395, 13382451, 13395507, 13408563, 13421619, 13434675, 16711731, 16724787, 16737843, 16750899, 16763955, 16777011, 255, 0, 10027110, 10040166, 10053222, 10066278, 10079334, 10092390, 13369446, 13382502, 13395558, 13408614, 13421670, 13434726, 16711782, 16724838, 16737894, 16750950, 16764006, 16777062, 16776960, 0, 10027161, 10040217, 10053273, 10066329, 10079385, 10092441, 13369497, 13382553, 13395609, 13408665, 13421721, 13434777, 16711833, 16724889, 16737945, 16751001, 16764057, 16777113, 65535, 0, 10027212, 10040268, 10053324, 10066380, 10079436, 10092492, 13369548, 13382604, 13395660, 13408716, 13421772, 13434828, 16711884, 16724940, 16737996, 16751052, 16764108, 16777164, 16711935, 0, 10027263, 10040319, 10053375, 10066431, 10079487, 10092543, 13369599, 13382655, 13395711, 13408767, 13421823, 13434879, 16711935, 16724991, 16738047, 16751103, 16764159, 16777215 ]);
	public static inline var GRID_COLUMN : Int = 20;
	public static inline var GRID_ROW : Int = 12;
	public static inline var GRID_SIZE : Int = 12;

	@SkinPart
	public var hoverColorRect : Rect;

	/**
	 * [SkinPart]
	 */
	@SkinPart
	public var curColorDisplay : Rect;

	/**
	 * [SkinPart]
	 */
	@SkinPart
	public var curColorText : TextInput;

	/**
	 * [SkinPart]
	 */
	@SkinPart
	public var gridGroup : Group;

	private var _selectColor : UInt;

	public function new()
	{
		super();
	}

	override private function partAdded( partName : String, instance : Dynamic ) : Void
	{
		super.partAdded( partName, instance );

		if ( instance == curColorText )
		{
			curColorText.addEventListener( Event.CHANGE, onTextChange );
			curColorText.addEventListener( KeyboardEvent.KEY_DOWN, onEnterDown );
			curColorText.text = StringTools.hex(_selectColor);
		}
		else if ( instance == curColorDisplay )
		{
			curColorDisplay.fillColor = _selectColor;
		}
		else if ( instance == gridGroup )
		{
			gridGroup.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			gridGroup.addEventListener( MouseEvent.CLICK, onChooseColor );
		}
	}

	override private function partRemoved( partName : String, instance : Dynamic ) : Void
	{
		super.partRemoved( partName, instance );

		if ( instance == curColorText )
		{
			curColorText.removeEventListener( Event.CHANGE, onTextChange );
			curColorText.removeEventListener( KeyboardEvent.KEY_DOWN, onEnterDown );
		}
		else if ( instance == gridGroup )
		{
			gridGroup.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			gridGroup.removeEventListener( MouseEvent.CLICK, onChooseColor );
		}
	}

	override private function createChildren() : Void
	{
		super.createChildren();
	}

	private function onEnterDown( event : KeyboardEvent ) : Void
	{
		if ( event.keyCode == Keyboard.ENTER )
		{
			dispatchEvent( new Event( Event.SELECT ));
		}
	}

	private function onTextChange( event : Event ) : Void
	{
		var color : UInt = Std.parseInt( curColorText.text);

		curColorDisplay.fillColor = color;
		_selectColor = color;
	}

	private function checkSelect( x : Float, y : Float ) : Void
	{
		var column : Int = Math.floor( x  / GRID_SIZE);
		var row : Int = Math.floor( y  / GRID_SIZE);

		if ( column >= 0 && column < GRID_COLUMN && row >= 0 && row < GRID_ROW )
		{
			hoverColorRect.visible = true;
			hoverColorRect.x = column * GRID_SIZE;
			hoverColorRect.y = row * GRID_SIZE;

			var mouseRect : Rect = cast gridGroup.getElementAt( row * GRID_COLUMN + column );

			_selectColor = mouseRect.fillColor;

			curColorDisplay.fillColor = mouseRect.fillColor;
			curColorText.text = StringTools.hex(mouseRect.fillColor);
		}
		else
		{
			hoverColorRect.visible = false;
		}
	}

	private function mouseMoveHandler( event : MouseEvent ) : Void
	{
		checkSelect( event.localX, event.localY );
	}

	private function onChooseColor( event : MouseEvent ) : Void
	{
		checkSelect( event.localX, event.localY );

		dispatchEvent( new Event( Event.SELECT ));
	}

	public var selectColor(get, set):UInt;
	
	private function get_selectColor() : UInt
	{
		return _selectColor;
	}

	private function set_selectColor( value : UInt ) : UInt
	{
		_selectColor = value;
		if ( curColorDisplay != null )
			curColorDisplay.fillColor = _selectColor;
		if ( curColorText != null )
			curColorText.text = StringTools.hex(_selectColor);
		return _selectColor;
	}
}
