﻿#language: ru

@tree

Функционал: Использование обработки "Массовое создание актов"

Как Бухгалтер я хочу
проверить использование обработки "Массовое создание актов"  
чтобы удостоверится в работе функционала     

Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий

Сценарий: Я использую групповую обработку Массовое создание актов
И В командном интерфейсе я выбираю 'Обслуживание клиентов' 'Массовое создание актов'
Тогда открылось окно 'Массовое создание актов'
И я нажимаю кнопку выбора у поля с именем "ВКМ_Период"
И в поле с именем 'ВКМ_Период' я ввожу текст '11.09.2024'
И я нажимаю на кнопку с именем 'ФормаСоздатьДокументыРеализации'
