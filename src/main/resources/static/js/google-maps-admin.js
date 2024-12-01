var map;
var distanceService;
var geocoder;
var baseLocations = []; // To store base coordinates
var clientLocations = []; // To store client coordinates
var infoWindow = new google.maps.InfoWindow(); // Shared InfoWindow for polylines

function initMap() {
    geocoder = new google.maps.Geocoder();
    distanceService = new google.maps.DistanceMatrixService();

    // Geocode bases and store their coordinates
    geocodeBases();
}

function geocodeBases() {
    var geocodePromises = staticBases.map(function(base) {
        return new Promise(function(resolve, reject) {
            geocoder.geocode({'address': base.address}, function(results, status) {
                if (status === 'OK') {
                    var location = results[0].geometry.location;
                    base.location = location; // Add coordinates to base object
                    baseLocations.push({
                        name: base.name,
                        position: location
                    });
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
            // Initialize map after geocoding all bases
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

                // Add base markers
                baseLocations.forEach(function(base) {
                    addStaticBaseMarker(base);
                });

                // Add client markers
                geocodeClients();
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
                    request.location = location; // Add coordinates to request object
                    clientLocations.push({
                        id: request.id,
                        position: location,
                        status: request.status,
                        date: request.formattedSelectedDate,
                        time: request.formattedSelectedTime,
                        completed: request.completed
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
            // Calculate distances after geocoding all clients
            calculateDistances();
        })
        .catch(function(error) {
            console.error('Error geocoding clients: ', error);
        });
}

function addClientMarker(request) {
    // Get today's date without time
    var today = new Date();
    today.setHours(0, 0, 0, 0);

    // Parse date from request.formattedSelectedDate (format 'dd.MM.yyyy')
    var dateParts = request.formattedSelectedDate.split('.');
    if (dateParts.length !== 3) {
        console.error('Invalid date format: ' + request.formattedSelectedDate);
        return;
    }
    var day = parseInt(dateParts[0], 10);
    var month = parseInt(dateParts[1], 10) - 1; // Months in JavaScript start at 0
    var year = parseInt(dateParts[2], 10);

    if (isNaN(day) || isNaN(month) || isNaN(year)) {
        console.error('Invalid date values: ' + request.formattedSelectedDate);
        return;
    }

    var requestDate = new Date(year, month, day);
    requestDate.setHours(0, 0, 0, 0);

    // Compare dates
    var isToday = today.getTime() === requestDate.getTime();

    // Set marker color
    var markerColor;
    if (request.completed) {
        markerColor = "http://maps.google.com/mapfiles/ms/icons/purple-dot.png";
    } else if (request.status === "APPROVED" && isToday) {
        markerColor = "http://maps.google.com/mapfiles/ms/icons/yellow-dot.png";
    } else if (request.status === "APPROVED" && !isToday) {
        markerColor = "http://maps.google.com/mapfiles/ms/icons/green-dot.png";
    } else {
        markerColor = "http://maps.google.com/mapfiles/ms/icons/red-dot.png";
    }

    // Create marker
    var marker = new google.maps.Marker({
        map: map,
        position: request.location,
        icon: markerColor,
        title: request.id + '. ' + request.address
    });

    // Info window
    var infowindow = new google.maps.InfoWindow({
        content: '<strong>' + request.id + '. ' + request.address + '</strong><br>' +
            'Status: ' + request.status + '<br>' +
            'Date: ' + request.formattedSelectedDate + '<br>' +
            'Time: ' + request.formattedSelectedTime +
            (request.completed ? '<br>Completed: Yes' : '')
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

            // Object to store minimum distance and time for each client
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

                    // Initialize object if not exists
                    if (!minDistances[requestId]) {
                        minDistances[requestId] = {
                            distanceText: distanceText,
                            distanceValue: distanceValue,
                            durationText: durationText,
                            durationValue: durationValue,
                            originIndex: i
                        };
                    } else {
                        // Update if current element has smaller distance
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

            // Update table with minimum distances and times
            for (var requestId in minDistances) {
                if (minDistances.hasOwnProperty(requestId)) {
                    var distanceCell = document.getElementById('distance-' + requestId);
                    var durationCell = document.getElementById('duration-' + requestId);

                    if (distanceCell && durationCell) {
                        distanceCell.innerText = minDistances[requestId].distanceText;
                        durationCell.innerText = minDistances[requestId].durationText;
                    }

                    // Draw polyline from selected base to client with info on hover
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

    // Add events to display InfoWindow on hover
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
