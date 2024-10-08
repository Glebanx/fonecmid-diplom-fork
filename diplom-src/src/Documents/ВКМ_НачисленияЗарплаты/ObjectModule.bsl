
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Движения.ВКМ_ОсновныеНачисления.Записывать = Истина;
	Движения.ВКМ_ДополнительныеНачисления.Записывать = Истина; 
	Движения.ВКМ_Удержания.Записывать = Истина;
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	
	ЗаписатьДвижения(); 
	
	РассчитатьОклад();
	
	РассчитатьОтпуск(); 
	РассчитатьДопНачисления();
	РассчитатьНДФЛ();
	
	//+++МГН 01.10.2024
	СформироватьВзаиморасчетыССотрудниками();
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаписатьДвижения()

	Для Каждого Строка Из ВКМ_ОсновныеНачисления Цикл 
		
		Движение = Движения.ВКМ_ОсновныеНачисления.Добавить();
		Движение.ВидРасчета = Строка.ВКМ_ВидРасчета;
		Движение.ПериодДействияНачало = Строка.ВКМ_ДатаНачала;
		Движение.ПериодДействияКонец = Строка.ВКМ_ДатаОкончания;
		Движение.ПериодРегистрации = Дата;
		Движение.ВКМ_Сотрудник = Строка.ВКМ_Сотрудник;
		Движение.ВКМ_ГрафикРаботы = Строка.ВКМ_ГрафикРаботы;
		
		Если Строка.ВКМ_ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск Тогда 
			Движение.БазовыйПериодНачало = НачалоМесяца(ДобавитьМесяц(Строка.ВКМ_ДатаНачала, -12));
		    Движение.БазовыйПериодКонец = КонецМесяца(ДобавитьМесяц(Строка.ВКМ_ДатаОкончания, -1));
		ИначеЕсли Строка.ВКМ_ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад Тогда 
			Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		    Движение.БазовыйПериодКонец = КонецМесяца(Дата);
		КонецЕсли;
				
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать();
	
	Для Каждого Строка Из ВКМ_ДополнительныеНачисления Цикл 
		
		Движение = Движения.ВКМ_ДополнительныеНачисления.Добавить();
		Движение.ВидРасчета = Строка.ВКМ_ВидРасчета;
		Движение.ПериодРегистрации = Дата;
		Движение.ВКМ_Сотрудник = Строка.ВКМ_Сотрудник;
		
	КонецЦикла;
	
	Движения.ВКМ_ДополнительныеНачисления.Записать();
	
	
КонецПроцедуры 

Процедура РассчитатьОклад()

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЕСТЬNULL(ВКМ_УсловияОплатыСотрудниковСрезПоследних.ВКМ_Оклад, 0) КАК Оклад,
	               |	ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
	               |	ВКМ_ОсновныеНачисленияДанныеГрафика.ВКМ_Сотрудник КАК Сотрудник,
	               |	ВКМ_ОсновныеНачисленияДанныеГрафика.ДнейФактическийПериодДействия КАК ОтработаноДней,
	               |	ВКМ_ОсновныеНачисленияДанныеГрафика.ДнейПериодДействия КАК ДнейПериодДействия
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
	               |			Регистратор = &Ссылка
	               |				И ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНачисления.Оклад)) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(
	               |				&Дата,
	               |				ВКМ_Сотрудник В
	               |					(ВЫБРАТЬ
	               |						ВКМ_НачисленияЗарплатыВКМ_ОсновныеНачисления.ВКМ_Сотрудник КАК ВКМ_Сотрудник
	               |					ИЗ
	               |						Документ.ВКМ_НачисленияЗарплаты.ВКМ_ОсновныеНачисления КАК ВКМ_НачисленияЗарплатыВКМ_ОсновныеНачисления
	               |					ГДЕ
	               |						ВКМ_НачисленияЗарплатыВКМ_ОсновныеНачисления.Ссылка = &Ссылка)) КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних
	               |		ПО ВКМ_ОсновныеНачисленияДанныеГрафика.ВКМ_Сотрудник = ВКМ_УсловияОплатыСотрудниковСрезПоследних.ВКМ_Сотрудник";
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("Ссылка", Ссылка); 
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
			
		Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1];
		Движение.ВКМ_Показатель = Выборка.Оклад; 
		Движение.ВКМ_ОтработаноДней = Выборка.ОтработаноДней;  
		
		Если Выборка.ДнейПериодДействия = Выборка.ОтработаноДней Тогда 
			Движение.ВКМ_Результат = Выборка.Оклад;
		Иначе
			Движение.ВКМ_Результат = (Выборка.Оклад / Выборка.ДнейПериодДействия) * Выборка.ОтработаноДней;
		КонецЕсли;
				
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);
КонецПроцедуры  

Процедура РассчитатьОтпуск()

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.НомерСтроки КАК НомерСтроки,
	               |	ЕСТЬNULL(ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ВКМ_РезультатБаза, 0) КАК База,
	               |	РАЗНОСТЬДАТ(ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ПериодДействияНачало, ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ПериодДействияКонец, ДЕНЬ) + 1 КАК ФактДней,
	               |	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ВКМ_ОтработаноДнейБаза КАК ОтработаноДнейБаза,
	               |	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.БазовыйПериодНачало КАК БазовыйПериодНачало,
	               |	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.БазовыйПериодКонец КАК БазовыйПериодКонец,
	               |	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ВКМ_Сотрудник КАК Сотрудник,
	               |	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ПериодДействияНачало КАК ПериодДействияНачало,
	               |	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ПериодДействияКонец КАК ПериодДействияКонец
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновныеНачисления.БазаВКМ_ОсновныеНачисления(
	               |			&Измерения,
	               |			&Измерения,
	               |			,
	               |			Регистратор = &Ссылка
	               |				И ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск)) КАК ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления";
	
	Измерения = Новый Массив;
	Измерения.Добавить("ВКМ_Сотрудник");
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Измерения", Измерения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		
		Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1];
		Движение.ВКМ_Показатель = Выборка.База / Выборка.ОтработаноДнейБаза;
		Движение.ВКМ_Результат = Выборка.ФактДней * Движение.ВКМ_Показатель;
		Движение.ВКМ_ДнейОтпуска = (Выборка.ПериодДействияКонец + 1 - Выборка.ПериодДействияНачало) / (24 * 3600);
		
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);

КонецПроцедуры

Процедура РассчитатьДопНачисления()	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_УсловияОплатыСотрудниковСрезПоследних.ВКМ_ПроцентОтРабот КАК ПроцентОтРабот,
	               |	ВКМ_ВыполненныеСотрудникомРаботыОбороты.ВКМ_СуммаКОплатеОборот КАК СуммаКОплатеОборот,
	               |	ВКМ_ДополнительныеНачисления.НомерСтроки КАК НомерСтроки
	               |ИЗ
	               |	РегистрНакопления.ВКМ_ВыполненныеСотрудникомРаботы.Обороты(
	               |			&НачалоПериода,
	               |			&КонецПериода,
	               |			Месяц,
	               |			ВКМ_Сотрудник В
	               |				(ВЫБРАТЬ
	               |					ВКМ_НачисленияЗарплатыВКМ_ДополнительныеНачисления.ВКМ_Сотрудник КАК ВКМ_Сотрудник
	               |				ИЗ
	               |					Документ.ВКМ_НачисленияЗарплаты.ВКМ_ДополнительныеНачисления КАК ВКМ_НачисленияЗарплатыВКМ_ДополнительныеНачисления
	               |				ГДЕ
	               |					ВКМ_НачисленияЗарплатыВКМ_ДополнительныеНачисления.Ссылка = &Ссылка)) КАК ВКМ_ВыполненныеСотрудникомРаботыОбороты
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(
	               |				&Дата,
	               |				ВКМ_Сотрудник В
	               |					(ВЫБРАТЬ
	               |						ВКМ_НачисленияЗарплатыВКМ_ДополнительныеНачисления.ВКМ_Сотрудник КАК ВКМ_Сотрудник
	               |					ИЗ
	               |						Документ.ВКМ_НачисленияЗарплаты.ВКМ_ДополнительныеНачисления КАК ВКМ_НачисленияЗарплатыВКМ_ДополнительныеНачисления
	               |					ГДЕ
	               |						ВКМ_НачисленияЗарплатыВКМ_ДополнительныеНачисления.Ссылка = &Ссылка)) КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних
	               |		ПО ВКМ_ВыполненныеСотрудникомРаботыОбороты.ВКМ_Сотрудник = ВКМ_УсловияОплатыСотрудниковСрезПоследних.ВКМ_Сотрудник
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
	               |		ПО ВКМ_ВыполненныеСотрудникомРаботыОбороты.ВКМ_Сотрудник = ВКМ_ДополнительныеНачисления.ВКМ_Сотрудник
	               |ГДЕ
	               |	ВКМ_ДополнительныеНачисления.Регистратор = &Ссылка
	               |	И ВКМ_ДополнительныеНачисления.ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ДополнительныеНачисления.ПроцентОтРабот)"; 
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("НачалоПериода", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("КонецПериода", КонецМесяца(Дата));
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		
		Движение = Движения.ВКМ_ДополнительныеНачисления[Выборка.НомерСтроки - 1];
		Движение.ВКМ_Процент = Выборка.ПроцентОтРабот;
		Движение.ВКМ_Результат = Выборка.СуммаКОплатеОборот;		
	КонецЦикла;
	
	Движения.ВКМ_ДополнительныеНачисления.Записать(, Истина); 

		
КонецПроцедуры

Процедура РассчитатьНДФЛ()
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ОсновныеНачисления.ВКМ_Сотрудник КАК ВКМ_Сотрудник,
		|	ВКМ_ОсновныеНачисления.ВКМ_Результат КАК ВКМ_Результат
		|ПОМЕСТИТЬ ВТ_ОсновныеИДопНачисления
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
		|ГДЕ
		|	ВКМ_ОсновныеНачисления.Регистратор = &Регистратор
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ВКМ_ДополнительныеНачисления.ВКМ_Сотрудник,
		|	ВКМ_ДополнительныеНачисления.ВКМ_Результат
		|ИЗ
		|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
		|ГДЕ
		|	ВКМ_ДополнительныеНачисления.Регистратор = &Регистратор
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ОсновныеИДопНачисления.ВКМ_Сотрудник КАК ВКМ_Сотрудник,
		|	СУММА(ВТ_ОсновныеИДопНачисления.ВКМ_Результат) КАК ВКМ_Результат
		|ИЗ
		|	ВТ_ОсновныеИДопНачисления КАК ВТ_ОсновныеИДопНачисления
		|
		|СГРУППИРОВАТЬ ПО
		|	ВТ_ОсновныеИДопНачисления.ВКМ_Сотрудник";
	
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	НДФЛ = 13;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.ВКМ_Сотрудник = ВыборкаДетальныеЗаписи.ВКМ_Сотрудник;
		Движение.ПериодРегистрации = Дата; 
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
		
		Показатель = ВыборкаДетальныеЗаписи.ВКМ_Результат;
		Удержание = Показатель * НДФЛ / 100;

		Движение.ВКМ_Показатель = Показатель;
		Движение.ВКМ_Результат = Удержание;
		
	КонецЦикла;
	
    Движения.ВКМ_Удержания.Записать();
	
КонецПроцедуры

Процедура СформироватьВзаиморасчетыССотрудниками()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_Удержания.ВКМ_Сотрудник КАК Сотрудник,
		|	ВКМ_Удержания.ВКМ_Показатель - ВКМ_Удержания.ВКМ_Результат КАК Сумма
		|ИЗ
		|	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
		|ГДЕ
		|	ВКМ_Удержания.Регистратор = &Регистратор";
	
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.Период = Дата;
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.ВКМ_Сотрудник = ВыборкаДетальныеЗаписи.Сотрудник;
		Движение.ВКМ_Сумма = ВыборкаДетальныеЗаписи.Сумма;
	КонецЦикла;

    Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();

КонецПроцедуры

#КонецОбласти

#КонецЕсли
