package BaseAssets
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class InstScreen extends MovieClip
	{
		private var closeAnywhere:Boolean = true;
		
		public function InstScreen() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.x = stage.stageWidth / 2;
			this.y = stage.stageHeight / 2;
			
			if (closeAnywhere) {
				this.gotoAndStop("END");
				this.addEventListener(MouseEvent.CLICK, closeScreen);
			}
			else {
				this.visible = false;
				closeButton.addEventListener(MouseEvent.CLICK, closeScreen);
			}
			
			stage.addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
		}
		
		private function escCloseScreen(e:KeyboardEvent):void 
		{
			if (e.keyCode ==  Keyboard.ESCAPE) {
				if (this.currentFrame == 1) closeScreen(null);
			}
		}
		
		private function closeScreen(e:MouseEvent):void 
		{
			if(closeAnywhere) this.play();
			else this.visible = false;
		}
		
		public function openScreen():void
		{
			if(closeAnywhere) this.gotoAndStop("BEGIN");
			else this.visible = true;
		}
		
	}

}