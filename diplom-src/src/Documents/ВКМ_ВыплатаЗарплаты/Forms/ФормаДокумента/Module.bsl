
&НаСервере
Процедура ВКМ_АвтозаполнениеНаСервере()
	Объект.ВКМ_Выплаты.Очистить();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ВзаиморасчетыССотрудникамиОстатки.ВКМ_Сотрудник КАК Сотрудник,
	               |	ВКМ_ВзаиморасчетыССотрудникамиОстатки.ВКМ_СуммаОстаток КАК СуммаОстаток
	               |ИЗ
	               |	РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками.Остатки(КОНЕЦПЕРИОДА(&Дата, МЕСЯЦ), ) КАК ВКМ_ВзаиморасчетыССотрудникамиОстатки";
	
	Запрос.УстановитьПараметр("Дата", Объект.Дата);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		НоваяСтрока = Объект.ВКМ_Выплаты.Добавить();
		НоваяСтрока.ВКМ_Сотрудник = Выборка.Сотрудник;
		НоваяСтрока.ВКМ_Сумма = Выборка.СуммаОстаток;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ВКМ_Автозаполнение(Команда)
	ВКМ_АвтозаполнениеНаСервере();
КонецПроцедуры
