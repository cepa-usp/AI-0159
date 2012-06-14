package 
{
	import BaseAssets.BaseMain;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private var pontoCentral:Point = new Point(340, 450);
		private var pecas:Vector.<MovieClip> = new Vector.<MovieClip>();
		private var pecasFilters:Dictionary = new Dictionary();
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			groupPieces();
			addListeners();
			randomizePositions();
		}
		
		private function groupPieces():void 
		{
			pecas.push(corola1);
			pecas.push(corola2);
			pecas.push(corola3);
			pecas.push(corola4);
			pecas.push(corola5);
			pecas.push(filete1);
			pecas.push(filete2);
			pecas.push(filete3);
			pecas.push(filete4);
			pecas.push(filete5);
			pecas.push(filete6);
			pecas.push(ovario);
			pecas.push(estilete);
			pecas.push(estigma);
			pecas.push(antera1);
			pecas.push(antera2);
			pecas.push(antera3);
			pecas.push(antera4);
			pecas.push(antera5);
			pecas.push(antera6);
			
			pecasFilters["carpelo"] = [estigma, estilete, ovario];
			pecasFilters["androceu"] = [filete1, filete2, filete3, filete4, filete5, filete6, antera1, antera2, antera3, antera4, antera5, antera6];
			pecasFilters["corola"] = [corola1, corola2, corola3, corola4, corola5];
		}
		
		private function addListeners():void 
		{
			for each (var peca:MovieClip in pecas) 
			{
				peca.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			}
			/*
			corola1.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			corola2.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			corola3.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			corola4.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			corola5.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			filete1.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			filete2.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			filete3.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			filete4.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			filete5.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			filete6.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			ovario.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			estilete.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			estigma.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
			*/
			
			label_carpelo.addEventListener(MouseEvent.MOUSE_DOWN, selectLabel);
			label_androceu.addEventListener(MouseEvent.MOUSE_DOWN, selectLabel);
			label_corola.addEventListener(MouseEvent.MOUSE_DOWN, selectLabel);
			
			finaliza.addEventListener(MouseEvent.CLICK, finishExercise);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageClick);
		}
		
		private function stageClick(e:MouseEvent):void 
		{
			if(e.target.parent != label_carpelo && e.target.parent != label_androceu && e.target.parent != label_corola) removeFilters();
		}
		
		private function removeFilters():void 
		{
			for each (var item:MovieClip in pecas) 
			{
				item.alpha = 1;
				item.filters = [];
			}
			base.alpha = 1;
			base.filters = [];
		}
		
		private var groupFilter:GlowFilter = new GlowFilter(0x0000FF);
		private function selectLabel(e:MouseEvent):void 
		{
			removeFilters();
			var labelName:String = String(e.target.parent.name).replace("label_", "");
			
			for each (var item:MovieClip in pecas) 
			{
				if(pecasFilters[labelName].indexOf(item) < 0){
					item.alpha = 0.2;
					item.filters = [GRAYSCALE_FILTER];
				}
			}
			base.alpha = 0.2;
			base.filters = [GRAYSCALE_FILTER];
		}
		
		private var pecaDragging:MovieClip;
		private function initDrag(e:MouseEvent):void 
		{
			if (e.target is TextField) return;
			
			pecaDragging = MovieClip(e.target);
			pecaDragging.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private function stopDragging(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			pecaDragging.stopDrag();
		}
		
		private function randomizePositions():void 
		{
			for each (var peca:MovieClip in pecas) 
			{
				peca.x = Math.random() * 250 + 200;
				peca.y = Math.random() * 150 + 350;
			}
		}
		
		private var maxDist:Number = 20;
		private var rightFilter:GlowFilter = new GlowFilter(0x008000);
		private var wrongFilter:GlowFilter = new GlowFilter(0xFF0000);
		
		private function finishExercise(e:MouseEvent):void 
		{
			var nCertas:int = 0;
			var nErradas:int = 0;
			var filetes:Array = ["filete1", "filete2", "filete3", "filete4", "filete5", "filete6"];
			var anteras:Array = ["antera1", "antera2", "antera3", "antera4", "antera5", "antera6"];
			var filetesToCompare:Array = [filete1, filete2, filete3, filete4, filete5, filete6];
			
			for each (var peca:MovieClip in pecas) 
			{
				if (filetes.indexOf(peca.name) >= 0) {
					if (MovieClip(ovarioResp).hitTestPoint(peca.x, peca.y)) {
						nCertas++;
						peca.filters = [rightFilter];
					}else {
						nErradas++;
						peca.filters = [wrongFilter];
					}
				}else if (anteras.indexOf(peca.name) >= 0) {
					
					var fileteFound:Boolean = false;
					lookFilete: for (var i:int = 0; i < filetesToCompare.length; i++) 
					{
						if (peca.hitTestObject(MovieClip(filetesToCompare[i]))) {
							fileteFound = true;
							filetesToCompare.splice(i, 1);
							break lookFilete;
						}
					}
					
					if (fileteFound)
					{
						nCertas++;
						peca.filters = [rightFilter];
					}else {
						nErradas++;
						peca.filters = [wrongFilter];
					}
				}else{
					if (Point.distance(new Point(peca.x, peca.y), pontoCentral) < maxDist) {
						nCertas++;
						peca.filters = [rightFilter];
					}else {
						nErradas++;
						peca.filters = [wrongFilter];
					}
				}
			}
		}
		
		
		
		override public function reset(e:MouseEvent = null):void
		{
			
		}
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			
		}
	}

}