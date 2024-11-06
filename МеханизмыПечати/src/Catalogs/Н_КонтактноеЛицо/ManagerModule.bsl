Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка) Экспорт
    Поля.Добавить("ФИО");
    Поля.Добавить("ДействуетНаОсновании");
    СтандартнаяОбработка = Ложь;
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка) Экспорт
    СтандартнаяОбработка = Ложь;
    Представление = Данные.ФИО;
    Если НЕ ПустаяСтрока(Данные.ДействуетНаОсновании) Тогда
        Представление = Представление + " (Действует на основании: " + Данные.ДействуетНаОсновании + ")";
    КонецЕсли;
КонецПроцедуры