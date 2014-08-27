/**
 * Created by zhuk on 13.08.14.
 */
/**
 * Кластеризатор с составными иконками кластеров.
 * @see http://api.yandex.ru/maps/doc/jsapi/2.x/ref/reference/Clusterer.xml
 * @class
 * @augments ymaps.Clusterer
 * @name PieChartClusterer
 * @param {Object} [options] Опции кластеризатора.
 */

MarkersApointmentColours = [];
MarkersApointmentColours["БНК"]='twirl#pinkIcon';
MarkersApointmentColours["ДОУ"]='twirl#violetIcon';
MarkersApointmentColours["жилье"]='twirl#darkgreenIcon';
MarkersApointmentColours["Поликлиника"]='twirl#yellowIcon';
MarkersApointmentColours["Дороги"]='twirl#violetIcon';
MarkersApointmentColours["ФОК"]='twirl#darkblueIcon';
MarkersApointmentColours["Прочие объекты"]='twirl#greyIcon';
MarkersApointmentColours["Спорт - ФОК"]='twirl#darkblueIcon';
MarkersApointmentColours["школа"]='twirl#redIcon';


function PieChartClusterer(options) {
    PieChartClusterer.superclass.constructor.apply(this, arguments);
}

/**
 * Соответствие цветов иконок АПИ с RRGGBB[AA] форматом.
 * @static
 * @constant
 */
PieChartClusterer.COLOURS = {
    "blue"       : "0A6CC8",
    "darkblue"   : "3D4AE9",
    "darkgreen"  : "158B02",
    "darkorange" : "CD6D2D",
    "green"      : "1AB500",
    "grey"       : "94948E",
    "lightblue"  : "4391E7",
    "night"      : "143A6B",
    "orange"     : "CCA42B",
    "pink"       : "E666DD",
    "red"        : "E03632",
    "violet"     : "A41DE2",
    "white"      : "FFFFFF",
    "yellow"     : "D4C62C",
    "brown"      : "946134",
    "black"      : "000000"
};

/**
 * Размеры иконок для всех размеров кластеров.
 * Элементов в этом массиве должно быть на 1 больше, чем элементов в массиве 'NUMBERS'.
 * @static
 * @constant
 */
PieChartClusterer.SIZES = [
    [60, 60],
    [75, 75],
    [90, 90]
];



/**
 * Массив, описывающий граничные значения для размеров кластеров.
 * @see http://api.yandex.ru/maps/doc/jsapi/2.x/ref/reference/Cluster.xml
 * @static
 * @constant
 */
PieChartClusterer.NUMBERS = [3, 8];

/**
 * Прозрачность иконки кластера.
 * @static
 * @constant
 */
PieChartClusterer.OPACITY = 0.7;

/**
 * Шаблон урла иконки кластера.
 * @static
 * @constant
 */
PieChartClusterer.URL_TEMPLATE = [
    '//chart.googleapis.com/chart?cht=pc',
    'chs=#{width}x#{height}', // Размеры чарта.
    'chd=t:1|#{data}', // Данные чарта.
    'chco=FFFFFF,#{colours}', // Цвета сегментов.
    'chf=a,s,000000#{opacity}|bg,s,00000000' // Background.
].join('&');


/**
 * Преобразование значения прозрачности иконки кластера из диапазона [0..1] в [00..FF].
 * @static
 * @function
 * @name PieChartClusterer.dec2hex
 * @param {Number} dec Прозрачность в диапазоне от 0 до 1.
 * @returns {String} Hex представление прозрачности в диапазоне от 00 до FF.
 */
PieChartClusterer.dec2hex = function (dec) {
    var hex = Math.floor(dec * 255).toString(16);

    return hex.length < 2 && '0' + hex || hex;
};

/**
 * Наследуемся после готовности АПИ.
 * @lends PieChartClusterer.prototype
 * @augments ymaps.Clusterer
 */
yamaps_ready_function = function(){
    ymaps.util.augment(PieChartClusterer, ymaps.Clusterer, {
        /**
         * Это перекрытие для базоваго метода ymaps.Clusterer,
         * рекомендованный разработчиками способ изменения вида кластера.
         * @see http://api.yandex.ru/maps/doc/jsapi/2.x/ref/reference/Clusterer.xml#createCluster
         * @function
         * @name PieChartClusterer.createCluster
         * @param {Number[]} center Координаты центра кластера.
         * @param {ymaps.GeoObject[]} geoObjects Массив геообъектов кластера.
         */
        createCluster: function (center, geoObjects) {
            var cluster = PieChartClusterer.superclass.createCluster.apply(this, arguments);

            // Выставляем кластеру нужные опции.
            cluster.options.set({
                icons: this.getClusterIcons(geoObjects),
                numbers: this.getClusterNumbers()
            });

            return cluster;
        },

        /**
         * Получение опции 'clusterNumbers' - определяет количество групп размеров иконок кластера
         * по количеству содержащихся в нем геообъектов.
         * @function
         * @name PieChartClusterer.getClusterNumbers
         * @returns {Number[]} Опция кластера.
         */
        getClusterNumbers: function () {
            return this.options.get('clusterNumbers', PieChartClusterer.NUMBERS);
        },

        /**
         * Получение опции 'clusterIconOpacity' - определяет значение прозрачности иконки кластера.
         * @function
         * @name PieChartClusterer.getClusterIconOpacity
         * @returns {Number} Значение прозрачности иконок в диапазоне от 0 до 1.
         */
        getClusterIconOpacity: function () {
            return this.options.get('clusterIconOpacity', PieChartClusterer.OPACITY);
        },

        /**
         * Получение размеров иконок кластеров.
         * @function
         * @name PieChartClusterer.getClusterIconSizes
         * @returns {Number[][]} Ширина и высота иконок.
         */
        getClusterIconSizes: function () {
            var icons = this.options.get('clusterIcons');

            if(icons) {
                var sizes = [], size, i = 0;

                while(size = icons[i] && icons[i].size) {
                    sizes[i++] = size;
                }

                return sizes;
            }

            return PieChartClusterer.SIZES;
        },

        /**
         * Получение опции 'clusterIcons' - определяет внешний вид каждой группы иконок кластера.
         * Элементов в этом массиве должно быть на 1 больше, чем элементов в массиве опции 'clusterNumbers'.
         * @function
         * @name PieChartClusterer.getClusterIcons
         * @returns {Array} Опция кластера.
         */
        getClusterIcons: function (geoObjects) {
            var sizes = this.getClusterIconSizes(),
                size, i = 0, icons = [];

            while(size = sizes[i]) {
                icons[i++] = {
                    href: this.formatClusterIconHref(size, this.getClusterIconColours(geoObjects)),
                    size: size,
                    offset: [-Math.floor(size[0] / 2), -Math.floor(size[1] / 2)]
                };
            }

            return icons;
        },

        /**
         * Возвращает количество геообъектов каждого цвета.
         * @function
         * @name PieChartClusterer.getClusterIconColors
         * @param {ymaps.GeoObject[]} geoObjects Массив геообъектов кластера.
         * @returns {Object} Соотношение имен цветов и количества геообъектов данного цвета.
         */
        getClusterIconColours: function (geoObjects) {
            var count = geoObjects.length,
                countByColour = {},
                colour, geoObject;

            while(geoObject = geoObjects[--count]) {
                colour = PieChartClusterer.COLOURS[this.getPresetColour(geoObject)];

                countByColour[colour] = countByColour[colour] + 1 || 1;
            }

            return countByColour;
        },

        /**
         * Формирует урл иконки кластера нужного размера.
         * @see https://developers.google.com/chart/image/
         * @function
         * @name PieChartClusterer.formatClusterIconHref
         * @param {Array} size Размер иконки - ширина х высота.
         * @param {Object} colours Количество геообъектов каждого цвета.
         * @returns {String} Урл иконки кластера.
         */
        formatClusterIconHref: function (size, colours) {
            // Количество геообъектов каждого цвета.
            var values = [],
            // Цвета геообъектов.
                keys = [], key,
                i = 0;

            for(keys[i] in colours) {
                values[i] = colours[keys[i++]];
            }

            // Хэш ключей для замены в шаблоне урла.
            var model = {
                width: size[0],
                height: size[1],
                data: values.join(','),
                colours: (keys.length < 2 ? [keys[0], keys[0]] : keys).join('|'),
                opacity: PieChartClusterer.dec2hex(this.getClusterIconOpacity())
            };

            return PieChartClusterer.URL_TEMPLATE.replace(/#{(\w+)}/g, function (s, key) {
                return model[key];
            });
        },

        /**
         * Возвращает строковый идентификатор цвета иконки геообъекта из его пресета.
         * @see http://api.yandex.ru/maps/doc/jsapi/2.x/ref/reference/option.presetStorage.xml
         * @function
         * @name PieChartClusterer.getPresetColour
         * @param {ymaps.GeoObject} geoObject Геообъект АПИ.
         * @returns {String} Цвета иконки геообъекта.
         */
        getPresetColour: function (geoObject) {
            return geoObject.options.get('preset', 'twirl#blueIcon').match(/#([a-z]+)[A-Z]/)[1];
        }
    });
};

rebind_markers = function(){
    clusterer.removeAll();
    clusterer.add(points);
    // А сам кластеризатор добавим на карту.

    myMap.geoObjects.add(clusterer);
    myMap.controls.add('zoomControl', {left : '5px'});
    // Выбор типа карты
    myMap.controls.add(new ymaps.control.TypeSelector());
}

function init_map_all_object() {
    console.log("yamaps init");
    var center = [55.76954, 37.621587];
    myMap = new ymaps.Map('map', {
            center: center,
            zoom: 10,
            behaviors: ["default", "scrollZoom"]
        }),

    // Создадим макет правой части балуна кластера.
        MainContentLayout = ymaps.templateLayoutFactory.createClass('', {
            build: function () {
                // Сначала вызываем метод build родительского класса.
                MainContentLayout.superclass.build.call(this);
                // Нужно отслеживать, какой из пунктов левого меню выбран,
                // чтобы обновлять содержимое правой части.
                this.stateListener = this.getData().state.events.group()
                    .add('change', this.onStateChange, this);
                // Запоминаем текущий активный объект.
                this.activeObject = this.getData().state.get('activeObject');
                this.applyContent();
            },

            clear: function () {
                // Снимаем слушателей изменения полей.
                this.stateListener.removeAll();
                // А затем вызываем метод clear родительского класса.
                MainContentLayout.superclass.clear.call(this);
            },

            onStateChange: function () {
                // При изменении одного из полей состояния
                // проверяем, не сменился ли активный объект.
                var newActiveObject = this.getData().state.get('activeObject');
                if (newActiveObject != this.activeObject) {
                    // Если объект изменился, нужно обновить
                    // содержимое правой части.
                    this.activeObject = newActiveObject;
                    this.applyContent();
                }
            },

            applyContent: function () {
                // Чтобы было удобнее формировать текстовый шаблон,
                // создадим внутренний макет, в который будем передавать
                // модифицированный dataSet.

                var subLayout = new MainContentSubLayout({
                    // Поскольку внутренний макет будет отображать
                    // информацию какого-то геообъекта,
                    // будем передавать во входном хэше данные и опции
                    // текущего активного геообъекта.
                    options: this.options,
                    properties: this.activeObject.properties
                });

                // Прикрепляем внутренний макет к внешнему.
                subLayout.setParentElement(this.getParentElement());
            }
        }),

    // Внутрений подмакет правой части балуна кластера.
        MainContentSubLayout = ymaps.templateLayoutFactory.createClass(
            // Мы можем использовать поля properties геообъекта,
            // так как будем передавать properties в конструктор макета.
            '<h3>$[properties.name]</h3>' +
                '<div width="100">' +
                '$[properties.balloonContentHeader]<br>' +
                '$[properties.balloonContentBody]' +
                '</div>'
        ),

    // Создадим макет для элемента списка в левой части балуна.
        ItemLayout = ymaps.templateLayoutFactory.createClass(
            '<div class="cluster-balloon-item" [if data.isSelected]style="font-weight: bold;"[endif]>$[properties.name]</div>'
        ),

    // Создадим кластеризатор и выставим ему созданные макеты
    // через опции.
    clusterer = new ymaps.Clusterer({
            // Поскольку опции задаются для кластеров, а не для всего
            // кластеризатора, им нужно приписать префикс 'cluster'.
            clusterDisableClickZoom: true
            // Если нужно задать опции для балуна кластера, то к названию
            // опции приписываются сразу 2 префикса - 'cluster' и 'balloon'.
//            clusterBalloonMainContentLayout: MainContentLayout,
//            clusterBalloonSidebarItemLayout: ItemLayout,
            // Настроим ширину левой части балуна кластера
//            clusterBalloonSidebarWidth: 100,
            // и ширину балуна целиком.
//            clusterBalloonWidth: 300
        })

    // Добавим полученные геообъекты в кластеризатор.
    clusterer = new PieChartClusterer();

    rebind_markers();

}

