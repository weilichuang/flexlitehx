package flexlite.skins.themes;


import flexlite.core.Theme;
import flexlite.skins.vector.AlertSkin;
import flexlite.skins.vector.ButtonSkin;
import flexlite.skins.vector.CheckBoxSkin;
import flexlite.skins.vector.ComboBoxSkin;
import flexlite.skins.vector.DropDownListSkin;
import flexlite.skins.vector.HScrollBarSkin;
import flexlite.skins.vector.HSliderSkin;
import flexlite.skins.vector.IconButtonSkin;
import flexlite.skins.vector.ItemRendererSkin;
import flexlite.skins.vector.ListSkin;
import flexlite.skins.vector.NumericStepperSkin;
import flexlite.skins.vector.PageNavigatorSkin;
import flexlite.skins.vector.PanelSkin;
import flexlite.skins.vector.ProgressBarSkin;
import flexlite.skins.vector.RadioButtonSkin;
import flexlite.skins.vector.ScrollerSkin;
import flexlite.skins.vector.SpinnerSkin;
import flexlite.skins.vector.SwitchPanelSkin;
import flexlite.skins.vector.TabBarButtonSkin;
import flexlite.skins.vector.TabBarSkin;
import flexlite.skins.vector.TabNavigatorSkin;
import flexlite.skins.vector.TextAreaSkin;
import flexlite.skins.vector.TextInputSkin;
import flexlite.skins.vector.TitleWindowSkin;
import flexlite.skins.vector.ToggleButtonSkin;
import flexlite.skins.vector.TreeItemRendererSkin;
import flexlite.skins.vector.VScrollBarSkin;
import flexlite.skins.vector.VSliderSkin;
import flexlite.skins.vector.ColorPickerSkin;


/**
* Vector主题皮肤默认配置
* @author weilichuang
*/
class VectorTheme extends Theme
{
    public function new()
    {
        super();
        apply();
    }
    
    private function apply() : Void
    {
        mapSkin("flexlite.components.Alert", AlertSkin);
        mapSkin("flexlite.components.Button", ButtonSkin);
        mapSkin("flexlite.components.CheckBox", CheckBoxSkin);
        mapSkin("flexlite.components.ComboBox", ComboBoxSkin);
        mapSkin("flexlite.components.DropDownList", DropDownListSkin);
        mapSkin("flexlite.components.HScrollBar", HScrollBarSkin);
        mapSkin("flexlite.components.HSlider", HSliderSkin);
        mapSkin("flexlite.components.List", ListSkin);
        mapSkin("flexlite.components.PageNavigator", PageNavigatorSkin);
        mapSkin("flexlite.components.Panel", PanelSkin);
        mapSkin("flexlite.components.ProgressBar", ProgressBarSkin);
        mapSkin("flexlite.components.RadioButton", RadioButtonSkin);
        mapSkin("flexlite.components.Scroller", ScrollerSkin);
        mapSkin("flexlite.components.TabBar", TabBarSkin);
        mapSkin("flexlite.components.TabBarButton", TabBarButtonSkin);
        mapSkin("flexlite.components.TabNavigator", TabNavigatorSkin);
        mapSkin("flexlite.components.TextArea", TextAreaSkin);
        mapSkin("flexlite.components.TextInput", TextInputSkin);
        mapSkin("flexlite.components.TitleWindow", TitleWindowSkin);
        mapSkin("flexlite.components.ToggleButton", ToggleButtonSkin);
        mapSkin("flexlite.components.Tree", ListSkin);
        mapSkin("flexlite.components.supportclasses.TreeItemRenderer", TreeItemRendererSkin);
        mapSkin("flexlite.components.VScrollBar", VScrollBarSkin);
        mapSkin("flexlite.components.VSlider", VSliderSkin);
        mapSkin("flexlite.components.supportclasses.ItemRenderer", ItemRendererSkin);
		
		mapSkin( "flexlite.components.Spinner", SpinnerSkin );
		mapSkin( "flexlite.components.NumericStepper", NumericStepperSkin );
		mapSkin( "flexlite.components.IconButton", IconButtonSkin );
		mapSkin( "flexlite.components.SwitchPanel", SwitchPanelSkin );
		mapSkin( "flexlite.components.ColorPicker", ColorPickerSkin );
    }
}
