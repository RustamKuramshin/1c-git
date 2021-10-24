//////////////////////////////////////////////////////////////////////////////// 
// Переменные
// 

&НаКлиенте
Перем АдресТоваровВХранилище;

//////////////////////////////////////////////////////////////////////////////// 
// ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

// Функция возвращает цену определенного товара на дату согласно виду цены
// 
// Параметры: 
//  Дата   – Дата – дата, на которую определяется цена. 
//  Товар  – СправочникСсылка.Товары – товар, цена которого определяется. 
//  ВидЦен – СправочникСсылка.ВидыЦен – вид цены. 
// 
// Возвращаемое значение: 
//  Число - Цена товара на определенную дату, согласно виду цены.
&НаСервереБезКонтекста
Функция ПолучитьЦенуТовара(Дата, Товар, ВидЦен)
	ЦенаТовара = РегистрыСведений.ЦеныТоваров.ПолучитьПоследнее(
		Дата, Новый Структура("Товар, ВидЦен", Товар, ВидЦен));
	Возврат ЦенаТовара.Цена;
КонецФункции

// Функция возвращает вид цены для указанного покупателя
// 
// Параметры: 
//  Покупатель – СправочникСсылка.Контрагенты – контрагент. 
// 
// Возвращаемое значение: 
//  СправочникСсылка.ВидыЦен - Вид цены для указанного покупателя.
&НаСервереБезКонтекста
Функция ПолучитьВидЦенПокупателя(Покупатель)
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ ВидЦен ИЗ Справочник.Контрагенты ГДЕ Ссылка = &Покупатель";
	Запрос.УстановитьПараметр("Покупатель", Покупатель);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ВидЦен;
	КонецЕсли;
	Возврат Справочники.ВидыЦен.ПустаяСсылка();
КонецФункции

// Функция определяет услуга это или нет
&НаСервереБезКонтекста
Функция ЭтоУслуга(Товар)
	
	Возврат ?(Товар.Вид = Перечисления.ВидыТоваров.Услуга, Истина, Ложь);
	
КонецФункции

// Процедура устанавливает цены товаров и вычисляет суммы по каждой строке
// табличной части Товары.
// 
// Параметры: 
//  Нет.
// 
// Возвращаемое значение: 
//  Нет.
&НаСервере
Процедура ПересчитатьЦеныИСуммыТоваров(ПересчитатьДляВсехТоваров)
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ
				   |	ЦеныТоваровСрезПоследних.Цена,
				   |	ЦеныТоваровСрезПоследних.Товар
				   |ИЗ
				   |	РегистрСведений.ЦеныТоваров.СрезПоследних(
				   |		,
				   |		ВидЦен = &ВидЦены
				   |			И Товар В (&Товары)) КАК ЦеныТоваровСрезПоследних";
	Запрос.УстановитьПараметр("ВидЦены", Объект.ВидЦен);
	Товары = Новый Массив();
	Для каждого Стр Из Объект.Товары Цикл 
		Товары.Добавить(Стр.Товар);
	КонецЦикла;
	Запрос.УстановитьПараметр("Товары", Товары);
	
	ТЗЦены = Запрос.Выполнить().Выгрузить();
	ТЗЦены.Индексы.Добавить("Товар");
	Для каждого Стр Из Объект.Товары Цикл 
		Если Стр.Цена = 0 ИЛИ ПересчитатьДляВсехТоваров Тогда
			ЦенаТовара = ТЗЦены.Найти(Стр.Товар, "Товар");
			Если ЦенаТовара <> Неопределено Тогда
				Стр.Цена = ЦенаТовара.Цена;
			Иначе 	
				Стр.Цена = 0;
			КонецЕсли;
		КонецЕсли;	
		Стр.Сумма = Стр.Цена * Стр.Количество;
		Стр.СуммаИзменена = Ложь;
		Стр.ЭтоУслуга = ЭтоУслуга(Стр.Товар);
	КонецЦикла;
КонецПроцедуры

// Функция помещает список товаров во временное хранилище и возвращает адрес 
&НаСервере
Функция ПоместитьТоварыВХранилище() 
	Возврат ПоместитьВоВременноеХранилище(Объект.Товары.Выгрузить(,"Товар,Цена,Количество"), УникальныйИдентификатор);
КонецФункции	

// Функция восстанавливает список товаров из временного хранилища
&НаСервере
Процедура ПолучитьТоварыИзХранилища(АдресТоваровВХранилище)
	Объект.Товары.Загрузить(ПолучитьИзВременногоХранилища(АдресТоваровВХранилище));
	ПересчитатьЦеныИСуммыТоваров(Ложь);   
КонецПроцедуры	


// Функция возвращает ссылку на текущую строку в списке товаров 
// 
// Параметры: 
//  Нет. 
// 
// Возвращаемое значение: 
//  СправочникСсылка.Товары - Текущий товар в списке.
&НаКлиенте
Функция ПолучитьТекущуюСтрокуТовары()
	Возврат Элементы.Товары.ТекущиеДанные;
КонецФункции

// Процедура вычисляет дополнительные данные строки документа
&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьДополнительныеДанныеСтроки(Строка)
	
	Строка.СуммаИзменена = Строка.Сумма <> Строка.Количество * Строка.Цена;
	
КонецПроцедуры

// Функция возвращает значение реквизита телефон на клиент
// 
// Параметры: 
//  Покупатель - контрагент, телефон которого получается
// 
// Возвращаемое значение: 
//  Телефон контрагента
&НаСервереБезКонтекста
Функция ПолучитьТелефон(Покупатель)
	
	Возврат Покупатель.Телефон;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ 
// 

&НаКлиенте
Процедура ТоварыТоварПриИзменении(Элемент)
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.ЭтоУслуга = ЭтоУслуга(Стр.Товар);
	Стр.Цена = ПолучитьЦенуТовара(Объект.Дата, Стр.Товар, Объект.ВидЦен);
	Стр.Количество = ?(Стр.ЭтоУслуга ИЛИ Стр.Количество = 0, 1, Стр.Количество);
	Стр.Сумма = Стр.Количество * Стр.Цена;
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

&НаКлиенте
Процедура ПокупательПриИзменении(Элемент)
	ВидЦен = ПолучитьВидЦенПокупателя(Объект.Покупатель);
	Если Объект.ВидЦен <> ВидЦен Тогда
		Объект.ВидЦен = ВидЦен;
		Если Объект.Товары.Количество() > 0 Тогда
			ПересчитатьЦеныИСуммыТоваров(Истина);
		КонецЕсли;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВидЦенПриИзменении(Элемент)
	Если Объект.Товары.Количество() > 0 Тогда
		ПересчитатьЦеныИСуммыТоваров(Истина);
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.Сумма = Стр.Количество * Стр.Цена;
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент) 
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.Сумма = Стр.Количество * Стр.Цена;
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаПриИзменении(Элемент)
	Стр = ПолучитьТекущуюСтрокуТовары();
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

// Обработчик команды подбора
&НаКлиенте
Процедура КомандаПодбор()
#Если МобильныйКлиент Тогда 
	Имя = "ОбщаяФорма.ФормаПодбораМобильная";
#Иначе
	Имя = "ОбщаяФорма.ФормаПодбора";
#КонецЕсли
	АдресТоваровВХранилище = ПоместитьТоварыВХранилище();
	ПараметрыПодбора = Новый Структура("АдресТоваровДокумента, ВидЦен, Склад", АдресТоваровВХранилище, Объект.ВидЦен, Объект.Склад);
	ФормаПодбора = ОткрытьФорму(Имя, ПараметрыПодбора, ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Ключ.Пустая() Тогда 
		
		ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
		УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
		
	КонецЕсли;
	
	Для каждого Стр Из Объект.Товары Цикл
		
		ЗаполнитьДополнительныеДанныеСтроки(Стр);
		
	КонецЦикла;
	
	//ID333 new
	ВремяЗаказа = ТекущаяДата();
	Если 1=1 Тогда
		Сообщить("Нет данных");
	Иначе
		Сообщить(ВремяЗаказа);
	КонецЕсли;
		
#Если НЕ МобильныйКлиент Тогда
	// Текущая строка не имеют смысла на мобильном клиенте
	
	Если Параметры.ТекущийТовар <> Неопределено
		И Параметры.ТекущийТовар < Объект.Товары.Количество() Тогда
				
	КонецЕсли;
#КонецЕсли
	
	СостояниеЗаказаПриСоздании = Объект.СостояниеЗаказа;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);

	Для каждого Стр Из Объект.Товары Цикл
		
		ЗаполнитьДополнительныеДанныеСтроки(Стр);
		Стр.ЭтоУслуга = ЭтоУслуга(Стр.Товар);
		
	КонецЦикла
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
	
	Для каждого Стр Из Объект.Товары Цикл
		
		ЗаполнитьДополнительныеДанныеСтроки(Стр);
		
	КонецЦикла;
	
#Если Не МобильныйАвтономныйСервер Тогда
	Если СостояниеЗаказаПриСоздании <> ТекущийОбъект.СостояниеЗаказа Тогда
		Уведомление = Новый ДоставляемоеУведомление();
		Уведомление.Текст = НСтр("ru = 'Заказ '", "ru") + ТекущийОбъект.Номер + НСтр("ru = ': изменилось состояние'", "ru");
		Проблемы = Новый Массив;
		УведомленияСервер.ОтправитьУведомление(Уведомление, ТекущийОбъект.Автор, Проблемы);
	КонецЕсли;
#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьПодбор() Экспорт
	
	ПолучитьТоварыИзХранилища(АдресТоваровВХранилище);  
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗаписиНового(НовыйОбъект, Источник, СтандартнаяОбработка)
	Если ТипЗнч(НовыйОбъект) = Тип("СправочникСсылка.Контрагенты") Тогда
		Объект.Покупатель = НовыйОбъект;
		ВидЦен = ПолучитьВидЦенПокупателя(Объект.Покупатель);
		Если Объект.ВидЦен <> ВидЦен Тогда
			Объект.ВидЦен = ВидЦен;
			Если Объект.Товары.Количество() > 0 Тогда
				ПересчитатьЦеныИСуммыТоваров(Истина);
			КонецЕсли;	
		КонецЕсли;
		ТекущийЭлемент = Элементы.Покупатель;
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура Позвонить(Команда)
	
	Если ЗначениеЗаполнено(Объект.Покупатель) Тогда
		
		Телефон = ПолучитьТелефон(Объект.Покупатель);
		Если ЗначениеЗаполнено(Телефон) Тогда
#Если МобильныйКлиент Тогда 
		СредстваТелефонии.НабратьНомер(Телефон, Ложь);
#КонецЕсли
		Иначе
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = НСтр("ru = 'Не указан телефон покупателя!'", "ru");
			Сообщение.Поле  = "Объект.Покупатель";
			Сообщение.Сообщить();
		КонецЕсли
		
	Иначе
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Покупатель не выбран!'", "ru");
		Сообщение.Поле  = "Объект.Покупатель";
		Сообщение.Сообщить();
		
	КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьСМС(Команда)
	
	Если ЗначениеЗаполнено(Объект.Покупатель) Тогда
		
		Телефон = ПолучитьТелефон(Объект.Покупатель);
		Если ЗначениеЗаполнено(Телефон) Тогда
#Если МобильныйКлиент Тогда 
		Сообщение = Новый SMSСообщение();
		Сообщение.Получатели.Добавить(Телефон);
		СредстваТелефонии.ПослатьSMS(Сообщение, Истина);
#КонецЕсли
		Иначе
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = НСтр("ru = 'Не указан телефон покупателя!'", "ru");
			Сообщение.Поле  = "Объект.Покупатель";
			Сообщение.Сообщить();
		КонецЕсли
		
	Иначе
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Покупатель не выбран!'", "ru");
		Сообщение.Поле  = "Объект.Покупатель";
		Сообщение.Сообщить();
		
	КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
#Если НЕ МобильныйКлиент Тогда
	
	// Команды звонка и отправки смс имеют смысл только на мобильном клиенте
	Элементы.ФормаПозвонить.Видимость = Ложь;
	Элементы.ФормаОтправитьСМС.Видимость = Ложь;
#Иначе
	Элементы.ФормаПозвонить.Доступность = СредстваТелефонии.ПоддерживаетсяНаборНомера();
	Элементы.ФормаОтправитьСМС.Доступность = СредстваТелефонии.ПоддерживаетсяОтправкаSMS(Истина);
	
#КонецЕсли
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаПолученияСпискаНавигационныхСсылок(СписокНавигационыхСсылок, КлючПоУмолчанию)
#Если НЕ МобильныйКлиент Тогда
	// Текущая строка не имеют смысла на мобильном клиенте
	Перем ТекущийТовар;
	
	ТекущийТовар = ПолучитьТекущуюСтрокуТовары();
	
	Если ТекущийТовар <> Неопределено Тогда
		
		СписокНавигационыхСсылок.Добавить(
			// ключ варианта ссылки
			"ЗаказСТекущимТоваром",
			// представление ссылки
			Строка(Объект.Ссылка) + " (" + Строка(ТекущийТовар.Товар) + ")",
			// запрашивать пользовательское представление
			Истина);
		
	КонецЕсли;
#КонецЕсли
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаПолученияНавигационнойСсылки(
	Ключ,
	Представление,
	НавигационнаяСсылка,
	СтандартнаяОбработка)
	
#Если НЕ МобильныйКлиент Тогда
	// Текущая строка не имеют смысла на мобильном клиенте
	Если Ключ = "ЗаказСТекущимТоваром" Тогда
		НавигационнаяСсылка = ЭтаФорма.ПолучитьНавигационнуюСсылкуОбъекта(
			Представление,
			// Чтобы получить индекс товара в коллекции Объект.Товары с нумерацией от 0,
			// из номера строки вычитаем 1, поскольку строки нумеруются с 1.
			Новый Структура("ТекущийТовар", ПолучитьТекущуюСтрокуТовары().НомерСтроки - 1));
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
#КонецЕсли

КонецПроцедуры
