//////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции

// Процедура заполняет список пользователей информационной базы
&НаСервере
Процедура ЗаполнитьСписокПользователей()
	
	СписокПользователей = ПользователиИнформационнойБазы.ПолучитьПользователей();
	
	Если СписокПользователей.Количество() > 0 Тогда
	
		Для каждого ТекПользователь Из СписокПользователей Цикл
			
			Элементы.Пользователь.СписокВыбора.Добавить(ТекПользователь.Имя);
			
		КонецЦикла;
		
	Иначе
		
		Элементы.Пользователь.Доступность = Ложь;
		Элементы.Скопировать.Доступность = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура обновляет список сохраненных настроек форм
&НаСервере
Процедура ОбновитьСписокФорм()
	
	Обработка = ДанныеФормыВЗначение(Объект, Тип("ОбработкаОбъект.УправлениеНастройкамиФорм"));
	Формы.Очистить();
	Обработка.ПолучитьСписокСохраненныхНастроек(Пользователь, Формы);
	
КонецПроцедуры

// Функция получает выделенные настройки в массиве
//
// Возврат :
//  Массив имен настроек форм
&НаСервере
Функция ПолучитьМассивВыделенныхНастроек()
	
	МассивНастроек = Новый Массив;
	
	ВыделенныеЭлементы = Элементы.ОтфильтрованныеФормы.ВыделенныеСтроки;
	
	Для каждого ВыделенныйЭлемент Из ВыделенныеЭлементы Цикл
		
		МассивНастроек.Добавить(Формы.НайтиПоЗначению(ОтфильтрованныеФормы.НайтиПоИдентификатору(ВыделенныйЭлемент).Значение).Значение);
		
	КонецЦикла;
	
	Возврат МассивНастроек;
	
КонецФункции

// Процедура копирует выделенные настройки указанному пользователю
// Параметры :
//  ПользователиПриемник - имя пользователя, которому нужно скопировать настройки
&НаСервере
Процедура СкопироватьНаСервере(ПользователиПриемник)

	МассивНастроекДляКопирования = ПолучитьМассивВыделенныхНастроек();
	
	Обработка = ДанныеФормыВЗначение(Объект, Тип("ОбработкаОбъект.УправлениеНастройкамиФорм"));
	Обработка.СкопироватьНастройкиФорм(Пользователь, ПользователиПриемник, МассивНастроекДляКопирования);
		
КонецПроцедуры

// Процедура удаляет выделенные настройки
&НаСервере
Процедура УдалитьНаСервере()
	
	МассивНастроекДляУдаления = ПолучитьМассивВыделенныхНастроек();
	
	Обработка = ДанныеФормыВЗначение(Объект, Тип("ОбработкаОбъект.УправлениеНастройкамиФорм"));
	Обработка.УдалитьНастройкиФорм(Пользователь, МассивНастроекДляУдаления);
	
КонецПроцедуры

// Процедура применяет фильтр к списку настроек
&НаСервере
Процедура ПрименитьФильтр()
	
	ОтфильтрованныеФормы.Очистить();
	
	Для каждого ЭлементФорма Из Формы Цикл
		
		Если Поиск = "" ИЛИ Найти(ВРег(ЭлементФорма.Представление), ВРег(Поиск)) <> 0 Тогда
			
			ОтфильтрованныеФормы.Добавить(ЭлементФорма.Значение, ЭлементФорма.Представление, ЭлементФорма.Пометка, ЭлементФорма.Картинка);
			
		КонецЕсли;
		
	КонецЦикла;
	
	ПримененныйПоиск = Поиск;
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////
// Обработчики команд

// Обработчик команды Обновить
&НаКлиенте
Процедура ОбновитьВыполнить()
	
	ОбновитьСписокФорм();
	ПрименитьФильтр();
	
КонецПроцедуры

&НаКлиенте
Процедура СкопироватьВыполнить(Команда)
	ВыполнитьКопирование();
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьКопирование()
	Если Элементы.ОтфильтрованныеФормы.ВыделенныеСтроки.Количество() = 0 Тогда
		Ждать ПредупреждениеАсинх(
			НСтр("ru = 'Для копирования нужно выбрать настройки, которые требуется скопировать.'", "ru"));
		Возврат;
	КонецЕсли;
	СписокВыбораПользователей = Элементы.Пользователь.СписокВыбора.Скопировать();
	СписокВыбораПользователей.Удалить(СписокВыбораПользователей.НайтиПоЗначению(Пользователь));
	РезультатОтметкиПользователя = Ждать СписокВыбораПользователей.ОтметитьЭлементыАсинх(НСтр("ru = 'Отметьте пользователей, которым нужно скопировать настройки.'", "ru"));
	Если РезультатОтметкиПользователя <> Неопределено Тогда
		ПользователиПриемник = Новый Массив;
		Для каждого Элемент Из СписокВыбораПользователей Цикл
			Элементы.Пользователь.СписокВыбора.НайтиПоЗначению(Элемент.Значение).Пометка = Элемент.Пометка;
			Если Элемент.Пометка Тогда
				ПользователиПриемник.Добавить(Элемент.Значение);
			КонецЕсли;
		КонецЦикла;
		Если ПользователиПриемник.Количество() = 0 Тогда
			Ждать ПредупреждениеАсинх(НСтр("ru = 'Для копирования нужно отметить пользователей, которым требуется скопировать настройки.'", "ru"));
			Возврат;
		КонецЕсли;
		Действие = "ВыполнитьКопирование";
		СписокКнопок = Новый СписокЗначений;
		СписокКнопок.Добавить(Действие, НСтр("ru = 'Выполнить копирование'", "ru"));
		СписокКнопок.Добавить(КодВозвратаДиалога.Отмена);
		Контекст = Новый Структура("Действие, ПользователиПриемник", Действие, ПользователиПриемник);
		РезультатОтветаНаВопрос = Ждать ВопросАсинх(
			НСтр("ru='После копирования настроек пользователю форма у пользователя будет открываться с настройками, которые ему скопируются. При этом его собственные настройки будут потеряны.'", "ru"),
			СписокКнопок, , Действие);
		Если РезультатОтветаНаВопрос = Контекст.Действие Тогда
			СкопироватьНаСервере(Контекст.ПользователиПриемник);
			ПоказатьОповещениеПользователя(НСтр("ru = 'Настройки скопированы'", "ru"));
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура УдалитьВыполнить(Команда)
	ВыполнитьУдаление();
КонецПроцедуры

&НаКлиенте
Асинх Процедура ВыполнитьУдаление()
	Если Элементы.ОтфильтрованныеФормы.ВыделенныеСтроки.Количество() = 0 Тогда
		Ждать ПредупреждениеАсинх(
			НСтр("ru='Для удаления нужно выбрать настройки, которые требуется удалить.'", "ru"));
		Возврат;
	КонецЕсли;
	Действие = "ВыполнитьУдаление";
	СписокКнопок = Новый СписокЗначений;
	СписокКнопок.Добавить(Действие, НСтр("ru = 'Выполнить удаление'", "ru"));
	СписокКнопок.Добавить(КодВозвратаДиалога.Отмена);
	РезультатВопросаОбУдалении = Ждать ВопросАсинх(
		НСтр("ru='После удаления настроек форма будет открываться с настройками по умолчанию.'", "ru"),
		СписокКнопок, , Действие);
	Если РезультатВопросаОбУдалении = Действие Тогда
		УдалитьНаСервере();
		ОбновитьСписокФорм();
		ПрименитьФильтр();
		ПоказатьОповещениеПользователя(НСтр("ru='Настройки удалены'", "ru"));
	КонецЕсли;
КонецПроцедуры

// Обработчик команды поиска
&НаКлиенте
Процедура ИскатьВыполнить()
	
	ПрименитьФильтр();
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////
// Обработчики событий формы

// Обработчик события создания формы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьСписокПользователей();
	Пользователь = ИмяПользователя();
	ОбновитьСписокФорм();
	ПрименитьФильтр();
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////
// Обработчики событий элементов управления

// Обработчик изменения имени пользователя
&НаКлиенте
Процедура ПользовательПриИзменении(Элемент)
	
	ОбновитьСписокФорм();
	ПрименитьФильтр();
	
КонецПроцедуры

// Обработчик изменения строки поиска
&НаКлиенте
Процедура ПоискПриИзменении(Элемент)
	
	ПрименитьФильтр();
	
КонецПроцедуры

