package example;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.Lib;
import flexlite.collections.ObjectCollection;
import flexlite.collections.XMLCollection;
import flexlite.components.Tree;
import flexlite.components.UIAsset;
import flexlite.dxr.RepeatBitmap;
import flexlite.dxr.DxrBitmap;
import flexlite.dxr.DxrMovieClip;
import flexlite.dxr.Scale9GridBitmap;
import flexlite.dxr.DxrShape;
import flexlite.dxr.codec.DxrDecoder;
import flexlite.dll.Dll;

/**
 * ...
 * @author weilichuang
 */
class RepeatBitmapTest extends AppContainer
{
	static function main() 
	{
		var test:RepeatBitmapTest = new RepeatBitmapTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}
	
	override private function createChildren():Void
	{
		super.createChildren();
		
		
		var ui:UIAsset = new UIAsset();
		var bitmap:RepeatBitmap = new RepeatBitmap(null,graphics);
		bitmap.bitmapData = new REPEAT(0,0);
		ui.skinName = bitmap;
		addElement(ui);
		ui.percentHeight = ui.percentWidth = 100;
	}
}


@:bitmap("../asset/wood.jpg") class REPEAT extends BitmapData { }
