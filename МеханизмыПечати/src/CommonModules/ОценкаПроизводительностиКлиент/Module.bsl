///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Начинает замер времени ключевой операции.
// Результат замера будет записан в регистр сведений ЗамерыВремени.
// Поскольку клиентские замеры хранятся в клиентском буфере и записываются с периодичностью,
// указанной в константе ОценкаПроизводительностиПериодЗаписи (по умолчанию, каждую минуту),
// в случае завершения сеанса часть замеров может быть потеряна.
//
// Параметры:
//  КлючеваяОперация - Строка - 	имя ключевой операции. Если Неопределено, то ключевую операцию
//									необходимо указать явно вызовом процедуры
//									УстановитьКлючевуюОперациюЗамера.
//  ФиксироватьСОшибкой - Булево -	признак автоматической фиксации ошибки. 
//									Истина - при автоматическом завершении замера, он будет записан
//									с признаком "Выполнен с ошибкой". В том месте кода, где ошибка явно
//									не может возникнуть, необходимо либо явно завершить замер методом
//									ЗавершитьЗамерВремени, либо снять признак ошибки с помощью метода
//									УстановитьПризнакОшибкиЗамера.
//									Ложь - замер будет считаться корректным при автоматическом завершении.
//  АвтоЗавершение - Булево	 - 		признак автоматического завершения замера.
//									Истина - завершение замера будет выполнено автоматически
//									через глобальный обработчик ожидания.
//									Ложь - завершить замер необходимо явно вызовом процедуры
//									ЗавершитьЗамерВремени.
//
// Возвращаемое значение:
//  УникальныйИдентификатор - уникальный идентификатор замера, который позволяет идентифицировать замер.
//
Функция ЗамерВремени(КлючеваяОперация = Неопределено, ФиксироватьСОшибкой = Ложь, АвтоЗавершение = Истина) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
	КонецЕсли;
	
	Параметры = ПараметрыЗамераВремениНаКлиенте(КлючеваяОперация);
	Параметры.АвтоЗавершение = АвтоЗавершение;
	Параметры.ВыполненаСОшибкой = ФиксироватьСОшибкой;

	НачатьЗамерВремениНаКлиентеСлужебный(Параметры);
	Возврат Параметры.УИДЗамера;
	
КонецФункции

// Начинает технологический замер времени ключевой операции.
// Результат замера будет записан в РегистрСведений.ЗамерыВремени.
//
// Параметры:
//  АвтоЗавершение - Булево	 - 	признак автоматического завершения замера.
//								Истина - завершение замера будет выполнено автоматически
//								через глобальный обработчик ожидания.
//								Ложь - завершить замер необходимо явно вызовом процедуры
//								ЗавершитьЗамерВремени.
//  КлючеваяОперация - Строка - имя ключевой операции. Если Неопределено> то ключевую операцию
//								необходимо указать явно вызовом процедуры
//								УстановитьКлючевуюОперациюЗамера.
//
// Возвращаемое значение:
//  УникальныйИдентификатор - уникальный идентификатор замера, который позволяет идентифицировать замер.
//
Функция НачатьЗамерВремениТехнологический(АвтоЗавершение = Истина, КлючеваяОперация = Неопределено) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
	КонецЕсли;

	Параметры = ПараметрыЗамераВремениНаКлиенте(КлючеваяОперация);
	Параметры.АвтоЗавершение = АвтоЗавершение;
	Параметры.Технологический = Истина;
	Параметры.ВыполненаСОшибкой = Ложь;
		
	НачатьЗамерВремениНаКлиентеСлужебный(Параметры);
	Возврат Параметры.УИДЗамера;
	
КонецФункции

// Завершает замер времени на клиенте.
//
// Параметры:
//  УИДЗамера - УникальныйИдентификатор - уникальный идентификатор замера.
//  ВыполненСОшибкой - Булево - признак того, что замер не был выполнен до конца,
//  							а выполнение ключевой операции завершилось с ошибкой.
//
Процедура ЗавершитьЗамерВремени(УИДЗамера, ВыполненСОшибкой = Ложь) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;

	ВремяОкончания = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ЗавершитьЗамерВремениСлужебный(УИДЗамера, ВремяОкончания);
	
	ЗамерыВремени = ОценкаПроизводительностиЗамерВремени();
	Если ЗамерыВремени = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Замер = ЗамерыВремени.Замеры[УИДЗамера];
	Если Замер = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Замер["ВыполненаСОшибкой"] = ВыполненСОшибкой;
	ЗамерыВремени.ЗамерыЗавершенные.Вставить(УИДЗамера, Замер);
	ЗамерыВремени.Замеры.Удалить(УИДЗамера);
	
КонецПроцедуры

// Устанавливает параметры замера.
//
// Параметры:
//  УИДЗамера	- УникальныйИдентификатор - уникальный идентификатор замера.
//  ПараметрыЗамера	- Структура:
//    * КлючеваяОперация - Строка		- имя ключевой операции.
//    * ВесЗамера		- Число			- количественный показатель сложности замера.
//    * Комментарий		- Строка
//						- Соответствие - дополнительная произвольной информации замера.
//    * ВыполненаСОшибкой - Булево			- признак выполнения замера с ошибкой,
//											см. процедуру УстановитьПризнакОшибкиЗамера.
//
Процедура УстановитьПараметрыЗамера(УИДЗамера, ПараметрыЗамера) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;

	Замеры = ОценкаПроизводительностиЗамерВремени().Замеры;
	Для Каждого Параметр Из ПараметрыЗамера Цикл
		Замеры[УИДЗамера][Параметр.Ключ] = Параметр.Значение;
	КонецЦикла;
	
КонецПроцедуры

// Устанавливает ключевую операцию замера.
//
// Параметры:
//  УИДЗамера 			- УникальныйИдентификатор - уникальный идентификатор замера.
//  КлючеваяОперация	- Строка - наименование ключевой операции.
//
// Если на момент начала замера имя ключевой операции еще неизвестно,
// то с помощью этой процедуры в любой момент до завершения замера можно
// доопределить имя ключевой операции.
// Например, при проведении документа, т.к. в момент начала проведения
// мы не можем гарантировать, что проведение документа завершиться и не будет отказа.
// 
// &НаКлиенте
// Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
//	Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
//		ИдентификаторЗамераПроведение = ОценкаПроизводительностиКлиент.НачатьЗамерВремени(Истина);
//	КонецЕсли;
// КонецПроцедуры
//
// &НаКлиенте
// Процедура ПослеЗаписи(ПараметрыЗаписи)
//	Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
//		ОценкаПроизводительностиКлиент.УстановитьКлючевуюОперациюЗамера(ИдентификаторЗамераПроведение, "_ДемоПроведениеДокумента");
//	КонецЕсли;
// КонецПроцедуры
//
Процедура УстановитьКлючевуюОперациюЗамера(УИДЗамера, КлючеваяОперация) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;

	ОценкаПроизводительностиЗамерВремени().Замеры[УИДЗамера]["КлючеваяОперация"] = КлючеваяОперация;
	
КонецПроцедуры

// Устанавливает вес операции замера.
//
// Параметры:
//  УИДЗамера - УникальныйИдентификатор - уникальный идентификатор замера.
//  ВесЗамера - Число					- количественный показатель сложности
//										  замера, например количество строк в документе.
//
Процедура УстановитьВесЗамера(УИДЗамера, ВесЗамера) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;
	ОценкаПроизводительностиЗамерВремени().Замеры[УИДЗамера]["ВесЗамера"] = ВесЗамера;
	
КонецПроцедуры

// Устанавливает комментарий операции замера.
//
// Параметры:
//  УИДЗамера   - УникальныйИдентификатор - уникальный идентификатор замера.
//  Комментарий - Строка
//              - Соответствие из КлючИЗначение - дополнительная произвольной информации замера.
//                               В случае указания соответствия:
//                                            * Ключ     - Строка - имя дополнительного параметра информации замера.
//                                            * Значение - Строка
//                                                       - Число
//                                                       - Булево - значение дополнительного параметра замера.
//
Процедура УстановитьКомментарийЗамера(УИДЗамера, Комментарий) Экспорт
		
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;
	ОценкаПроизводительностиЗамерВремени().Замеры[УИДЗамера]["Комментарий"] = Комментарий;
	
КонецПроцедуры

// Устанавливает признак ошибки операции замера.
//
// Параметры:
//  УИДЗамера	- УникальныйИдентификатор	- уникальный идентификатор замера.
//  Признак		- Булево					- признак замера. Истина - замер выполнился без ошибок.
//											  Ложь - при выполнении замера есть ошибка.
//
Процедура УстановитьПризнакОшибкиЗамера(УИДЗамера, Признак) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;
	ОценкаПроизводительностиЗамерВремени().Замеры[УИДЗамера]["ВыполненаСОшибкой"] = Признак;
	
КонецПроцедуры

// Начинает замер времени выполнения длительной ключевой операции. Закончить замер нужно явно вызовом
// процедуры ЗакончитьЗамерДлительнойОперации.
// Результат замера будет записан в регистр сведений ЗамерыВремени.
//
// Параметры:
//  КлючеваяОперация - Строка - имя ключевой операции. 
//  ФиксироватьСОшибкой - Булево -	признак автоматической фиксации ошибки. 
//									Истина - при автоматическом завершении замера, он будет записан
//									с признаком "Выполнен с ошибкой". В том месте кода, где ошибка явно
//									не может возникнуть, необходимо либо явно завершить замер методом
//									ЗавершитьЗамерВремени, либо снять признак ошибки с помощью метода
//									УстановитьПризнакОшибкиЗамера
//									Ложь - замер будет считаться корректны при автоматическом завершении.
//									ЗавершитьЗамерВремени.
//  АвтоЗавершение - Булево	 - 		признак автоматического завершения замера.
//									Истина - завершение замера будет выполнено автоматически
//									через глобальный обработчик ожидания.
//									Ложь - завершить замер необходимо явно вызовом процедуры
//									ЗавершитьЗамерВремени.
//  ИмяПоследнегоШага - Строка - 	имя последнего шага ключевой операции. Целесообразно использовать, если
//									замер запущен с автоматическим завершением. В противным случае последние 
//									действия, выполненные между ЗафиксироватьЗамерДлительнойОперации и 
//									срабатыванием обработчика ожидания будет записано под именем "Последний шаг".
//
// Возвращаемое значение:
//   Соответствие из КлючИЗначение:
//     * Ключ - Строка
//     * Значение - Произвольный
//   Ключи: 
//     # КлючеваяОперация - Строка -  имя ключевой операции.
//     # ВремяНачала - Число - время начала ключевой операции в миллисекундах.
//     # ВремяПоследнегоЗамера - Число - время последнего замера ключевой операции в миллисекундах.
//     # ВесЗамера - Число - количество данных, обработанных в ходе выполнения действий.
//     # ВложенныеЗамеры - Соответствие - коллекция замеров вложенных шагов.
//
Функция НачатьЗамерДлительнойОперации(КлючеваяОперация, ФиксироватьСОшибкой = Ложь, АвтоЗавершение = Ложь, ИмяПоследнегоШага = "ПоследнийШаг") Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат Новый Соответствие;
	КонецЕсли;
	
	Параметры = ПараметрыЗамераВремениНаКлиенте(КлючеваяОперация);
	Параметры.ВыполненаСОшибкой = ФиксироватьСОшибкой;
	Параметры.АвтоЗавершение = АвтоЗавершение;
			
	НачатьЗамерВремениНаКлиентеСлужебный(Параметры);
	
	ЗамерыВремени = ОценкаПроизводительностиЗамерВремени().Замеры;
	ЗамерВремени = ЗамерыВремени[Параметры.УИДЗамера];
	ЗамерВремени.Вставить("ВремяПоследнегоЗамера", ЗамерВремени["ВремяНачала"]);
	ЗамерВремени.Вставить("УдельноеВремя", 0.0);
	ЗамерВремени.Вставить("ВесЗамера", 0);
	ЗамерВремени.Вставить("ВложенныеЗамеры", Новый Соответствие);
	ЗамерВремени.Вставить("УИДЗамера", Параметры.УИДЗамера);
	ЗамерВремени.Вставить("Клиентский", Истина);
	ЗамерВремени.Вставить("ИмяПоследнегоШага", ИмяПоследнегоШага);
	Возврат ЗамерВремени;
	
КонецФункции

// Фиксирует замер вложенного шага длительной операции.
// Параметры:
//  ОписаниеЗамера 		- Соответствие	 - должно быть получено вызовом метода НачатьЗамерДлительнойОперации.
//  КоличествоДанных 	- Число			 - количество данных, например, строк, обработанных в ходе выполнения вложенного шага.
//  ИмяШага 			- Строка		 - произвольное имя вложенного шага.
//  Комментарий 		- Строка		 - произвольное дополнительное описание замера.
//
Процедура ЗафиксироватьЗамерДлительнойОперации(ОписаниеЗамера, КоличествоДанных, ИмяШага, Комментарий = "") Экспорт
	
	Если НЕ ЗначениеЗаполнено(ОписаниеЗамера) Тогда
		Возврат;
	КонецЕсли;
	
	ТекущееВремя = ТекущаяУниверсальнаяДатаВМиллисекундах();
	КоличествоДанныхШага = ?(КоличествоДанных = 0, 1, КоличествоДанных);
	
	Длительность = ТекущееВремя - ОписаниеЗамера["ВремяПоследнегоЗамера"];
	// Если вложенный замер выполняется первый раз, то инициализируем его.
	ВложенныеЗамеры = ОписаниеЗамера["ВложенныеЗамеры"];
	Если ВложенныеЗамеры[ИмяШага] = Неопределено Тогда
		ВложенныеЗамеры.Вставить(ИмяШага, Новый Соответствие);
		ШагВложенногоЗамера = ВложенныеЗамеры[ИмяШага];
		ШагВложенногоЗамера.Вставить("Комментарий", Комментарий);
		ШагВложенногоЗамера.Вставить("ВремяНачала", ОписаниеЗамера["ВремяПоследнегоЗамера"]);
		ШагВложенногоЗамера.Вставить("Длительность", 0.0);	
		ШагВложенногоЗамера.Вставить("ВесЗамера", 0);
	КонецЕсли;                                                            
	// Пишем данные вложенного замера.
	ШагВложенногоЗамера = ВложенныеЗамеры[ИмяШага];
	ШагВложенногоЗамера.Вставить("ВремяОкончания", ТекущееВремя);
	ШагВложенногоЗамера.Вставить("Длительность", Длительность + ШагВложенногоЗамера["Длительность"]);
	ШагВложенногоЗамера.Вставить("ВесЗамера", КоличествоДанныхШага + ШагВложенногоЗамера["ВесЗамера"]);
	
	// Пишем данные длительного замера
	ОписаниеЗамера.Вставить("ВремяПоследнегоЗамера", ТекущееВремя);
	ОписаниеЗамера.Вставить("ВесЗамера", КоличествоДанныхШага + ОписаниеЗамера["ВесЗамера"]);
	
КонецПроцедуры

// Завершает замер длительной операции.
// Если указано имя шага, фиксирует его как отдельный вложенный шаг
// Параметры:
//  ОписаниеЗамера 		- Соответствие	 - должно быть получено вызовом метода НачатьЗамерДлительнойОперации.
//  КоличествоДанных 	- Число			 - количество данных, например, строк, обработанных в ходе выполнения вложенного шага.
//  ИмяШага 			- Строка		 - произвольное имя вложенного шага.
//  Комментарий 		- Строка		 - произвольное дополнительное описание замера.
//
Процедура ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера, КоличествоДанных, ИмяШага = "", Комментарий = "") Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;
		
	Если ОписаниеЗамера["ВложенныеЗамеры"].Количество() > 0 Тогда
		КоличествоДанныхШага = ?(КоличествоДанных = 0, 1, КоличествоДанных);
		ЗафиксироватьЗамерДлительнойОперации(ОписаниеЗамера, КоличествоДанныхШага, 
			?(ПустаяСтрока(ИмяШага), "ПоследнийШаг", ИмяШага), Комментарий);
	КонецЕсли;
	
	УИДЗамера = ОписаниеЗамера["УИДЗамера"];
	ВремяОкончания = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ЗавершитьЗамерВремениСлужебный(УИДЗамера, ВремяОкончания);
	
	ЗамерыВремени = ОценкаПроизводительностиЗамерВремени();
	Если ЗамерыВремени = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Замер = ЗамерыВремени.Замеры[УИДЗамера];
	Если Замер <> Неопределено Тогда
		ЗамерыЗавершенные = ЗамерыВремени.ЗамерыЗавершенные;
		ОписаниеЗамера.Вставить("ВремяОкончания", Замер["ВремяОкончания"]);
		ЗамерыЗавершенные.Вставить(УИДЗамера, ОписаниеЗамера);
		ЗамерыВремени.Замеры.Удалить(УИДЗамера);
	КонецЕсли;

КонецПроцедуры

#Область УстаревшиеПроцедурыИФункции

// Устарела. Будет удалена в следующей редакции библиотеки.
// Необходимо использовать процедуру
//		ОценкаПроизводительностиКлиент.ЗамерВремени
// Начинает замер времени ключевой операции.
// Результат замера будет записан в регистр сведений ЗамерыВремени.
// Поскольку клиентские замеры хранятся в клиентском буфере и записываются с периодичностью,
// указанной в константе ОценкаПроизводительностиПериодЗаписи (по умолчанию, каждую минуту),
// в случае завершения сеанса часть замеров может быть потеряна.
//
// Параметры:
//  АвтоЗавершение - Булево	 - 	признак автоматического завершения замера.
//								Истина - завершение замера будет выполнено автоматически
//								через глобальный обработчик ожидания.
//								Ложь - завершить замер необходимо явно вызовом процедуры
//								ЗавершитьЗамерВремени.
//  КлючеваяОперация - Строка - имя ключевой операции. Если Неопределено> то ключевую операцию
//								необходимо указать явно вызовом процедуры
//								УстановитьКлючевуюОперациюЗамера.
//
// Возвращаемое значение:
//  УникальныйИдентификатор - уникальный идентификатор замера, который позволяет идентифицировать замер.
//
Функция НачатьЗамерВремени(АвтоЗавершение = Истина, КлючеваяОперация = Неопределено) Экспорт
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
	КонецЕсли;

	Параметры = ПараметрыЗамераВремениНаКлиенте(КлючеваяОперация);
	Параметры.АвтоЗавершение = АвтоЗавершение;
	Параметры.ВыполненаСОшибкой = Ложь;

	НачатьЗамерВремениНаКлиентеСлужебный(Параметры);
	Возврат Параметры.УИДЗамера;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияКлиентПереопределяемый.ПередНачаломРаботыСистемы.
Процедура ПередНачаломРаботыСистемы(Параметры) Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.ОценкаПроизводительности.ВремяНачалаЗапуска";
	ВремяНачала = ПараметрыПриложения[ИмяПараметра];
	ПараметрыПриложения.Удалить(ИмяПараметра);
	
	НачатьЗамерВремениСоСмещением(ВремяНачала, Истина, "ОбщееВремяЗапускаПриложения");
	
КонецПроцедуры

// См. ОбщегоНазначенияКлиентПереопределяемый.ПередПериодическойОтправкойДанныхКлиентаНаСервер
Процедура ПередПериодическойОтправкойДанныхКлиентаНаСервер(Параметры) Экспорт
	
	ПараметрыКлиента = ПараметрыПриложения["СтандартныеПодсистемы.ПараметрыКлиента"];
	Если ПараметрыКлиента = Неопределено
	 Или Не ПараметрыКлиента.Свойство("ОценкаПроизводительности") Тогда
		Возврат;
	КонецЕсли;
	ПериодЗаписи = ПараметрыКлиента.ОценкаПроизводительности.ПериодЗаписи;
	
	Если Не СерверныеОповещенияКлиент.ЗакончилосьВремяОжидания("СтандартныеПодсистемы.ОценкаПроизводительности", ПериодЗаписи, Истина) Тогда
		Возврат;
	КонецЕсли;
	
	ЗамерыДляЗаписи = ЗамерыДляЗаписи();
	Если ЗамерыДляЗаписи = Неопределено
	 Или Не ЗначениеЗаполнено(ЗамерыДляЗаписи.ЗамерыЗавершенные) Тогда
		Возврат;
	КонецЕсли;
	
	Параметры.Вставить("СтандартныеПодсистемы.ОценкаПроизводительности.ЗамерыДляЗаписи", ЗамерыДляЗаписи);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Начинает замер времени ключевой операции.
// Результат замера будет записан в регистр сведений ЗамерыВремени.
//
// Параметры:
//  Смещение - Число	 	 - 	дата и время начала замера в миллисекундах (см. ТекущаяУниверсальнаяДатаВМиллисекундах).
//  АвтоЗавершение - Булево	 - 	признак автоматического завершения замера.
//								Истина - завершение замера будет выполнено автоматически
//								через глобальный обработчик ожидания.
//								Ложь - завершить замер необходимо явно вызовом процедуры
//								ЗавершитьЗамерВремени.
//  КлючеваяОперация - Строка - имя ключевой операции. Если Неопределено> то ключевую операцию
//								необходимо указать явно вызовом процедуры
//								УстановитьКлючевуюОперациюЗамера.
//
// Возвращаемое значение:
//  УникальныйИдентификатор - уникальный идентификатор замера, который позволяет идентифицировать замер.
//
Функция НачатьЗамерВремениСоСмещением(Смещение, АвтоЗавершение = Истина, КлючеваяОперация = Неопределено)
	
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000");
	КонецЕсли;

	Параметры = ПараметрыЗамераВремениНаКлиенте(КлючеваяОперация);
	Параметры.АвтоЗавершение = АвтоЗавершение;
	Параметры.ВыполненаСОшибкой = Ложь;
	Параметры.Смещение = Смещение;

	НачатьЗамерВремениНаКлиентеСлужебный(Параметры);
	Возврат Параметры.УИДЗамера;
	
КонецФункции

Функция ВыполнятьЗамерыПроизводительности()
	
	ВыполнятьЗамерыПроизводительности = Ложь;
	
	ИмяПараметраСтандартныеПодсистемы = "СтандартныеПодсистемы.ПараметрыКлиента";
	
	Если ПараметрыПриложения[ИмяПараметраСтандартныеПодсистемы] = Неопределено Тогда
		ВыполнятьЗамерыПроизводительности = ОценкаПроизводительностиВызовСервераПовтИсп.ВыполнятьЗамерыПроизводительности();
	Иначе
		Если ПараметрыПриложения[ИмяПараметраСтандартныеПодсистемы].Свойство("ОценкаПроизводительности") Тогда
			ВыполнятьЗамерыПроизводительности = ПараметрыПриложения[ИмяПараметраСтандартныеПодсистемы]["ОценкаПроизводительности"]["ВыполнятьЗамерыПроизводительности"];
		Иначе
			ВыполнятьЗамерыПроизводительности = ОценкаПроизводительностиВызовСервераПовтИсп.ВыполнятьЗамерыПроизводительности();
		КонецЕсли;
	КонецЕсли;
	
	Возврат ВыполнятьЗамерыПроизводительности; 
	
КонецФункции

// Возвращаемое значение:
//  Структура:
//   * КлючеваяОперация - Строка
//   * УИДЗамера - УникальныйИдентификатор
//   * АвтоЗавершение - Булево
//   * Технологический - Булево
//   * ВыполненаСОшибкой - Булево
//   * Смещение - Число
//   * Комментарий - Строка, Неопределено
//
Функция ПараметрыЗамераВремениНаКлиенте(КлючеваяОперация)

	Параметры = Новый Структура;
	Параметры.Вставить("КлючеваяОперация", КлючеваяОперация);
	Параметры.Вставить("УИДЗамера", Новый УникальныйИдентификатор());
	Параметры.Вставить("АвтоЗавершение", Истина);
	Параметры.Вставить("Технологический", Ложь);
	Параметры.Вставить("ВыполненаСОшибкой", Ложь);
	Параметры.Вставить("Смещение", 0);
	Параметры.Вставить("Комментарий", Неопределено);
	Возврат Параметры;

КонецФункции

// Возвращаемое значение:
//  Структура:
//   * Замеры - Соответствие
//   * ЗамерыЗавершенные - Соответствие
//   * ЕстьОбработчик - Булево
//   * ВремяПодключенияОбработчика - Дата 
//   * СмещениеДатыКлиента - Число
//
Функция ОценкаПроизводительностиЗамерВремени()
	Возврат ПараметрыПриложения["СтандартныеПодсистемы.ОценкаПроизводительностиЗамерВремени"];
КонецФункции

// Параметры:
//  Параметры - см. ПараметрыЗамераВремениНаКлиенте
//
Процедура НачатьЗамерВремениНаКлиентеСлужебный(Параметры)
    
    ВремяНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Если ПараметрыПриложения = Неопределено Тогда
		ПараметрыПриложения = Новый Соответствие;
	КонецЕсли;
		
	ЗамерыВремени = ОценкаПроизводительностиЗамерВремени();
	Если ЗамерыВремени = Неопределено Тогда
		ЗамерыВремени = Новый Структура;
		ЗамерыВремени.Вставить("Замеры", Новый Соответствие);
		ЗамерыВремени.Вставить("ЗамерыЗавершенные", Новый Соответствие);
		ЗамерыВремени.Вставить("ЕстьОбработчик", Ложь);
		ЗамерыВремени.Вставить("ВремяПодключенияОбработчика", ВремяНачала);
		ЗамерыВремени.Вставить("СмещениеДатыКлиента", 0);
		ПараметрыПриложения["СтандартныеПодсистемы.ОценкаПроизводительностиЗамерВремени"] = ЗамерыВремени;
		
		ИмяПараметраСтандартныеПодсистемы = "СтандартныеПодсистемы.ПараметрыКлиента";
		Если ПараметрыПриложения[ИмяПараметраСтандартныеПодсистемы] = Неопределено Тогда
			ПараметрыОценкиПроизводительности = ОценкаПроизводительностиВызовСервера.ПолучитьПараметрыНаСервере();
			ТекущийПериодЗаписи = ПараметрыОценкиПроизводительности.ПериодЗаписи;
			ДатаИВремяНаСервере = ПараметрыОценкиПроизводительности.ДатаИВремяНаСервере;
		
			ДатаИВремяНаКлиенте = ТекущаяУниверсальнаяДатаВМиллисекундах();
			ЗамерыВремени.СмещениеДатыКлиента = ДатаИВремяНаСервере - ДатаИВремяНаКлиенте;
		Иначе
			ТекущийПериодЗаписи = Неопределено; // Смотри ПередПериодическойОтправкойДанныхКлиентаНаСервер.
			ПараметрыПриложенияСтандартныеПодсистемы = ПараметрыПриложения[ИмяПараметраСтандартныеПодсистемы];
			Если ПараметрыПриложенияСтандартныеПодсистемы.Свойство("ОценкаПроизводительности") Тогда
				ЗамерыВремени.СмещениеДатыКлиента = ПараметрыПриложенияСтандартныеПодсистемы["СмещениеДатыКлиента"];
			Иначе
				ПараметрыОценкиПроизводительности = ОценкаПроизводительностиВызовСервера.ПолучитьПараметрыНаСервере();
				ДатаИВремяНаСервере = ПараметрыОценкиПроизводительности.ДатаИВремяНаСервере;
				
				ДатаИВремяНаКлиенте = ТекущаяУниверсальнаяДатаВМиллисекундах();
				ЗамерыВремени.СмещениеДатыКлиента = ДатаИВремяНаСервере - ДатаИВремяНаКлиенте;
			КонецЕсли;
		КонецЕсли;
				
		ИнформацияПрограммыПросмотра = "";
#Если ТолстыйКлиентУправляемоеПриложение Тогда
		ИнформацияПрограммыПросмотра = "ТолстыйКлиентУправляемоеПриложение";
#ИначеЕсли ТолстыйКлиентОбычноеПриложение Тогда
		ИнформацияПрограммыПросмотра = "ТолстыйКлиент";
#ИначеЕсли ТонкийКлиент Тогда
		ИнформацияПрограммыПросмотра = "ТонкийКлиент";
#ИначеЕсли ВебКлиент Тогда
		ИнфоКлиента = Новый СистемнаяИнформация();
		ИнформацияПрограммыПросмотра = ИнфоКлиента.ИнформацияПрограммыПросмотра;
#КонецЕсли
		ЗамерыВремени.Вставить("ИнформацияПрограммыПросмотра", ИнформацияПрограммыПросмотра);
		Если ТекущийПериодЗаписи <> Неопределено Тогда
			ПодключитьОбработчикОжидания("ЗаписатьРезультатыАвто", ТекущийПериодЗаписи, Истина);
		КонецЕсли;
	КонецЕсли;
	
	// Фактическое начало замера времени на клиенте.
	Если Параметры.Смещение > 0 Тогда
		ВремяНачала = Параметры.Смещение + ЗамерыВремени.СмещениеДатыКлиента;
	Иначе
		ВремяНачала = ВремяНачала + ЗамерыВремени.СмещениеДатыКлиента;
	КонецЕсли;
		
	Замер = Новый Соответствие;
	Замер.Вставить("КлючеваяОперация", Параметры.КлючеваяОперация);
	Замер.Вставить("АвтоЗавершение", Параметры.АвтоЗавершение);
	Замер.Вставить("ВремяНачала", ВремяНачала);
	Замер.Вставить("Комментарий", Параметры.Комментарий);
	Замер.Вставить("ВыполненаСОшибкой", Параметры.ВыполненаСОшибкой);
	Замер.Вставить("Технологический", Параметры.Технологический);
	Замер.Вставить("ВесЗамера", 1);
	ЗамерыВремени.Замеры.Вставить(Параметры.УИДЗамера, Замер);

	Если Параметры.АвтоЗавершение Тогда
		Если НЕ ЗамерыВремени.ЕстьОбработчик Тогда
			ПодключитьОбработчикОжидания("ЗакончитьЗамерВремениАвто", 0.1, Истина);
			ЗамерыВремени.ЕстьОбработчик = Истина;
			ЗамерыВремени.ВремяПодключенияОбработчика = ТекущаяУниверсальнаяДатаВМиллисекундах() + ЗамерыВремени.СмещениеДатыКлиента;
		КонецЕсли;	
	КонецЕсли;	
	
КонецПроцедуры

Процедура ЗавершитьЗамерВремениНаКлиентеАвто() Экспорт
	
	ВремяОкончания = ТекущаяУниверсальнаяДатаВМиллисекундах();

	ЗамерыВремени = ОценкаПроизводительностиЗамерВремени();
	Если ЗамерыВремени = Неопределено Тогда
		Возврат;
	КонецЕсли;	

	ДляУдаления = Новый Массив;

	КоличествоНеЗавершенныхАвтоЗамеров = 0;
	Для Каждого ЗамерВремени Из ЗамерыВремени.Замеры Цикл
		ЗамерЗначение = ЗамерВремени.Значение;
		Если ЗамерЗначение["АвтоЗавершение"] Тогда 
			Если ЗамерЗначение["ВремяНачала"] <= ЗамерыВремени.ВремяПодключенияОбработчика 
				И ЗамерЗначение["ВремяОкончания"] = Неопределено Тогда
				// Если есть вложенные замеры, зафиксируем последний шаг.
				Если ЗамерЗначение["ВложенныеЗамеры"] <> Неопределено
					И ЗамерЗначение["ВложенныеЗамеры"].Количество() > 0 Тогда
					ЗафиксироватьЗамерДлительнойОперации(ЗамерЗначение, 1, ЗамерЗначение["ИмяПоследнегоШага"]);
				КонецЕсли;
				
				// Смещение даты клиента рассчитывается внутри процедуры
				ЗавершитьЗамерВремениСлужебный(ЗамерВремени.Ключ, ВремяОкончания);
				Если ЗначениеЗаполнено(ЗамерВремени.Значение["КлючеваяОперация"]) Тогда
					ЗамерыВремени.ЗамерыЗавершенные.Вставить(ЗамерВремени.Ключ, ЗамерВремени.Значение);
				КонецЕсли;
				ДляУдаления.Добавить(ЗамерВремени.Ключ);
			Иначе
				КоличествоНеЗавершенныхАвтоЗамеров = КоличествоНеЗавершенныхАвтоЗамеров + 1;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ЗамерВремени Из ДляУдаления Цикл
		ЗамерыВремени.Замеры.Удалить(ЗамерВремени);
	КонецЦикла;
	
	Если КоличествоНеЗавершенныхАвтоЗамеров = 0 Тогда
		ЗамерыВремени.ЕстьОбработчик = Ложь;
	Иначе
		ПодключитьОбработчикОжидания("ЗакончитьЗамерВремениАвто", 0.1, Истина);
		ЗамерыВремени.ЕстьОбработчик = Истина;
		ЗамерыВремени.ВремяПодключенияОбработчика = ТекущаяУниверсальнаяДатаВМиллисекундах() + ЗамерыВремени.СмещениеДатыКлиента;
	КонецЕсли;
КонецПроцедуры

Процедура ЗавершитьЗамерВремениСлужебный(УИДЗамера, Знач ВремяОкончания)
		
	Если Не ВыполнятьЗамерыПроизводительности() Тогда
		Возврат;
	КонецЕсли;

	ЗамерыВремени = ОценкаПроизводительностиЗамерВремени();
	Если ЗамерыВремени = Неопределено Тогда
		Возврат;
	КонецЕсли;

	СмещениеДатыКлиента = ЗамерыВремени.СмещениеДатыКлиента;
	ВремяОкончания = ВремяОкончания + СмещениеДатыКлиента;

	Замер = ЗамерыВремени.Замеры[УИДЗамера];
	Если Замер <> Неопределено Тогда
		Замер.Вставить("ВремяОкончания", ВремяОкончания);
	КонецЕсли;
	
КонецПроцедуры

// Произвести запись накопленных замеров времени выполнения ключевых операций на сервере.
//
// Параметры:
//  ПередЗавершением - Булево - Истина, если метод вызывается перед закрытием приложения.
//
Процедура ЗаписатьРезультатыАвтоНеГлобальный(ПередЗавершением = Ложь) Экспорт
	
	ЗамерыДляЗаписи = ЗамерыДляЗаписи();
	Если ЗамерыДляЗаписи = Неопределено Тогда
		Возврат;
	КонецЕсли;

	НовыйПериодЗаписи = ОценкаПроизводительностиВызовСервера.ЗафиксироватьДлительностьКлючевыхОпераций(ЗамерыДляЗаписи);
	
	ИмяПараметраСтандартныеПодсистемы = "СтандартныеПодсистемы.ПараметрыКлиента";
	Если ПараметрыПриложения[ИмяПараметраСтандартныеПодсистемы] = Неопределено Тогда
		// Смотри также ПередПериодическойОтправкойДанныхКлиентаНаСервер.
		ПодключитьОбработчикОжидания("ЗаписатьРезультатыАвто", НовыйПериодЗаписи, Истина);
	КонецЕсли;
	
КонецПроцедуры

Функция ЗамерыДляЗаписи()
	
	ЗамерыВремени = ОценкаПроизводительностиЗамерВремени();
	Если ЗамерыВремени = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	ЗамерыЗавершенные = ЗамерыВремени.ЗамерыЗавершенные;
	ЗамерыВремени.ЗамерыЗавершенные = Новый Соответствие;
	
	ЗамерыДляЗаписи = Новый Структура;
	ЗамерыДляЗаписи.Вставить("ЗамерыЗавершенные", ЗамерыЗавершенные);
	ЗамерыДляЗаписи.Вставить("ИнформацияПрограммыПросмотра", ЗамерыВремени.ИнформацияПрограммыПросмотра);
	Возврат ЗамерыДляЗаписи;
	
КонецФункции

#КонецОбласти