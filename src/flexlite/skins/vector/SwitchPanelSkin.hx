package flexlite.skins.vector;

import flexlite.components.Group;
import flexlite.components.Rect;
import flexlite.components.SwitchPanel;
import flexlite.components.TextInput;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.HorizontalLayout;
import flexlite.layouts.VerticalAlign;
import flexlite.layouts.VerticalLayout;
import flexlite.skins.VectorSkin;

class SwitchPanelSkin extends VectorSkin
{
	public var curColorDisplay : Rect;
	
	public var curColorText : TextInput;
	
	public var gridGroup:Group;
	
	public var hoverColorRect:Rect;
	
	public function new()
	{
		super();
	}
	
	override private function createChildren():Void
	{
		super.createChildren();
		
		this.mouseEnabled = false;
		this.mouseChildren = true;
		
		var vLayout : VerticalLayout = new VerticalLayout();
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		this.layout = vLayout;
		
		
		var topGroup : Group = new Group();
		var hLayout : HorizontalLayout = new HorizontalLayout();
		hLayout.verticalAlign = VerticalAlign.JUSTIFY;
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		topGroup.layout = hLayout;
		
		curColorDisplay = new Rect();
		curColorDisplay.mouseChildren = false;
		curColorDisplay.mouseEnabled = false;
		curColorDisplay.strokeColor = 0xFFFFFF;
		curColorDisplay.strokeAlpha = 1;
		curColorDisplay.strokeWeight = 1;
		curColorDisplay.fillAlpha = 1;
		curColorDisplay.fillColor = 0;
		curColorDisplay.minHeight = SwitchPanel.GRID_SIZE;
		curColorDisplay.minWidth = SwitchPanel.GRID_SIZE * 5;
		
		curColorText = new TextInput();
		curColorText.width = 80;
		curColorText.maxChars = 6;
		curColorText.textColor = 0x0;
		curColorText.restrict = "0-9a-fA-F";
		
		
		topGroup.addElement( curColorDisplay );
		topGroup.addElement( curColorText );
		
		gridGroup = new Group();
		
		for ( i in 0...SwitchPanel.GRID_ROW)
		{
			for ( j in 0...SwitchPanel.GRID_COLUMN)
			{
				var rect : Rect = new Rect();
				rect.mouseChildren = false;
				rect.mouseEnabled = false;
				rect.width = SwitchPanel.GRID_SIZE;
				rect.height = SwitchPanel.GRID_SIZE;
				
				rect.x = j * SwitchPanel.GRID_SIZE;
				rect.y = i * SwitchPanel.GRID_SIZE;
				
				rect.strokeColor = 0x0;
				rect.strokeAlpha = 1;
				rect.strokeWeight = 1;
				rect.fillAlpha = 1;
				rect.fillColor = SwitchPanel.SWITCH_COLORS[ i * SwitchPanel.GRID_COLUMN + j ];
				
				gridGroup.addElement( rect );
			}
		}
		
		hoverColorRect = new Rect();
		hoverColorRect.mouseChildren = false;
		hoverColorRect.mouseEnabled = false;
		hoverColorRect.width = SwitchPanel.GRID_SIZE;
		hoverColorRect.height = SwitchPanel.GRID_SIZE;
		hoverColorRect.strokeColor = 0xFFFFFF;
		hoverColorRect.strokeAlpha = 1;
		hoverColorRect.strokeWeight = 2;
		hoverColorRect.fillAlpha = 0;
		hoverColorRect.fillColor = 0xFFFFFF;
		hoverColorRect.visible = false;
		gridGroup.addElement( hoverColorRect );
		
		gridGroup.width = SwitchPanel.GRID_SIZE * SwitchPanel.GRID_COLUMN;
		gridGroup.height = SwitchPanel.GRID_SIZE * SwitchPanel.GRID_ROW;
		
		this.addElement( topGroup );
		this.addElement( gridGroup );
	}
}


