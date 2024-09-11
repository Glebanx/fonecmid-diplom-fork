
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Ответственный = Пользователи.ТекущийПользователь();
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ОбработкаЗаказов.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;
	
	Движение = Движения.ОбработкаЗаказов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Заказ = Основание;
	Движение.СуммаОтгрузки = СуммаДокумента;
    //+++МГН 10.09.2024 (ВКМ) 
	НоменклатураРаботы = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	Для Каждого Строка Из Услуги Цикл
		Если Строка.Номенклатура = НоменклатураРаботы Тогда 
			Движение.ВКМ_ЕстьРаботыСпециалиста = Истина;
			Движение.ВКМ_СуммаПоРаботамСпециалиста = Строка.Сумма;
		КонецЕсли;
	КонецЦикла;	
	//---МГН 10.09.2024 (ВКМ) 
	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Сумма;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказПокупателя.Организация КАК Организация,
	               |	ЗаказПокупателя.Контрагент КАК Контрагент,
	               |	ЗаказПокупателя.Договор КАК Договор,
	               |	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
	               |	ЗаказПокупателя.Товары.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Товары,
	               |	ЗаказПокупателя.Услуги.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Услуги
	               |ИЗ
	               |	Документ.ЗаказПокупателя КАК ЗаказПокупателя
	               |ГДЕ
	               |	ЗаказПокупателя.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
	
	ТоварыОснования = Выборка.Товары.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
	КонецЦикла;
	
	УслугиОснования = Выборка.Услуги.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
	КонецЦикла;
	
	Основание = ДанныеЗаполнения;
	
КонецПроцедуры

//+++МГН 05.09.2024 (ВКМ)

Процедура ВКМ_ВыполнитьАвтозаполнение() Экспорт
	НоменклатураАбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	НоменклатураРаботыСпециалиста = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	
	Если НЕ ЗначениеЗаполнено(НоменклатураАбонентскаяПлата) ИЛИ НЕ ЗначениеЗаполнено(НоменклатураРаботыСпециалиста) Тогда 
		ОбщегоНазначения.СообщитьПользователю("Проверьте заполнение констант ""Номенклатура абонентская плата"" и ""Номенклатура работы специалиста""");
		Возврат;
	КонецЕсли; 
	
	Товары.Очистить();
	Услуги.Очистить();
	
	СуммаАбонентскойПлаты = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "ВКМ_СуммаАбонентскойПлаты");
	
	Если СуммаАбонентскойПлаты <> 0 Тогда 
		
		НоваяСтрока = Услуги.Добавить();
		НоваяСтрока.Номенклатура = НоменклатураАбонентскаяПлата;
		НоваяСтрока.Количество = 1;
		НоваяСтрока.Цена = СуммаАбонентскойПлаты;		
		НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена;
	КонецЕсли;                           
	
	ВыполненныеРаботыЗаМесяц = ВКМ_ПолучитьВыполенныеРаботы(); 	
	
	Если ВыполненныеРаботыЗаМесяц.Количество() <> 0 Тогда 
		
		ВКМ_КоличествоЧасов = ВыполненныеРаботыЗаМесяц[0].КоличествоЧасов;
		ВКМ_СуммаКОплате = ВыполненныеРаботыЗаМесяц[0].СуммаКОплате;
		
		НоваяСтрока = Услуги.Добавить();
		НоваяСтрока.Номенклатура = НоменклатураРаботыСпециалиста;
		НоваяСтрока.Количество = ВКМ_КоличествоЧасов;
		НоваяСтрока.Сумма = ВКМ_СуммаКОплате;
		НоваяСтрока.Цена = НоваяСтрока.Сумма / НоваяСтрока.Количество;
		
	КонецЕсли; 
	
	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");	
КонецПроцедуры

Функция ВКМ_ПолучитьВыполенныеРаботы()

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботыОбороты.ВКМ_КоличествоЧасовОборот, 0) КАК КоличествоЧасов,
	               |	ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботыОбороты.ВКМ_СуммаКОплатеОборот, 0) КАК СуммаКОплате
	               |ИЗ
	               |	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(НАЧАЛОПЕРИОДА(&Период, МЕСЯЦ), КОНЕЦПЕРИОДА(&Период, МЕСЯЦ), Месяц, ВКМ_Договор = &Договор) КАК ВКМ_ВыполненныеКлиентуРаботыОбороты";
	
	Запрос.УстановитьПараметр("Договор", Договор);
	Запрос.УстановитьПараметр("Период", Дата);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

//---МГН 05.09.2024 (ВКМ)


#КонецОбласти

#КонецЕсли
