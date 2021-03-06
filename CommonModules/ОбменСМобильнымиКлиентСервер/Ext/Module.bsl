﻿
///////////////////////////////////////////////////////////////////////////////
// СУЩНОСТИ ОБМЕНА

#Область СущностиОбмена

// Справочники

Функция Сущность_Город() Экспорт
	
	Возврат "Город";
	
КонецФункции

Функция Сущность_Контрагент() Экспорт
	
	Возврат "Контрагент";
	
КонецФункции

Функция Сущность_ОбъектСтроительства() Экспорт
	
	Возврат "Объект";
	
КонецФункции

Функция Сущность_СтатьяРасходов() Экспорт
	
	Возврат "СтатьяРасходов";	
	
КонецФункции

// Документы

Функция Сущность_СписаниеДС() Экспорт
	
	Возврат "СписаниеДенежныхСредств";
	
КонецФункции

Функция Сущности() Экспорт
	
	Результат = Новый Массив();
	
	Результат.Добавить(Сущность_ОбъектСтроительства());
	Результат.Добавить(Сущность_Город());
	Результат.Добавить(Сущность_Контрагент());
	Результат.Добавить(Сущность_СтатьяРасходов());
	
	Результат.Добавить(Сущность_СписаниеДС());
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти