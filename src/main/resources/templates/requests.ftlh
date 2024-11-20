<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/requests.css">
    <div class="container my-5">
        <h2 class="mb-4">User Requests List</h2>
        <table class="table table-bordered table-hover">
            <thead class="thead-dark">
            <tr>
                <th>Request ID</th>
                <th>User ID</th>
                <th>User Email</th>
                <th>Address</th>
                <th>Product ID</th>
                <th>Product Name</th>
                <th>Selected Date</th>
                <th>Selected Time</th>
                <th>End Time</th>
                <th>Request Creation Date</th>
                <th>Status</th>
                <th>Distance from Base</th>
                <th>Duration from Base</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <#list requests as request>
                <tr>
                    <td>${request.id}</td>
                    <td>${request.user.id}</td>
                    <td>${request.user.email}</td>
                    <td>${request.address}</td>
                    <td>${request.product.id}</td>
                    <td>${request.product.title}</td>
                    <td>${request.formattedSelectedDate}</td>
                    <td>${request.formattedSelectedTime}</td>
                    <td>${request.formattedEndTime}</td>
                    <td>${request.formattedDateOfCreated}</td>
                    <td>
                        <#if request.status == "PENDING">
                            <span class="badge badge-warning">Pending</span>
                        <#elseif request.status == "APPROVED">
                            <span class="badge badge-success">Approved</span>
                        <#elseif request.status == "REJECTED">
                            <span class="badge badge-danger">Rejected</span>
                        </#if>
                    </td>
                    <td id="distance-${request.id}">Loading...</td>
                    <td id="duration-${request.id}">Loading...</td>
                    <td>
                        <#if request.status == "PENDING">
                            <form action="/admin/requests/approve/${request.id}" method="post" style="display:inline;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit" class="btn btn-success btn-sm">Approve</button>
                            </form>
                            <form action="/admin/requests/reject/${request.id}" method="post" style="display:inline;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit" class="btn btn-danger btn-sm">Reject</button>
                            </form>
                        <#else>
                            <span class="text-muted">No actions available</span>
                        </#if>
                    </td>
                </tr>
            </#list>
            </tbody>
        </table>
        <!-- Map Legend -->
        <div id="map-legend" class="map-legend">
            <h5>Legend</h5>
            <ul>
                <li>
                    <span class="legend-icon" style="background-color: blue;"></span>
                    Base
                </li>
                <li>
                    <span class="legend-icon" style="background-color: yellow;"></span>
                    Today's Request
                </li>
                <li>
                    <span class="legend-icon" style="background-color: green;"></span>
                    Approved Request
                </li>
                <li>
                    <span class="legend-icon" style="background-color: red;"></span>
                    Rejected Request
                </li>
            </ul>
        </div>


        <!-- Карта -->
        <div id="map" style="width: 100%; height: 600px; margin-bottom: 50px; border: 1px solid #ddd; border-radius: 5px;"></div>
    </div>

    <!-- Дополнительные стили -->
    <style>

    </style>

    <!-- Подготовка данных адресов -->
    <script type="text/javascript">
        var requestData = [
            <#list requests as request>
            {
                id: "${request.id}",
                address: "${request.address}",
                status: "${request.status}",
                formattedSelectedDate: "${request.formattedSelectedDate}",
                formattedSelectedTime: "${request.formattedSelectedTime}"
            }<#if request_has_next>,</#if>
            </#list>
        ];

        // Статические базы
        var staticBases = [
            {
                address: "Natolin",
                name: "Cleaning Base Natolin"
            },
            {
                address: "Wierzbno",
                name: "Cleaning Base Wierzbno "
            },
            {
                address: "LAZARZ",
                name: "Cleaning Base LAZARZ "
            }
        ];
    </script>

    <!-- Инициализация карты и Distance Matrix -->
    <script type="text/javascript">
        var map;
        var distanceService;
        var geocoder;
        var baseLocations = []; // Для хранения координат баз
        var clientLocations = []; // Для хранения координат клиентов
        var infoWindow = new google.maps.InfoWindow(); // Один общий InfoWindow для полилиний

        function initMap() {
            geocoder = new google.maps.Geocoder();
            distanceService = new google.maps.DistanceMatrixService();

            // Геокодируем базы и сохраняем их координаты
            geocodeBases();
        }

        function geocodeBases() {
            var geocodePromises = staticBases.map(function(base) {
                return new Promise(function(resolve, reject) {
                    geocoder.geocode({'address': base.address}, function(results, status) {
                        if (status === 'OK') {
                            var location = results[0].geometry.location;
                            base.location = location; // Добавляем координаты в объект базы
                            baseLocations.push({
                                name: base.name,
                                position: location
                            });
                            // Маркер баз добавляется позже после инициализации карты
                            resolve();
                        } else {
                            console.error('Geocoding failed for base address: ' + base.address + ' with status: ' + status);
                            reject(status);
                        }
                    });
                });
            });

            Promise.all(geocodePromises)
                .then(function() {
                    // После геокодирования всех баз, инициализируем карту
                    if (baseLocations.length > 0) {
                        map = new google.maps.Map(document.getElementById('map'), {
                            zoom: 10,
                            center: baseLocations[0].position,
                            styles: [
                                {
                                    "featureType": "water",
                                    "stylers": [{"color": "#46bcec"}, {"visibility": "on"}]
                                },
                                {
                                    "featureType": "landscape",
                                    "stylers": [{"color": "#f2f2f2"}]
                                },
                                {
                                    "featureType": "road",
                                    "stylers": [{"saturation": -100}, {"lightness": 45}]
                                }
                            ]
                        });

                        // Добавляем маркеры баз
                        baseLocations.forEach(function(base) {
                            addStaticBaseMarker(base);
                        });

                        // Добавляем маркеры клиентов
                        geocodeClients();

                        // Вычисляем расстояния после геокодирования клиентов
                    } else {
                        console.error('No base locations available to center the map.');
                    }
                })
                .catch(function(error) {
                    console.error('Error geocoding bases: ', error);
                });
        }

        function addStaticBaseMarker(base) {
            var marker = new google.maps.Marker({
                map: map,
                position: base.position,
                icon: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png",
                title: base.name + " - " + base.address
            });

            var infowindow = new google.maps.InfoWindow({
                content: '<strong>' + base.name + '</strong><br>Address: ' + base.address
            });

            marker.addListener('click', function() {
                infowindow.open(map, marker);
            });
        }

        function geocodeClients() {
            var geocodePromises = requestData.map(function(request) {
                return new Promise(function(resolve, reject) {
                    geocoder.geocode({'address': request.address}, function(results, status) {
                        if (status === 'OK') {
                            var location = results[0].geometry.location;
                            request.location = location; // Добавляем координаты в объект запроса
                            clientLocations.push({
                                id: request.id,
                                position: location,
                                status: request.status,
                                date: request.formattedSelectedDate,
                                time: request.formattedSelectedTime
                            });
                            addClientMarker(request);
                            resolve();
                        } else {
                            console.error('Geocoding failed for client address: ' + request.address + ' with status: ' + status);
                            reject(status);
                        }
                    });
                });
            });

            Promise.all(geocodePromises)
                .then(function() {
                    // После геокодирования всех клиентов, вычисляем расстояния
                    calculateDistances();
                })
                .catch(function(error) {
                    console.error('Error geocoding clients: ', error);
                });
        }

        function addClientMarker(request) {
            // Получаем текущую дату без времени
            var today = new Date();
            today.setHours(0, 0, 0, 0);

            // Парсим дату из request.formattedSelectedDate (формат 'dd.MM.yyyy')
            var dateParts = request.formattedSelectedDate.split('.');
            if (dateParts.length !== 3) {
                console.error('Неверный формат даты: ' + request.formattedSelectedDate);
                return;
            }
            var day = parseInt(dateParts[0], 10);
            var month = parseInt(dateParts[1], 10) - 1; // Месяцы в JavaScript начинаются с 0
            var year = parseInt(dateParts[2], 10);

            if (isNaN(day) || isNaN(month) || isNaN(year)) {
                console.error('Неверные значения даты: ' + request.formattedSelectedDate);
                return;
            }

            var requestDate = new Date(year, month, day);
            requestDate.setHours(0, 0, 0, 0);

            // Сравниваем даты
            var isToday = today.getTime() === requestDate.getTime();

            // Устанавливаем цвет маркера
            var markerColor;
            if (isToday) {
                markerColor = "http://maps.google.com/mapfiles/ms/icons/yellow-dot.png";
            } else if (request.status === "APPROVED") {
                markerColor = "http://maps.google.com/mapfiles/ms/icons/green-dot.png";
            } else {
                markerColor = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";
            }

            // Создаем маркер
            var marker = new google.maps.Marker({
                map: map,
                position: request.location,
                icon: markerColor,
                title: request.id + '. ' + request.address
            });

            // Инфо окно
            var infowindow = new google.maps.InfoWindow({
                content: '<strong>' + request.id + '. ' + request.address + '</strong><br>' +
                    'Status: ' + request.status + '<br>' +
                    'Date: ' + request.formattedSelectedDate + '<br>' +
                    'Time: ' + request.formattedSelectedTime
            });

            marker.addListener('click', function() {
                infowindow.open(map, marker);
            });
        }

        function calculateDistances() {
            var origins = staticBases.map(function(base) { return base.address; });
            var destinations = requestData.map(function(request) { return request.address; });

            distanceService.getDistanceMatrix({
                origins: origins,
                destinations: destinations,
                travelMode: 'DRIVING',
                unitSystem: google.maps.UnitSystem.IMPERIAL,
                avoidHighways: false,
                avoidTolls: false,
            }, function(response, status) {
                if (status !== 'OK') {
                    console.error('Error with Distance Matrix: ' + status);
                } else {
                    var originAddresses = response.originAddresses;
                    var destinationAddresses = response.destinationAddresses;
                    var results = response.rows;

                    // Создаем объект для хранения минимального расстояния и времени для каждого клиента
                    var minDistances = {};

                    for (var i = 0; i < originAddresses.length; i++) {
                        var origin = originAddresses[i];
                        var elements = results[i].elements;

                        for (var j = 0; j < elements.length; j++) {
                            var element = elements[j];
                            var destination = destinationAddresses[j];
                            var distanceText = element.distance.text;
                            var distanceValue = element.distance.value;
                            var durationText = element.duration.text;
                            var durationValue = element.duration.value;
                            var requestId = requestData[j].id;

                            // Инициализируем объект, если еще не существует
                            if (!minDistances[requestId]) {
                                minDistances[requestId] = {
                                    distanceText: distanceText,
                                    distanceValue: distanceValue,
                                    durationText: durationText,
                                    durationValue: durationValue,
                                    originIndex: i
                                };
                            } else {
                                // Обновляем, если текущий элемент имеет меньшее расстояние
                                if (distanceValue < minDistances[requestId].distanceValue) {
                                    minDistances[requestId].distanceText = distanceText;
                                    minDistances[requestId].distanceValue = distanceValue;
                                    minDistances[requestId].durationText = durationText;
                                    minDistances[requestId].durationValue = durationValue;
                                    minDistances[requestId].originIndex = i;
                                }
                            }
                        }
                    }

                    // Обновляем таблицу с минимальными расстояниями и временем
                    for (var requestId in minDistances) {
                        if (minDistances.hasOwnProperty(requestId)) {
                            var distanceCell = document.getElementById('distance-' + requestId);
                            var durationCell = document.getElementById('duration-' + requestId);

                            if (distanceCell && durationCell) {
                                distanceCell.innerText = minDistances[requestId].distanceText;
                                durationCell.innerText = minDistances[requestId].durationText;
                            }

                            // Рисуем полилинию от выбранной базы до клиента с информацией при наведении
                            var originIndex = minDistances[requestId].originIndex;
                            var base = staticBases[originIndex];
                            var client = requestData.find(function(req) { return req.id === requestId; });

                            if (base && client && base.location && client.location) {
                                drawRoute(base.location, client.location, minDistances[requestId].distanceText, minDistances[requestId].durationText);
                            }
                        }
                    }
                }
            });
        }

        function drawRoute(origin, destination, distanceText, durationText) {
            var polyline = new google.maps.Polyline({
                path: [origin, destination],
                geodesic: true,
                strokeColor: '#FF0000',
                strokeOpacity: 0.6,
                strokeWeight: 2
            });

            polyline.setMap(map);

            // Добавляем события для отображения InfoWindow при наведении
            polyline.addListener('mouseover', function(e) {
                var infoContent = distanceText + " | " + durationText;
                infoWindow.setContent(infoContent);
                infoWindow.setPosition(e.latLng);
                infoWindow.open(map);
            });

            polyline.addListener('mouseout', function() {
                infoWindow.close();
            });
        }
    </script>

    <!-- Загрузка Google Maps API -->
    <script async defer
            src="https://maps.googleapis.com/maps/api/js?key=${googleMapsApiKey}&callback=initMap">
    </script>
</@t.template>
