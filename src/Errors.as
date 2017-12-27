package  
{
	import api.ExternalApi;
	import core.Post;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import ui.UserInterface;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Errors
	{
		
		public static var data:Object = {
			   1:'Обнаружены признаки читерства!',// 'ARE_YOU_HACKER',
			   2:'Не могу загрузить игровые данные',
			   3:'Нет данных',
			   4:'Обнаружены признаки читерства!',
			   5:'Некорректный ID запроса',
			   6:'Неизвестный контролер',
			   7:'Неизвестное действие',
			   8:'Неизвестный пользователь',
			   9:'Неизвестный сон',
			   10:'Не удалось загрузить профиль игрока',
			   11:'Не удалось загрузить профиль сна',
			   12:'Не удалось загрузить данные склада',
			   13:'Неизвестный идентификатор объекта',
			   14:'Неправильные координаты',
			   15:'Неизвестный идентификатор на карте',
			   16:'Загрузка склада не удалась',//'CANT_TAKE_STOCK',
			   17:'Нечего продавать',
			   18:'Не хватает денег',//'NOT_ENAUGH_MONEY',
			   19:'Не хватает материалов',//'NOT_ENAUGH_ITEMS'
			   20:'Ошибочный уровень',//'WRONG_LEVEL',
			   21:'Нечего покупать',
			   22:'Не удалось загрузить данные склада',
			   23:'Необходимые материалы не найдены на складе',//'NOT_ENAUGH_MATERIALS',
			   24:'Неизвестный идентификатор растения',
			   25:'Растение еще не созрело для сбора',
			   26:'Поле уже занято',
			   29:'Неизвестный рецепт',
			   30:'Рецепт еще не готов',
			   31:'Не удалось загрузить модель данных',
			   32:'Лист желаний уже полный',
			   33:'Лист желаний пустой',
			   34:'Неверное состояние существа',
			   35:'ANIMAL_IS_FULL',
			   36:'ANIMAL_NOT_IS_FULL',
			   37:'Существо еще не готово выдать бонус',
			   38:'Неизвестный идентификатор друга',
			   39:'Неизвестная роль',
			   40:'На этой стадии еще нельзя нанимать друзей',
			   41:'WRONG_COUNT_TO_HIRE',
			   42:'Не удалось найти друга',
			   43:'Не удалось уволить друга',
			   44:'Не удалось освободить роль',
			   45:'Не удалось забрать энергию',
			   46:'Роль уже занята',
			   47:'Не удалось загрузить данные друзей',
			   48:'Коллекция еще не полная для обмена',
			   49:'Неизвестный идентификатор подарков',
			   50:'Не удалось отправить бесплатный подарок',
			   51:'Количество задано не верно',
			   52:'Неизвестный тип',
			   53:'Некому отсылать',
			   54:'Невозможно обработать JSON данные',
			   55:'Подарок имеет не верный тип',
			   56:'Не удалось найти подарок',
			   57:'Неизвестный идентификатор варенья',
			   58:'Неизвестный идентификатор работы',
			   59:'Не удалось идентифицировать цель работы',
			   60:'Не возможно работать с целью',
			   61:'Неизвестный медведь',
			   62:'Не удалось найти',
			   63:'Цель занята',
			   64:'Медведь уже нанят в другое здание',
			   65:'Медведь уже работает с целью',
			   66:'Нечего собрать',
			   67:'Еще не готово',
			   68:'Неизвестный гость',
			   69:'Исчерпан лимит на гостевую энергию',
			   70:'Не удалось помощь',
			   71:'Параметры переданы некорректно или не полностью',
			   72:'Передано неверное время',
			   73:'Не удалось загрузить данные открытых позиций',
			   74:'Неизвестный квест',
			   75:'Неизвестная миссия',
			   76:'Не удалось загрузить данные квестов',
			   77:'Неизвестная зона',
			   78:'Не верно указан квест',
			   79:'У друга превышен лимит подарков',
			   1000:'Связь с сервером прервана, обновите игру.'
		}
		
		public function Errors()
		{
			
		}
		
		public static function show(error:uint, data:Object, settings:Object = null):void
		{
			if (!Errors.data.hasOwnProperty(error) || error == 0) return;
			
			var titleText:String = 'Error:' + error + " " + Errors.data[error];
			if (data != null && data.hasOwnProperty('code')) {
				titleText += " " + data.code;
			}
			
			if (settings == null) settings = { };
			
			var winSettings:Object = {
				title				:Locale.__e('flash:1382952379692'),
				text				:takeErrorDescription(error),
				buttonText			:Locale.__e('flash:1382952379731'),
				//image				:UserInterface.textures.alert_error,
				image				:Window.texture('errorPic'),
				forcedClosing       :true,
				imageX				:-400,
				imageY				:-44,
				ok					:function():void {
					ExternalApi.reset()
				}
			};
			
			if (Config.admin || error == 8) {
				winSettings['title'] = Locale.__e('flash:1382952379692');
				winSettings['text'] = takeErrorDescription(error);//Locale.__e('flash:1382952380310');
				winSettings['buttonText'] = Locale.__e('flash:1382952380298');
				winSettings['escExit'] = true;
				winSettings['hasExit'] = true;
				winSettings['closeAfterOk'] = true;
			}
			
			/*if (error == 1) {
				Post.send({
					ctr:'save',
					act:'hash',
					uID:App.user.id,
					log:JSON.stringify(Post.h_arr)
				},function(error:int, data:Object, params:Object):void {});
			}*/
			
			for (var item:* in settings)
				winSettings[item] = settings[item];
				
			var confirm:Function = null;
			if (error == 1) confirm = onReload;
			new SimpleWindow( {
				title:Locale.__e('flash:1382952379692'),
				text:winSettings['text'],//Ой-ой-ой, тут что-то не\n так. Перезагрузи-ка.
				isImg:true,
				confirm:confirm
			}).show();	
			
			App.user.onStopEvent();
		}
		
		public static function onReload():void {
			navigateToURL(new URLRequest(Config.appUrl), '_parent');
		}
		
		private static function takeErrorDescription(errorID:uint):String
		{
			if(App.lang == 'ru')
				return Errors.data[errorID];
			else
				//return Locale.__e('flash:1382952379732', ['ID:' + errorID]);
				return Locale.__e('Error ID:' + errorID);
		}
	}
}
