/* Copyright (c) 2006-2008 MetaCarta, Inc., published under the Clear BSD
 * license.  See http://svn.openlayers.org/trunk/openlayers/license.txt for the
 * full text of the license. */

/* Translators (2009 onwards):
 *  - Ferrer
 *  - Lockal
 *  - Александр Сигачёв
 */

/**
 * @requires OpenLayers/Lang.js
 */

/**
 * Namespace: OpenLayers.Lang["ru"]
 * Dictionary for Русский.  Keys for entries are used in calls to
 *     <OpenLayers.Lang.translate>.  Entry bodies are normal strings or
 *     strings formatted for use with <OpenLayers.String.format> calls.
 */
OpenLayers.Lang["ru"] = OpenLayers.Util.applyDefaults({

    'unhandledRequest': "Неподдерживамый запрос вернул ${statusText}",

    'permalink': "Постоянная ссылка",

    'overlays': "Оверлеи",

    'baseLayer': "Базовый слой",

    'sameProjection': "Обзорная карта работает только если она использует ту же проекцию, что и основная карта",

    'readNotImplemented': "Чтение не выполняется.",

    'writeNotImplemented': "Запись не выполняется.",

    'noFID': "Не удаётся обновить функцию, для которой нет FID.",

    'errorLoadingGML': "Ошибка при загрузке файла GML ${url}",

    'browserNotSupported': "Ваш браузер не поддерживает векторные изображения. В настоящее поддерживают работу с векторами:\n${renderers}",

    'componentShouldBe': "addFeatures: компонент должен быть ${geomType}",

    'getFeatureError': "getFeatureFromEvent была вызван из слоя, без рендерера. Обычно это означает, что вы уничтожили слой, а не какой-то связанный с ним обработчик.",

    'minZoomLevelError': "Свойство minZoomLevel предназначено только для использования со слоями, являющимися потомками FixedZoomLevels. То, что этот WFS-слой проверяется на minZoomLevel — реликт прошлого. Однако мы не можем удалить эту функцию, так как, возможно, от неё зависят некоторые основанные на OpenLayers приложения. Функция объявлена устаревшей — проверка minZoomLevel будет удалена в 3.0. Пожалуйста, используйте вместо неё настройку мин/макс разрешения, описанную здесь: http://trac.openlayers.org/wiki/SettingZoomLevels",

    'commitSuccess': "Транзакция WFS: Успешно ${response}",

    'commitFailed': "Транзакция WFS: Не удалось ${response}",

    'googleWarning': "Не удалось правильно загрузить слой Google.\x3cbr\x3e\x3cbr\x3eЧтобы избавиться от этого сообщения выберите новый BaseLayer в переключателе слоёв в верхнем правом углу.\x3cbr\x3e\x3cbr\x3eСкорее всего это объясняется тем, что библиотечный скрипт Карт Google не включён, или не содержат правильный API-ключ для вашего сайта.\x3cbr\x3e\x3cbr\x3e Разработчикам. Помощь в корректной настройке этого механизма можно получить в \x3ca href=\'http://trac.openlayers.org/wiki/Google\' target=\'_blank\'\x3eвики\x3c/a\x3e.",

    'getLayerWarning': "Слой ${layerType} не удалось правильно загрузить.\x3cbr\x3e\x3cbr\x3eЧтобы избавиться от этого сообщения, выберите новый БазовыйСлой в переключателе слоёв в верхнем правом углу.\x3cbr\x3e\x3cbr\x3eСкорее всего, это произолшо из-за того, что библиотека скрипта ${layerLib} некорректно включена.\x3cbr\x3e\x3cbr\x3eДля разработчиков: см. \x3ca href=\'http://trac.openlayers.org/wiki/${layerLib}\' target=\'_blank\'\x3eвики\x3c/a\x3e для получения помощи о правильной работе.",

    'scale': "Масштаб = 1 : ${scaleDenom}",

    'layerAlreadyAdded': "Вы попытались добавить слой «${layerName}» на карту, но он уже был добавлен",

    'reprojectDeprecated': "Вы используете настройку «reproject» на слое ${layerName}. Этот настройка устарела, она была разработана для поддержки отображения данных на коммерческих картах, но сейчас эта функциональность достигается с помощью поддержки сферической меркаторской проекции. Более подробную информацию можно найти на http://trac.openlayers.org/wiki/SphericalMercator.",

    'methodDeprecated': "Этот метод не рекомендуется использовать и будет удалён в версии 3.0. Пожалуйста, используйте ${newMethod}.",

    'boundsAddError': "Вы должны передать одновременно значения x и y для функции добавления.",

    'lonlatAddError': "Вы должны передать одновременно значения lon и lat для функции добавления.",

    'pixelAddError': "Вы должны передать одновременно значения x и y для функции добавления.",

    'unsupportedGeometryType': "Неподдерживаемый геометрический тип: ${geomType}",

    'pagePositionFailed': "OpenLayers.Util.pagePosition не удалось: элемент с id ${elemId} может быть перемещён.",

    'filterEvaluateNotImplemented': "«evaluate» не выполнено для этого типа фильтра."

});
