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
		
		private var caixaLabels:CaixaTexto = new CaixaTexto(true);
		private var comCaixa:Boolean = false;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(caixaLabels);
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
			
			iniciaTutorial();
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
			pecas.push(sepala1);
			pecas.push(sepala2);
			pecas.push(ovulo);
			pecas.push(base);
			
			pecasCInner.push(corola1);
			pecasCInner.push(filete1);
			pecasCInner.push(antera3);
			pecasCInner.push(estigma);
			pecasCInner.push(estilete);
			pecasCInner.push(ovario);
			pecasCInner.push(sepala2);
			pecasCInner.push(ovulo);
			
			answers["corola1"] = ["pétala", "petala"];
			answers["filete1"] = ["filete"];
			answers["antera3"] = ["antera"];
			answers["estigma"] = ["estigma"];
			answers["estilete"] = ["estilete"];
			answers["ovario"] = ["ovario", "ovário"];
			answers["sepala2"] = ["sepala", "sépala"];
			answers["ovulo"] = ["ovulo", "óvulo"];
			
			pecasFilters["androceu"] = [filete1, filete2, filete3, filete4, filete5, filete6, antera1, antera2, antera3, antera4, antera5, antera6];
			pecasFilters["gineceu"] = [estigma, estilete, ovario, ovulo];
			pecasFilters["corola"] = [corola1, corola2, corola3, corola4, corola5];
			pecasFilters["calice"] = [base, sepala1, sepala2];
		}
		
		private function addListeners():void 
		{
			for each (var peca:MovieClip in pecasCInner) 
			{
				peca.inner.mouseEnabled = false;
				peca.inner.buttonMode = true;
				//peca.label.fundoLabel.mouseEnabled = false;
			}
			
			for each (peca in pecas) 
			{
				if(peca != base){
					peca.addEventListener(MouseEvent.MOUSE_DOWN, initDrag);
					peca.buttonMode = true;
				}
			}
			
			makeOverOut(label_androceu);
			makeOverOut(label_gineceu);
			makeOverOut(label_corola);
			makeOverOut(label_calice);
			
			finaliza.addEventListener(MouseEvent.CLICK, finishExercise);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageClick);
			feedbackScreen.addEventListener(Event.CLOSE, closeFeedback);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		private function makeOverOut(label:*):void
		{
			label.addEventListener(MouseEvent.MOUSE_OVER, selectLabel);
			label.addEventListener(MouseEvent.MOUSE_OUT, unselectLabel);
			//label.buttonMode = true;
		}
		
		private function keyUpHandler(e:KeyboardEvent):void 
		{
			if (e.target.name == "label") saveStatus();
		}
		
		private function closeFeedback(e:Event):void 
		{
			alowRemoveFilter = true;
		}
		
		private var alowRemoveFilter:Boolean = false;
		private function stageClick(e:MouseEvent):void 
		{
			if (!alowRemoveFilter) return;
			alowRemoveFilter = false;
			removeFilters();
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
			
		}
		
		private var groupFilter:GlowFilter = new GlowFilter(0x0000FF);
		private function selectLabel(e:MouseEvent):void 
		{
			removeFilters();
			var labelName:String = String(e.target.name).replace("label_", "");
			
			if(comCaixa){
				if (labelName == "androceu") {
					caixaLabels.setText("Compõe o Androceu.", CaixaTexto.LEFT, CaixaTexto.CENTER);
					caixaLabels.setPosition(label_androceu.x - 5, label_androceu.y + 12);
				}else if (labelName == "gineceu") {
					caixaLabels.setText("Compõe o Gineceu.", CaixaTexto.LEFT, CaixaTexto.CENTER);
					caixaLabels.setPosition(label_androceu.x - 5, label_gineceu.y + 12);
				}
			}
			
			for each (var item:MovieClip in pecas) 
			{
				if(pecasFilters[labelName].indexOf(item) < 0){
					item.alpha = 0.2;
					item.filters = [GRAYSCALE_FILTER];
				}
			}
		}
		
		private function unselectLabel(e:MouseEvent):void
		{
			if(comCaixa) caixaLabels.visible = false;
			removeFilters();
		}
		
		private var pecaDragging:MovieClip;
		private var posClickLocal:Point = new Point();
		private var posMeioRect:Point = new Point();
		private function initDrag(e:MouseEvent):void 
		{
			if (e.target is TextField) return;
			
			if(e.target.name == "fundoLabel") return;
			
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
			
			verificaPosicaoPecaDragging(pecaDragging);
			
			saveStatus();
		}
		
		private function verificaPosicaoPecaDragging(pecaDragging:MovieClip):void 
		{
			var filetes:Array = ["filete1", "filete2", "filete3", "filete4", "filete5", "filete6"];
			var anteras:Array = ["antera1", "antera2", "antera3", "antera4", "antera5", "antera6"];
			
			for each (var peca:MovieClip in pecas) 
			{
				if(peca == pecaDragging){
					if(filetes.indexOf(peca.name) < 0 && anteras.indexOf(peca.name) < 0){
						if (Point.distance(new Point(peca.x, peca.y), pontoCentral) < maxDist) {
							pecaDragging.x = pontoCentral.x;
							pecaDragging.y = pontoCentral.y;
						}
					}
				}
			}
		}
		
		private function randomizePositions():void 
		{
			for each (var peca:MovieClip in pecas) 
			{
				if (peca != base) {
					if (peca.name == "estigma") {
						peca.x = Math.random() * 500 + 100;
						peca.y = Math.random() * 230 + 320;
					}else{
						peca.x = Math.random() * 500 + 100;
						peca.y = Math.random() * 400 + 150;
					}
				}
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
			
			score = Math.round((nCertas / nTotal) * 100);
			
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
			
			return finish;
		}
		
		private function compareString(str1:String, str2:String):int
		{
			//return 1;
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
			
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			removeAnswers();
			randomizePositions();
			saveStatus();
		}
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Monte a flor arrastando as peças.", 
										  "Escreva o nome de cada peça que possui um campo de texto como esse.",
										  "Ao passar o mouse sobre essas caixas de texto um grupo de peças será destacado.",
										  "Ao terminar de montar e classificar clique aqui para avaliar sua resposta."];
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(250, 300),
								new Point(473 , 542),
								new Point(450 , 42),
								new Point(55 , 35)];
								
				tutoBaloonPos = [["", ""],
								[CaixaTexto.BOTTON, CaixaTexto.LAST],
								[CaixaTexto.RIGHT, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.FIRST]];
			}
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
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