# Фоновая геолокация Flutter - пример реализации

## Способы фоновой геолокации

Существует несколько способов фоновой геолокации в приложении Flutter. Главная проблема - определиться с приемлемым расходом батареи и минимально-необходимой частотой запуска. Чтобы выбрать лучший вариант, нужно реализовать их все, протестировав каждый на разных устройствах в течение нескольких дней.

1) Фоновая задача через [workmanager](https://pub.dev/packages/workmanager). Ограничение - не чаще одного раза в [15 минут](https://stackoverflow.com/questions/51202905/execute-task-every-second-using-work-manager-api). Ограничение можно попытаться обойти, но не рекомендуется (требуется несколько дней на эксперименты).

В данном репозитории реализован как раз такой вариант. Локация добавляется в локальное хранилище каждые 15 минут, полный список локаций отображается на экране при запуске приложения. Список автообновляется.

2) Использовать плагины, предоставляющие коллбэки при смене локации. Известно как минимум 2 плагина:
- [location](https://pub.dev/packages/location)
- [flutter_background_geolocation](https://pub.dev/packages/flutter_background_geolocation)

Первый старый, отзывы противоречивые. Второй имеет хорошие отзывы, работает по колбэкам акселерометра, но он [платный](https://www.transistorsoft.com/shop/products/flutter-background-geolocation#plans).

Открытый вопрос - обязательно ли отправлять координаты сразу на сервер (чтобы мониторить локацию сотрудника даже если он не пользуется приложением), или достаточно сохранять координаты локально, а на сервер отправлять только когда приложение будет открыто.

## Точность определения геолокации.

Используемый плагин [geolocator](https://pub.dev/packages/geolocator) умеет определять статус службы геолокации, открывать системное окно настроек, прогревать службу в течение заданного периода, получать локацию с заданной точностью, и т.д. Программно выбирать источники (например только GPS) скорее всего не получится, но возможно получится прочитать список используемых источников. Вообще-то этот вопрос правильнее отдать операционной системе. Предлагаю ограничиться указанием максимальной точности и максимального времени прогрева, все остальное ОС должна сделать сама. Требуется несколько дней на тестирование.

В данном репозитарии запрашивается максимальная точность с временем прогрева до 30 секунд.

## Работа при отсутствии сети

Чтобы выбрать локальную БД (SQLite, Hive, Shared Preferences), нужно сначала понимать структуру и объем данных, которые должны быть сохранены локально. В данном репозитарии используется самый примитивный вариант - данные хранятся в виде сериализованных строк в [shared_preferences](https://pub.dev/packages/shared_preferences). 

Качественная обработка сетевых ошибок (перехват, логгирование, уведомление пользователя, восстановление) - дело трудоемкое, сначала надо посмотреть, как работа с сетью реализована в существующем приложении. Оценка работы - до 2-х недель.

## Резюме
Для решения по архитектуре и оценки трудозатрат сначала нужно ответить на вопросы:

1) С какой минимальной частотой нужно снимать гео?
2) Эта частота разная для фонового и обычного режимов?
3) Нужно ли отправлять гео на сервер, если приложение закрыто, или достаточно сохранять локально?
4) Оффлайн-режим - нужна структура данных или дизайн-макеты, чтобы понимать сколько данных и в каком формате нужно сохранять локально.
5) Работа с сетью - нужно посмотреть, что уже сделано в текущем приложении, как обрабатываются сетевые ошибки.
6) Индикаторы состояния сети, кол-ва неотправленных данных - нужно посмотреть экраны, чтобы понять, куда эти индикаторы выводить.
PS
Блокирование пользовательского интерфейса невозможно при работе с сетью и датчиками, так работает флаттер, этот вопрос можно снять.

Если уж совсем приблизительно, и приложение уже существует и как-то работает, то на разработку и предварительное тестирование уйдет 3..4 недели.
Для тестирования нужен один человек, который будет жить неделю с несколькими телефонами, и отслеживать расход батареи для разных алгоритмов геолокации.
С учетом финального тестирования - можно смело писать 4..5 недель. Но лучше сначала увидеть приложение.

### Мини-задание:
  предложить proof of concept/техническое описание верхнеуровнего дизайна следующего решения:
  -- имеется мобильное приложение "список задач выездного исполнителя". Реализован просмотр списка задач, детальная форма задачи, функционал обработки (закрытие, перевод на след. этап, добавление примечания) задачи, страницы профиля и аутентификации
  -- требуется реализовать:
      -- функционал получения текущих координат исполнителя и передачи их на сервер
          -- должна учитываться особенность gps: сразу после включения, датчик требуется прогреть в течение хотя бы 5с, иначе точность измерений будет недопустимо  низкой
          -- дожна быть обеспечена возможность принудительно отключить получение координат любым способом, кроме датчика GPS (т.к. точность получения по другим каналам разная и недопустимо ниже, чем по GPS)
          -- координаты должны сниматься, даже если пользователь перевел приложение в background

-- оффлайн-режим
          -- при обновлении/открытии экрана в МП, должна отображаться информация, ранее полученная с сервера (если с момента запуска МП она хотя бы раз была запрошена), даже если сервер недоступен/нет сети. Если информация не сохранена, поведение приложения должно быть понятно пользователю
          -- координаты устройства, регулярно получаемые с GPS, должны храниться на время недоступности сервера/отсутствия сети и после установления подключения передаваться на сервер
              -- передача координат не должна никак блокировать действия пользователя в ui
          -- пользователь имеет возможность видеть текущий статус соединения с сервером: установлено/нет сети/сервер недоступен
          -- пользователь имеет возможность видеть, имеются ли непереданные на сервер накопленные в offline даннные. Идет ли передача данных на сервер
  -- все допущения, предположения, утверждения и тезисы, используемые в описании proof of concept, сопроводить ссылками на необходимые подтверждения в сторонних источниках (страницы описания плагинов, статей, спецификаций, похожих примеров и т.п.)
  -- дополнительно по возможности прошу предоставить верхнеуровневую декомпозицию и оценку трудоемкости задач. Желательно дать оценку трудоемкости не только по разработке, но и по тестированию.