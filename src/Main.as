package 
{
	import BaseAssets.BaseMain;
	import com.adobe.serialization.json.JSON;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import cepa.utils.levenshteinDistance;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private var pontoCentral:Point = new Point(340, 450);
		private var pecas:Vector.<MovieClip> = new Vector.<MovieClip>();
		private var pecasCInner:Vector.<MovieClip> = new Vector.<MovieClip>();
		private var pecasFilters:Dictionary = new Dictionary();
		private var answers:Dictionary = new Dictionary();
		
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
			
			if (ExternalInterface.available) {
				initLMSConnection();
				if (mementoSerialized != null) {
					if (mementoSerialized != "" && mementoSerialized != "null") {
						status = JSON.decode(mementoSerialized);
						recoverStatus();
					}
				}
			}
			
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
			
			pecasCInner.push(corola1);
			pecasCInner.push(filete1);
			pecasCInner.push(antera3);
			pecasCInner.push(estigma);
			pecasCInner.push(estilete);
			pecasCInner.push(ovario);
			
			answers["corola1"] = ["pétala", "petala"];
			answers["filete1"] = ["filete"];
			answers["antera3"] = ["antera"];
			answers["estigma"] = ["estigma"];
			answers["estilete"] = ["estilete"];
			answers["ovario"] = ["ovario", "ovário"];
			
			answers["label_carpelo"] = ["carpelo", "gineceu"];
			answers["label_androceu"] = ["estame", "androceu"];
			answers["label_corola"] = ["corola"];
			
			pecasFilters["carpelo"] = [estigma, estilete, ovario];
			pecasFilters["androceu"] = [filete1, filete2, filete3, filete4, filete5, filete6, antera1, antera2, antera3, antera4, antera5, antera6];
			pecasFilters["corola"] = [corola1, corola2, corola3, corola4, corola5];
		}
		
		private function addListeners():void 
		{
			for each (var peca:MovieClip in pecasCInner) 
			{
				peca.inner.mouseEnabled = false;
			}
			
			for each (peca in pecas) 
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
			feedbackScreen.addEventListener(Event.CLOSE, closeFeedback);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		private function keyUpHandler(e:KeyboardEvent):void 
		{
			if (e.target.name == "label") saveStatus();
		}
		
		private function closeFeedback(e:Event):void 
		{
			alowRemoveFilter = true;
		}
		
		private var alowRemoveFilter:Boolean = true;
		private function stageClick(e:MouseEvent):void 
		{
			if (!alowRemoveFilter) return;
			if(e.target.parent != label_carpelo && e.target.parent != label_androceu && e.target.parent != label_corola) removeFilters();
		}
		
		private function removeFilters():void 
		{
			for each (var item:MovieClip in pecas) 
			{
				item.alpha = 1;
				item.filters = [];
			}
			
			for each (item in pecasCInner) 
			{
				item.inner.filters = [];
			}
			
			base.alpha = 1;
			base.filters = [];
			
			for each (item in pecasCInner) 
			{
				item.label.filters = [];
			}
			
			label_carpelo.filters = [];
			label_androceu.filters = [];
			label_corola.filters = [];
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
		private var posClickLocal:Point = new Point();
		private var posMeioRect:Point = new Point();
		private function initDrag(e:MouseEvent):void 
		{
			if (e.target is TextField) return;
			
			pecaDragging = MovieClip(e.target);
			posClickLocal.x = pecaDragging.mouseX;
			posClickLocal.y = pecaDragging.mouseY;
			var rectPeca:Rectangle;
			if (pecasCInner.indexOf(pecaDragging) >= 0) rectPeca = pecaDragging.inner.getBounds(stage);
			else rectPeca = pecaDragging.getBounds(stage);
			posMeioRect.x = pecaDragging.x - (rectPeca.x + rectPeca.width / 2);
			posMeioRect.y = pecaDragging.y - (rectPeca.y + rectPeca.height / 2);
			//pecaDragging.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, movingPeca);
		}
		
		private function movingPeca(e:MouseEvent):void 
		{
			pecaDragging.x = Math.max(posMeioRect.x + 5, Math.min(stage.stageWidth + posMeioRect.x - 5, stage.mouseX - posClickLocal.x));
			pecaDragging.y = Math.max(posMeioRect.y + 5, Math.min(stage.stageHeight+ posMeioRect.y - 5, stage.mouseY - posClickLocal.y));
		}
		
		private function stopDragging(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingPeca);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			pecaDragging.stopDrag();
			saveStatus();
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
		private var rightFilter:GlowFilter = new GlowFilter(0x00BF00, 0.8, 6, 6, 3, 2);
		private var wrongFilter:GlowFilter = new GlowFilter(0xFF0000, 0.8, 6, 6, 3, 2);
		
		private var nCertas:int;
		private var nErradas:int;
		private var nTotal:int;
		
		private function finishExercise(e:MouseEvent):void 
		{
			alowRemoveFilter = false;
			if (!verificaTerminei()) {
				feedbackScreen.setText("Você precisa digitar todas as respostas para finalizar a atividade.");
				return;
			}
			
			nCertas = 0;
			nErradas = 0;
			nTotal = 0;
			var filetes:Array = ["filete1", "filete2", "filete3", "filete4", "filete5", "filete6"];
			var anteras:Array = ["antera1", "antera2", "antera3", "antera4", "antera5", "antera6"];
			var filetesToCompare:Array = [filete1, filete2, filete3, filete4, filete5, filete6];
			
			for each (var peca:MovieClip in pecas) 
			{
				if (filetes.indexOf(peca.name) >= 0) {
					addFilter(peca, MovieClip(ovarioResp).hitTestPoint(peca.x, peca.y));
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
					
					addFilter(peca, fileteFound);
				}else{
					addFilter(peca, Point.distance(new Point(peca.x, peca.y), pontoCentral) < maxDist);
				}
			}
			
			for each (var item:MovieClip in pecasCInner) 
			{
				var userAns:String = String(item.label.label.text).toLowerCase();
				var acertou:Boolean = false;
				lookStr: for each (var itemStr:String in answers[item.name]) 
				{
					if (compareString(itemStr, userAns) <= 1) {
						acertou = true;
						break lookStr;
					}
				}
				addFilter(item.label, acertou);
			}
			
			addFilter(label_carpelo, (compareString(label_carpelo.label.text, answers["label_carpelo"]) <= 1));
			addFilter(label_androceu, (compareString(label_androceu.label.text, answers["label_androceu"]) <= 1));
			addFilter(label_corola, (compareString(label_corola.label.text, answers["label_corola"]) <= 1));
			
			score = Math.round(nCertas / nTotal);
			
			if (score >= 99) {
				feedbackScreen.setText("Parabéns, você acertou!");
			}else {
				feedbackScreen.setText("Tem alguma coisa errada. Observe as peças destacadas em vermelho e tente responder novamente.");
			}
			
		}
		
		private function verificaTerminei():Boolean 
		{
			var finish:Boolean = true;
			
			lookStr: for each (var item:MovieClip in pecasCInner) 
			{
				if (item.label.label.text == "") {
					finish = false;
					break lookStr;
				}
			}
			
			if (label_carpelo.label.text == "") finish = false;
			if (label_androceu.label.text == "") finish = false;
			if (label_corola.label.text == "") finish = false;
			
			return finish;
		}
		
		private function compareString(str1:String, str2:String):int
		{
			//return (str1 == str2 ? 0 : 2);
			return levenshteinDistance(str1, str2);
		}
		
		private function addFilter(peca:*, value:Boolean):void
		{
			var inner:Boolean = false;
			if (pecasCInner.indexOf(peca) >= 0) inner = true;
			
			if (value) {
				nCertas++;
				if (inner) peca.inner.filters = [rightFilter];
				else peca.filters = [rightFilter];
			}else {
				nErradas++;
				if (inner) peca.inner.filters = [wrongFilter];
				else peca.filters = [wrongFilter];
			}
			nTotal++;
		}
		
		private function removeAnswers():void
		{
			for each (var item:MovieClip in pecasCInner) 
			{
				item.label.label.text = "";
			}
			
			label_carpelo.label.text = "";
			label_androceu.label.text = "";
			label_corola.label.text = "";
		}
		
		private var status:Object = { };
		private function saveStatusForRecovery():void
		{
			status.positions = { };
			status.texts = { };
			
			for each (var item:MovieClip in pecas) 
			{
				status.positions[item.name] = { };
				status.positions[item.name].x = item.x;
				status.positions[item.name].y = item.y;
			}
			
			for each (item in pecasCInner) 
			{
				status.texts[item.name] = item.label.label.text;
			}
			
			status.texts.label_carpelo = label_carpelo.label.text;
			status.texts.label_androceu = label_androceu.label.text;
			status.texts.label_corola = label_corola.label.text;
			
			mementoSerialized = JSON.encode(status);
		}
		
		private function recoverStatus():void
		{
			for each (var item:MovieClip in pecas) 
			{
				item.x = status.positions[item.name].x;
				item.y = status.positions[item.name].y;
			}
			
			for each (item in pecasCInner) 
			{
				item.label.label.text = status.texts[item.name];
			}
			
			label_carpelo.label.text = status.texts.label_carpelo;
			label_androceu.label.text = status.texts.label_androceu;
			label_corola.label.text = status.texts.label_corola;
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			removeAnswers();
			randomizePositions();
			saveStatus();
		}
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			
		}
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int = 0;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				
				if (scorm.get("cmi.mode" != "normal")) return;
				
				scorm.set("cmi.exit", "suspend");
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				mementoSerialized = scorm.get("cmi.suspend_data");
				var stringScore:String = scorm.get("cmi.score.raw");
				
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
				mementoSerialized = ExternalInterface.call("getLocalStorageString");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				if (scorm.get("cmi.mode" != "normal")) return;
				
				// Salva no LMS a nota do aluno.
				var success:Boolean;// = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));
				
				//success = scorm.set("cmi.exit", (completed ? "normal" : "suspend"));
				
				//Notifica o LMS se o aluno passou ou falhou na atividade, de acordo com a pontuação:
				success = scorm.set("cmi.success_status", (score > 75 ? "passed" : "failed"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}else { //LocalStorage
				ExternalInterface.call("save2LS", mementoSerialized);
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			//commit();
			saveStatus();
		}
		
		private function saveStatus(e:Event = null):void
		{
			if (ExternalInterface.available) {
				if (connected) {
					
					if (scorm.get("cmi.mode" != "normal")) return;
					
					saveStatusForRecovery();
					scorm.set("cmi.suspend_data", mementoSerialized);
					commit();
				}else {//LocalStorage
					saveStatusForRecovery();
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
	}

}