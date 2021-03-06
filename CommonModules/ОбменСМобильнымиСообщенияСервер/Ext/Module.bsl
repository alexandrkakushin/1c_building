﻿
#Область ПрограммныйИнтерфейс

// Инициирует обработку входящего сообщения и заполнения ответного сообщения.
//
// Параметры:
//  МобильныйКлиент		 - ссылка на узел плана обмена Мобильный;
//  ИсходящееСообщение	 - Ссылка на элемент справочника СообщенияИнтегрированныхСистем.
//
Процедура ОбработатьСообщенияИСформироватьПакетОбмена(МобильныйКлиент, ИсходящееСообщение) Экспорт

	Попытка
		Сообщения = ОбменСМобильнымиСервер.ПолучитьВходящиеНеобработанныеСообщения(МобильныйКлиент);
		Для Каждого Сообщение Из Сообщения Цикл
			ОбработатьВходящееСообщение(МобильныйКлиент, Сообщение);
		КонецЦикла;
	Исключение
		Инфо = ИнформацияОбОшибке();

		Если Инфо.Описание = "СтопДальнейшейОбработки" Тогда
			Возврат;
		КонецЕсли;

		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Обмен с мобильным.Обработка сообщения.Ошибка'", Метаданные.ОсновнойЯзык.КодЯзыка),
			УровеньЖурналаРегистрации.Ошибка,
			,
			Строка(МобильныйКлиент),
			ПодробноеПредставлениеОшибки(Инфо));

		ПоместитьВОчередьСообщениеОбОшибке(МобильныйКлиент, Инфо);

		УстановитьПривилегированныйРежим(Истина);

		ОбъектСообщения = ИсходящееСообщение.ПолучитьОбъект();
		Если Не ОбъектСообщения = Неопределено Тогда
			ОбъектСообщения.Удалить();
		КонецЕсли;

		ВызватьИсключение;
	КонецПопытки;

	Попытка
		Если Не МобильныйКлиент.ПометкаУдаления Тогда
			Если УКлиентаЕстьСинхронизируемыеОбласти() Тогда
				СформироватьПакетОбмена(ИсходящееСообщение, МобильныйКлиент);
			Иначе
				ТекстПредупреждения = 
					"warning:" + 
					НСтр("ru = 'Не включена синхронизация данных с мобильным клиентом.
						|C сервера на мобильный клиент не передаются никакие данные.
						|Необходимо зайти в персональные настройки в настольном клиенте и включить синхронизацию.'");
				Попытка
					ВызватьИсключение ТекстПредупреждения;
				Исключение
					Инфо = ИнформацияОбОшибке();
					ПоместитьВОчередьСообщениеОбОшибке(МобильныйКлиент, Инфо);
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
	Исключение
		Инфо = ИнформацияОбОшибке();
		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Обмен с мобильным.Формирование сообщения'", Метаданные.ОсновнойЯзык.КодЯзыка),
			УровеньЖурналаРегистрации.Ошибка,,
			Строка(МобильныйКлиент),
			ПодробноеПредставлениеОшибки(Инфо));

		ПоместитьВОчередьСообщениеОбОшибке(МобильныйКлиент, Инфо);
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

// Читает и обрабатывает данные СообщенияИнтегрированныхСистем.
//
// Параметры:
//  МобильныйКлиент	 -  ссылка на узел плана обмена Мобильный;
//  Сообщение		 -  Ссылка на элемент справочника СообщенияИнтегрированныхСистем;
// 
// Возвращаемое значение:
//  Истина - Если обработка завершена без ошибок.
//
Функция ОбработатьВходящееСообщение(МобильныйКлиент, Сообщение) Экспорт

	Данные = Сообщение.ДанныеСообщения.Получить();
	
	СвязиКУстановке = Новый Массив;

	ПараметрыСинхронизации = ОбменСМобильнымиСервер.ПолучитьПараметрыСинхронизации(МобильныйКлиент.Пользователь);
	ПараметрыСинхронизации.Вставить("МобильныйКлиент", МобильныйКлиент);

	Попытка
		ОбменСМобильнымиОбработкаСервер.ОбработатьДанныеОбъекта(
			Данные, СвязиКУстановке, ПараметрыСинхронизации);
			
		ПометитьСообщениеОбработанным(Сообщение);
	Исключение
		Инфо = ИнформацияОбОшибке();
		Если Инфо.Описание = "СтопДальнейшейОбработки" Тогда
			ПометитьСообщениеОбработанным(Сообщение);
			ВызватьИсключение;
		КонецЕсли;
				
		Если СтрНайти(НРег(Инфо.Описание), "info:") > 0 Тогда
			ЗаписьЖурналаРегистрации(
				НСтр("ru = 'Обмен с мобильным.Обработка сообщения.Информация'", Метаданные.ОсновнойЯзык.КодЯзыка),
				УровеньЖурналаРегистрации.Информация,
				,
				Строка(МобильныйКлиент),
				ПодробноеПредставлениеОшибки(Инфо));

			ПоместитьВОчередьСообщениеОбОшибке(МобильныйКлиент, Инфо);

		ИначеЕсли СтрНайти(НРег(Инфо.Описание), "warning:") > 0 Тогда
			ЗаписьЖурналаРегистрации(
				НСтр("ru = 'Обмен с мобильным.Обработка сообщения.Предупреждение'", Метаданные.ОсновнойЯзык.КодЯзыка),
				УровеньЖурналаРегистрации.Предупреждение,
				,
				Строка(МобильныйКлиент),
				ПодробноеПредставлениеОшибки(Инфо));

			ПоместитьВОчередьСообщениеОбОшибке(МобильныйКлиент, Инфо);
		Иначе
			ВызватьИсключение;
		КонецЕсли;

	КонецПопытки;

	Возврат Истина;

КонецФункции

// Получает параметры синхронизации для того чтобы их не читать множество раз
//
// Параметры:
//  МобильныйКлиент	 - ПланОбмена.Мобильные - ссылка на узел плана обмена Мобильный, из которого читаются 
//							данные для помещения в сообщение;
// 
// Возвращаемое значение:
//  Структура - Кешированные параметры синхронизхации и объекты для обеспечения скорости выгрузки
//
Функция ПолучитьПараметрыСинхронизации(МобильныйКлиент) Экспорт

	Пользователь   = ПользователиКлиентСервер.ТекущийПользователь();
	ИДПользователя = Пользователь.ИдентификаторПользователяИБ;

	Если ЗначениеЗаполнено(ИДПользователя) Тогда
		ПользовательИБ = 
			ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
				ИДПользователя);
	Иначе
		ПользовательИБ = Неопределено;
	КонецЕсли;

	ПараметрыСинхронизации  = 
		ОбменСМобильнымиСервер.ПолучитьПараметрыСинхронизации(Пользователь);

	ПараметрыСинхронизации.Вставить("МобильныйКлиент", МобильныйКлиент);
	ПараметрыСинхронизации.Вставить("КешДанныхОПользователях", ПолучитьДанныеПользователей());
	ПараметрыСинхронизации.Вставить("ОбъектыКВыгрузке", Новый Соответствие());
	ПараметрыСинхронизации.Вставить("ВыгруженныеОбъекты", Новый Соответствие());
	ПараметрыСинхронизации.Вставить("Адресаты", Новый Соответствие);
	ПараметрыСинхронизации.Вставить("Контакты", Новый Соответствие);

	ПараметрыСинхронизации.Вставить("ПользовательИБ", ПользовательИБ);
	ПараметрыСинхронизации.Вставить("ВыгруженоОбъектов", 0);
	
	// todo
	//ПараметрыСинхронизации.Вставить("ПапкиВСинхронизации", 
	//	ОбменСМобильнымиСерверПовтИсп.ПолучитьСинхронизируемыеПапкиПисем(МобильныйКлиент));

	Возврат ПараметрыСинхронизации;

КонецФункции

// Выполняет формирование сообщения со всеми измененными с момента последней синхронизации данными
//
// Параметры:
//  Сообщение       - Справочник.СообщенияИнтегрированныхСистем - ссылка на СообщениеИнтегрированныхСистем,
//					  в которое необходимо поместить данные;
//  МобильныйКлиент - ПланОбмена.Мобильные - ссылка на узел плана обмена Мобильный, из которого читаются 
//					  данные для помещения в сообщение;
//  ВерсияСервиса   - Строка - Версия используемого сервиса обмена.
//
Процедура СформироватьПакетОбмена(Сообщение, МобильныйКлиент) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	
	ДанныеСообщения = Сообщение.ДанныеСообщения.Получить();
	
	НачалоПодготовки = ТекущаяУниверсальнаяДатаВМиллисекундах();

	РегистрыСведений.ПротоколРаботыСМобильнымиКлиентами.ДобавитьИнформацию(
			НСтр("ru = 'Начало подготовки сообщения'"),
			Ложь,
			МобильныйКлиент);

	Попытка
		// Выборка всех изменений для данного мобильного клиента
		МассивДанныхДляПередачиНаМобильныйКлиент = 
			ОбменСМобильнымиСервер.ПолучитьИзмененныеДанные(МобильныйКлиент, Истина);

		КоличествоОбъектовВсего = МассивДанныхДляПередачиНаМобильныйКлиент.Количество();

		РегистрыСведений.ПротоколРаботыСМобильнымиКлиентами.ДобавитьИнформацию(
			СтрШаблон(
				НСтр("ru = 'Данных к выгрузке: %1'"), 
				КоличествоОбъектовВсего), 
			Ложь, 
			МобильныйКлиент);

		Если КоличествоОбъектовВсего = 0 Тогда
			// Если данных к выгрузке нет, то сообщение удаляется из очереди и из базы.
			СообщениеОбъект = Сообщение.ПолучитьОбъект();
			Если СообщениеОбъект <> Неопределено Тогда
				СообщениеОбъект.Удалить();
			КонецЕсли;
			Возврат;
		КонецЕсли;

		ШагОтображенияПроцентаГотовности = 
			ОбменСМобильнымиСервер.ПолучитьШагОтображенияПроцентаГотовности(КоличествоОбъектовВсего);

		СчетчикОбъектов = 0;
		ПараметрыСинхронизации = ПолучитьПараметрыСинхронизации(МобильныйКлиент);

		Для Каждого ЭлементДанных Из МассивДанныхДляПередачиНаМобильныйКлиент Цикл
			Попытка
				СчетчикОбъектов = СчетчикОбъектов + 1;

				Если Не ОбменСМобильнымиСервер.ЭлементДанныхСуществуетВБазе(ЭлементДанных) Тогда
					Продолжить;
				КонецЕсли;
							
				ОбменСМобильнымиФормированиеСообщенийСервер.ПолучитьИзОбъекта(ДанныеСообщения, 
					ПараметрыСинхронизации, ЭлементДанных);

				// Расчет процента готовности сообщения.
				// Максимальное значение 99, т.к. необходимо гарантировать, 
				// что не будет выполняться попытка передать сообщение клиенту до того,
				// как данные сообщения будут записаны.

				Если СчетчикОбъектов % ШагОтображенияПроцентаГотовности = 0 Тогда
					ПроцентГотовности = 99 * (СчетчикОбъектов/КоличествоОбъектовВсего) - 1;
					РегистрыСведений.СтепеньГотовностиСообщенийИнтегрированныхСистем.УстановитьПроцентГотовности(
						Сообщение, ПроцентГотовности);
				КонецЕсли;

				ПеренестиОбъектыКВыгрузкеВМассивВыгружаемых(
					ПараметрыСинхронизации, МассивДанныхДляПередачиНаМобильныйКлиент);

				// Обновим общее количество объектов, так как оно увеличилось.
				КоличествоОбъектовВсего = МассивДанныхДляПередачиНаМобильныйКлиент.Количество();

			Исключение
				Инфо = ИнформацияОбОшибке();
				ОбменСМобильнымиФормированиеСообщенийСервер.ПолучитьИзОбъекта(ДанныеСообщения, ПараметрыСинхронизации, Инфо);
			КонецПопытки;
		КонецЦикла;

		РегистрыСведений.СведенияОСообщенияхОбменаСМобильнымиКлиентами.ЗаписатьВремяПодготовки(
			Сообщение,
			(ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоПодготовки)/1000);

		КоличествоОбъектов = ПараметрыСинхронизации.ВыгруженоОбъектов;

		РегистрыСведений.ПротоколРаботыСМобильнымиКлиентами.ДобавитьИнформацию(
			СтрШаблон(
				НСтр("ru = 'Подготовлено сообщение из %1 объектов'"),
				КоличествоОбъектов), 
			Ложь, 
			МобильныйКлиент);

		СообщениеОбъект = Сообщение.ПолучитьОбъект();
		СообщениеОбъект.ДанныеСообщения = Новый ХранилищеЗначения(ДанныеСообщения);
		СообщениеОбъект.Записать();
		
		// Сообщение подготовлено
		РегистрыСведений.СтепеньГотовностиСообщенийИнтегрированныхСистем.УстановитьПроцентГотовности(
			Сообщение, 100);
				
		ОбменСМобильнымиРегистрацияИзмененийСервер.УдалитьРегистрациюИзмененийПослеФормированияСообщения(
			МобильныйКлиент, МассивДанныхДляПередачиНаМобильныйКлиент, ПараметрыСинхронизации);
	Исключение
		Инфо = ОписаниеОшибки();
		РегистрыСведений.ПротоколРаботыСМобильнымиКлиентами.ДобавитьИнформацию(
				НСтр("ru = 'Ошибка подготовки пакета: '") + Инфо,
				Ложь,
				МобильныйКлиент);
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

// Создает XDTO с указанным типом
//
// Параметры:
//  ТипОбъекта	 - Строка - строковое представление типа XDTO
// 
// Возвращаемое значение:
//  ОбъектXDTO - Объект XDTO указанного типа
//
Функция СоздатьОбъект(ТипОбъекта) Экспорт

	УстановитьПривилегированныйРежим(Истина);

	Возврат ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://www.1c.ru/DMX", ТипОбъекта));

КонецФункции

// Проверяет, что задача доступна текущему пользователю в момент проверки по правам, ролям
// и делегировани.
//
// Параметры:
//  Задача - ЗадачаСсылка.ЗадачаПользователя - проверяемая задача.
// 
// Возвращаемое значение:
//  РезультатЗапроса - Результат выполнления запроса по проверке прав и получению реквизитов.
//
Функция ПолучитьРеквизитыЗадачиСПроверкойДоступности(Задача) Экспорт

	// Запросы последовательно выполняют следующие действия:
	// 1. Получает все области делигирования по области "Задачи и поручения".
	// 2. Выбирает все активные области по текущему пользователю.
	// 3. Получает данные указанной задачи если выполнитлось условие, что пользователь это или текущий
	//    пользователь или выполняется условие делегирования, или задача является ролевой для тех же 
	//    пользователей.

	Запрос = Новый Запрос();

	Запрос.УстановитьПараметр("Исполнитель", ПользователиКлиентСервер.ТекущийПользователь());
	Запрос.УстановитьПараметр("Ссылка"     , Задача);
	Запрос.УстановитьПараметр("ОбъектМетаданных", 
		ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Задача.ЗадачаИсполнителя"));

	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ОбластиДелегированияПравСостав.Ссылка
		|ПОМЕСТИТЬ ОбластиДелегирования
		|ИЗ
		|	Справочник.ОбластиДелегированияПрав.Состав КАК ОбластиДелегированияПравСостав
		|ГДЕ
		|	ОбластиДелегированияПравСостав.ОбъектМетаданных = &ОбъектМетаданных
		|	И НЕ ОбластиДелегированияПравСостав.Ссылка.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДелегированиеПрав.ОтКого,
		|	ДелегированиеПрав.Кому
		|ПОМЕСТИТЬ Делегирующие
		|ИЗ
		|	Справочник.ДелегированиеПрав КАК ДелегированиеПрав
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДелегированиеПрав.ОбластиДелегирования КАК ТаблЧастьОбластиДелегирования
		|		ПО ДелегированиеПрав.Ссылка = ТаблЧастьОбластиДелегирования.Ссылка
		|ГДЕ
		|	ДелегированиеПрав.Кому = &Исполнитель
		|	И ДелегированиеПрав.Действует
		|	И (ДелегированиеПрав.ВариантДелегирования = ЗНАЧЕНИЕ(Перечисление.ВариантыДелегированияПрав.ВсеПрава)
		|			ИЛИ ТаблЧастьОбластиДелегирования.ОбластьДелегирования В
		|				(ВЫБРАТЬ
		|					ОбластиДелегирования.Ссылка
		|				ИЗ
		|					ОбластиДелегирования КАК ОбластиДелегирования))
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	ЗадачаИсполнителя.Ссылка,
		|	ЗадачаИсполнителя.БизнесПроцесс,
		|	ЗадачаИсполнителя.СостояниеБизнесПроцесса,
		|	ЗадачаИсполнителя.ПометкаУдаления,
		|	ЗадачаИсполнителя.Наименование,
		|	ЗадачаИсполнителя.Автор,
		|	ЗадачаИсполнителя.Описание,
		|	ЗадачаИсполнителя.СрокИсполнения,
		|	ЗадачаИсполнителя.Важность,
		|	ЗадачаИсполнителя.Дата,
		|	ЗадачаИсполнителя.Выполнена,
		|	ЗадачаИсполнителя.ДатаИсполнения,
		|	ЗадачаИсполнителя.РезультатВыполнения,
		|	ЗадачаИсполнителя.ВерсияДанных,
		|	ЗадачаИсполнителя.ТочкаМаршрута,
		|	ЗадачаИсполнителя.ДатаПринятияКИсполнению,
		|	ЗадачаИсполнителя.ПринятаКИсполнению,
		|	ЗадачаИсполнителя.Исполнитель,
		|	ЗадачаИсполнителя.РольИсполнителя
		|ИЗ
		|	Задача.ЗадачаИсполнителя КАК ЗадачаИсполнителя
		|ГДЕ
		|	ЗадачаИсполнителя.Ссылка = &Ссылка
		|	И (ЗадачаИсполнителя.Исполнитель = &Исполнитель
		|			ИЛИ ЗадачаИсполнителя.Исполнитель В
		|				(ВЫБРАТЬ
		|					Делегирующие.ОтКого
		|				ИЗ
		|					Делегирующие КАК Делегирующие)
		|			ИЛИ 1 В
		|					(ВЫБРАТЬ
		|						1
		|					ИЗ
		|						РегистрСведений.ИсполнителиЗадач КАК ИсполнителиЗадач
		|					ГДЕ
		|						ИсполнителиЗадач.РольИсполнителя = ЗадачаИсполнителя.РольИсполнителя
		|						И (ИсполнителиЗадач.Исполнитель = &Исполнитель
		|							ИЛИ ИсполнителиЗадач.Исполнитель В
		|								(ВЫБРАТЬ
		|									Делегирующие.ОтКого
		|								ИЗ
		|									Делегирующие КАК Делегирующие))
		|					)
		|				И ЗадачаИсполнителя.Исполнитель = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))";

	Возврат Запрос.Выполнить();

КонецФункции

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Переносит данные из списка связанных объектов которые нужно выгрузить в массив выгружаемых.
//
// Параметры:
//  ПараметрыСинхронизации					 - Структура - Параметры синхронизации;
//  МассивДанныхДляПередачиНаМобильныйКлиент - Массив - Массив писем.
//
Процедура ПеренестиОбъектыКВыгрузкеВМассивВыгружаемых(ПараметрыСинхронизации, 
	МассивДанныхДляПередачиНаМобильныйКлиент)

	// Добавляем связанные объекты найденные по ссылкам в массив выгружаемых ообъетов.
	Для Каждого Пара Из ПараметрыСинхронизации.ОбъектыКВыгрузке Цикл

		Если Не Пара.Значение Тогда
			Продолжить;
		КонецЕсли;

		Если МассивДанныхДляПередачиНаМобильныйКлиент.Найти(Пара.Ключ) = Неопределено Тогда

			ЭлементДанных = Новый Структура("Ссылка, ПометкаУдаления", Пара.Ключ, Ложь);

			МассивДанныхДляПередачиНаМобильныйКлиент.Добавить(ЭлементДанных);

			ПараметрыСинхронизации.ОбъектыКВыгрузке.Удалить(Пара.Ключ);

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

// Проверяет наличие у клиента синхронизируемых областей данных.
// 
// Возвращаемое значение:
//  Булево - Истина если есть что синхронизировать.
//
Функция УКлиентаЕстьСинхронизируемыеОбласти() 

	Пользователь = ПользователиКлиентСервер.ТекущийПользователь();
	
	СинхронизироватьСписанияДенежныхСредств =
		 РегистрыСведений.ОбменСМобильнымиНастройкиПользователей.ПолучитьНастройку(
		 	Пользователь,
			Перечисления.ОбменСМобильнымиТипыНастроекПользователей.СинхронизацияСписанийДенежныхСредств);
			
	Если СинхронизироватьСписанияДенежныхСредств Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;

КонецФункции

// Формирует сообщение об ошибке и помещает его в очередь сообщений для мобильного клиента.
//  Клиент получит это сообщение и отобразит его пользователю.
//
// Параметры:
//  МобильныйКлиент		 - 	 - ссылка на узел плана обмена Мобильный
//  ИнформацияОбОшибке	 - 	 - объект, содержащий информацию о произошедшей ошибке
//
Процедура ПоместитьВОчередьСообщениеОбОшибке(МобильныйКлиент, ИнформацияОбОшибке)
	
	// todo
	ВерсияКлиента = Неопределено;
	Если Не ЗначениеЗаполнено(ВерсияКлиента) Тогда
		// Гарантированное большое значение, чтобы клиент считал что сервер новее.
		ВерсияКлиента = "999";
	КонецЕсли;

	УстановитьПривилегированныйРежим(Истина);

	ОбменСМобильнымиСервер.ЗаписатьОшибкуВПротоколПриОбмене(МобильныйКлиент, ИнформацияОбОшибке);

	Пользователь = ПользователиКлиентСервер.ТекущийПользователь();
	ВозвращаемыеОбъекты = Новый Соответствие;
	ПараметрыСинхронизации = ОбменСМобильнымиСервер.ПолучитьПараметрыСинхронизации(Пользователь);

	Попытка
		Сообщение = Неопределено;
		ОбменСМобильнымиФормированиеСообщенийСервер.ПолучитьИзОбъекта(Сообщение, ПараметрыСинхронизации, ИнформацияОбОшибке);
		ОбменСМобильнымиСервер.ЗаписатьДанныеОбмена(МобильныйКлиент, Сообщение);
	Исключение
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

// Формирует структуру объекта читаемого из XML.
//
// Параметры:
//  ЧтениеXML	 - ЧтениеXML - Объект чтения из файла;
//  ИмяТипа		 - Строка - Имя типа читаемого объекта.
// 
// Возвращаемое значение:
//  Соответствие - прочитанные поля объекта указанного типа.
//
Функция ПрочитатьСтруктуруОбъектаИзXML(ЧтениеXML, ИмяТипа)

	ДанныеОбъекта = Новый Соответствие();

	// Выполняем обход по данным.
	Пока ЧтениеXML.Прочитать() Цикл

		// На конечном элемента объекта - выходим.
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.КонецЭлемента
			И ЧтениеXML.Имя = ИмяТипа Тогда
			Прервать;

		ИначеЕсли ЧтениеXML.ТипУзла = ТипУзлаXML.Текст Тогда

			// Читаем значение.
			Значение = ЧтениеXML.Значение;

			// Читаем закрывающий тэг.
			ЧтениеXML.Прочитать();

			Возврат Значение;

		// Нашли новый элемент.
		ИначеЕсли ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда

			// Запоминаем имя элемента.
			Имя = ЧтениеXML.Имя;
			ВерсияУзла = ЧтениеXML.ПолучитьАтрибут("Version");

			Данные = ПрочитатьСтруктуруОбъектаИзXML(ЧтениеXML, Имя);

			Если Не ВерсияУзла = Неопределено Тогда
				Данные.Вставить(ВРег("Версия"), ВерсияУзла);
			КонецЕсли;

			Если ТипЗнч(ДанныеОбъекта) = Тип("Соответствие") Тогда

				Значение = ДанныеОбъекта[ВРег(Имя)];

				Если Значение = Неопределено Тогда
					ДанныеОбъекта.Вставить(ВРег(Имя), Данные);
				Иначе
					ДанныеОбъекта = Новый Массив();
					ДанныеОбъекта.Добавить(Значение);
					ДанныеОбъекта.Добавить(Данные);
				КонецЕсли;

			Иначе

				ДанныеОбъекта.Добавить(Данные);

			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

	Возврат ДанныеОбъекта;

КонецФункции

// Получить данные пользователей и ролей.
// 
// Возвращаемое значение:
//  ТаблицаЗначений - Данные о пользователях и ролях.
//
Функция ПолучитьДанныеПользователей()

	Запрос = Новый Запрос();
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Пользователи.Ссылка,
		|	Пользователи.Наименование,
		|	Пользователи.КонтактнаяИнформация.(
		|		Ссылка,
		|		НомерСтроки,
		|		Тип,
		|		Вид,
		|		Представление,
		|		ЗначенияПолей,
		|		Страна,
		|		Регион,
		|		Город,
		|		АдресЭП,
		|		ДоменноеИмяСервера,
		|		НомерТелефона,
		|		НомерТелефонаБезКодов
		|	)
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи";

	ДанныеОПользователях = Запрос.Выполнить().Выгрузить();
	ДанныеОПользователях.Индексы.Добавить("Ссылка");

	Возврат ДанныеОПользователях;

КонецФункции

// Помечает сообщение обмена обработанным
//
// Параметры:
//  Сообщение - Справочник.СообщенияИнтегрированныхСистем - Сообщение обмена данными.
//
Процедура ПометитьСообщениеОбработанным(Сообщение) Экспорт

	СообщениеОбъект = Сообщение.ПолучитьОбъект();
	Если Не СообщениеОбъект = Неопределено Тогда

		СообщениеОбъект.ДатаОбработки   = ТекущаяДатаСеанса();
		СообщениеОбъект.ПометкаУдаления = Истина;

		СообщениеОбъект.Записать();

	КонецЕсли;

КонецПроцедуры 

#КонецОбласти // СлужебныеПроцедурыИФункции