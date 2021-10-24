
//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ 
// 

Процедура ОбработкаПроведения(Отказ, Режим)
	// Формирование движения регистра накопления Взаиморасчеты
	Движения.Взаиморасчеты.Записывать = Истина;
	Движение = Движения.Взаиморасчеты.Добавить(); //комментарий
	Структура = Новый Структура;
	Структура.Вставить("екек");
	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
	Движение.Период = Дата;
	Движение.Контрагент = Поставщик;
	Движение.Сумма = Сумма;
	Движение.Валюта = Валюта;
	Сообщить("Пока");
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ПриходТовара") Тогда
		Валюта      = ДанныеЗаполнения.Валюта;
		Поставщик   = ДанныеЗаполнения.Поставщик;
		Организация = ДанныеЗаполнения.Организация;
		Сумма       = 11;
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.Контрагенты") Тогда
		
		ЗапросПоКонтрагенту = Новый Запрос("ВЫБРАТЬ
		                                   |	Контрагенты.ЭтоГруппа
		                                   |ИЗ
		                                   |	Справочник.Контрагенты КАК Контрагенты
		                                   |ГДЕ
		                                   |	Контрагенты.Ссылка = &КонтрагентСсылка");
		ЗапросПоКонтрагенту.УстановитьПараметр("КонтрагентСсылка", ДанныеЗаполнения);
		Выборка = ЗапросПоКонтрагенту.Выполнить().Выбрать();
		Если Выборка.Следующий() И Выборка.ЭтоГруппа Тогда
			Возврат;
		КонецЕсли;
		
		Поставщик = ДанныеЗаполнения.Ссылка;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	//Удалим из списка проверяемых реквизитов валюту, если по организации не ведется 
	//валютный учет
	Если НЕ ПолучитьФункциональнуюОпцию("ВалютныйУчет", Новый Структура("Организация", Организация)) Тогда
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("Валюта"));
	КонецЕсли;
		
	Если Отказ Тогда
		Сообщить("Есть ошибка");
	Иначе
		Сообщить("Нет ошибки");			
	КонецЕсли;		
	
КонецПроцедуры
