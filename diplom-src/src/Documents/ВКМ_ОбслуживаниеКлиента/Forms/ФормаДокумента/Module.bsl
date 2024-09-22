#Область ОбработчикиСобытийФормы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	ПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
КонецПроцедуры





&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	ДанныеДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ТекущийОбъект.Ссылка, "Дата, Специалист");
	ДокументИзменен = Не ТекущийОбъект.Проведен ИЛИ (ДанныеДокумента.Дата <> ТекущийОбъект.Дата) ИЛИ ДанныеДокумента.Специалист <> ТекущийОбъект.Специалист;
    Текст = "";
	
	Если Не ТекущийОбъект.Проведен Тогда  
		Текст = СтрШаблон("Создан новый документ %1", ТекущийОбъект.Ссылка);
	ИначеЕсли ДанныеДокумента.Дата <> ТекущийОбъект.Дата Тогда  
		Текст = Текст + Символы.ПС + СтрШаблон("Изменилась дата в документе %1 на %2", ТекущийОбъект.Ссылка, ТекущийОбъект.Дата);
	ИначеЕсли ДанныеДокумента.Специалист <> ТекущийОбъект.Специалист Тогда 
		Текст = Текст + Символы.ПС + СтрШаблон("Изменился специалист в документе %1 на %2", ТекущийОбъект.Ссылка, ТекущийОбъект.Специалист);
	КонецЕсли;
	
		
	Если ДокументИзменен Тогда 
		
		НовыйСпр = Справочники.ВКМ_УведомленияТелеграмБоту.СоздатьЭлемент();
		НовыйСпр.ВКМ_ТекстСообщения = Текст; 
		НовыйСпр.Записать();
		
	КонецЕсли;
КонецПроцедуры
#КонецОбласти





#Область СлужебныеПроцедурыИФункции
#Область ПодключаемыеКоманды

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
    ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
    ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
    ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти
#КонецОбласти