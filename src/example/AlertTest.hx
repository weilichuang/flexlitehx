package example;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.components.Alert;
import flexlite.events.CloseEvent;

/**
 * ...
 * @author weilichuang
 */
class AlertTest extends AppContainer
{
	static function main()
	{
		var test:AlertTest = new AlertTest();
		Lib.current.addChild(test);
	}

	public function new()
	{
		super();
	}

	override private function onAddedToStage(event : Event) : Void
	{
		super.onAddedToStage(event);
		this.stage.addEventListener(MouseEvent.CLICK, onClick);
	}

	private function onClick(event:MouseEvent):Void
	{
		var target:DisplayObject = Lib.as(event.target,DisplayObject);
		while (target != null)
		{
			if (Std.is(target,Alert))
				return;
			target = target.parent;
		}
		Alert.show("导读：和许多新兴的网站一样，著名的轻博客服务Tumblr在急速发展中面临了系统架构的瓶颈。每天5亿次浏览量，峰值每秒4万次请求，每天3TB新的数据存储，超过1000台服务器，这样的情况下如何保证老系统平稳运行，平稳过渡到新的系统，Tumblr正面临巨大的挑战。近日，HighScalability网站的Todd Hoff采访了该公司的分布式系��工程师Blake Matheny，撰文系统介绍了网站的架构，内容很有价值。我们也非常希望国内的公司和团队多做类似分享，贡献于社区的同时，更能提升自身的江湖地位，对招聘、业务发展都好处多多。欢迎通过@CSDN云计算的微博向我们投稿。","提示",
		onClose,"确定");
	}

	private function onClose(event:CloseEvent):Void
	{
		Lib.trace("event.detail:" + event.detail);
	}
}