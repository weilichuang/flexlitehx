package;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.Lib;
import flexlite.collections.ObjectCollection;
import flexlite.collections.XMLCollection;
import flexlite.components.Tree;

/**
 * ...
 * @author weilichuang
 */
class TreeTest extends AppContainer
{
	static function main() 
	{
		var test:TreeTest = new TreeTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}
	
	override private function createChildren():Void
	{
		super.createChildren();
		
		
		var dp:XMLCollection = new XMLCollection();
		
		var xml:Xml = Xml.parse("<root>
						<item dir='true' name='XML数据源0'>
							<item name='XML数据源00'/>
							<item dir='true' name='XML数据源01'>
								<item name='XML数据源000'/>
							</item>
						</item>
						<item dir='true' name='XML数据源1'/>
						<item name='XML数据源2'/>
					</root>");
			
		dp.source = xml;
		
		var tree:Tree = new Tree();
		tree.labelField = "name";
		tree.iconFunction = iconFunc;
		tree.dataProvider = dp;
		addElement(tree);
		
		var tree2:Tree = new Tree();
		var dp2:ObjectCollection = new ObjectCollection();
		
		var obj:Dynamic = { };
		var children:Array<Dynamic> = [];
		
		var obj2:Dynamic = { };
		obj2.dir = true;
		obj2.name = "Object数据源0";
		var children2:Array<Dynamic> = [];
		children2.push( { dir:false, name:"Object数据源00" } );
		children2.push( { dir:true, name:"Object数据源01", children:[ { dir:false, name:"Object数据源000" } ] } );
		obj2.children = children2;
		
		children.push(obj2);
		children.push({dir:true,name:"Object数据源1",children:[]});
		children.push({dir:false,name:"Object数据源2"});
		
		obj.children = children;
		
		dp2.source = obj;
		ObjectCollection.assignParent(dp2.source);
		tree2.labelField = "name";
		tree2.iconFunction = iconFunc;
		tree2.dataProvider = dp2;
		tree2.x = 200;
		addElement(tree2);
	}

	private function iconFunc(item:Dynamic):Dynamic
	{
		if(Std.is(item,Xml))
		{
			var xml:Xml = cast item;
			if(xml.get("dir") == "true")
				return new Bitmap(new DIR(0,0)) ;
			return new Bitmap(new FILE(0,0));
		}
		else
		{
			if(item.dir)
				return new Bitmap(new DIR(0,0));
			return new Bitmap(new FILE(0,0));
		}
	}
}


@:bitmap("resource/dir.gif") class DIR extends BitmapData { }
@:bitmap("resource/file.png") class FILE extends BitmapData {}
