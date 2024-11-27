<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/requests.css">
    <!-- Include Bootstrap CSS (if not already included in your base template) -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <!-- Include Font Awesome for icons (optional) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <div class="container my-5">
        <h2 class="mb-4">User Requests List</h2>

        <!-- Flash Messages for Success and Error Notifications -->
        <#if successMessage??>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${successMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </#if>

        <#if errorMessage??>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${errorMessage}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </#if>

        <table class="table table-bordered table-hover">
            <thead class="thead-dark">
            <tr>
                <th>Delete</th> <!-- Moved Delete Column to the First Position -->
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
                <th>Completed</th>
                <th>Distance from Base</th>
                <th>Duration from Base</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <#list requests as request>
                <tr>
                    <td>
                        <!-- Delete Button Positioned to the Left -->
                        <button type="button" class="btn btn-outline-danger btn-sm" data-toggle="modal" data-target="#deleteModal-${request.id}" title="Delete Request">
                            Delete <i class="fas fa-trash-alt"></i>
                        </button>

                        <!-- Delete Confirmation Modal -->
                        <div class="modal fade" id="deleteModal-${request.id}" tabindex="-1" aria-labelledby="deleteModalLabel-${request.id}" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form action="/admin/requests/delete/${request.id}" method="post" onsubmit="return validateDeleteInput('${request.id}');">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="deleteModalLabel-${request.id}">Confirm Deletion</h5>
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                <span aria-hidden="true">&times;</span>
                                            </button>
                                        </div>
                                        <div class="modal-body">
                                            <p>To confirm the deletion of Request ID <strong>${request.id}</strong>, please type <strong>DELETE</strong> in the field below.</p>
                                            <div class="form-group">
                                                <input type="text" class="form-control" id="confirmDelete-${request.id}" name="confirmDelete" placeholder="Type DELETE to confirm" required>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                                            <button type="submit" class="btn btn-danger">Delete <i class="fas fa-trash-alt"></i></button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </td>
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
                    <td>
                        <#if request.completed>
                            <span class="badge badge-completed">Completed</span>
                        <#else>
                            <span class="badge badge-secondary">Not Completed</span>
                        </#if>
                    </td>
                    <td id="distance-${request.id}">Loading...</td>
                    <td id="duration-${request.id}">Loading...</td>
                    <td>
                        <!-- Actions (Approve, Reject, etc.) -->
                        <#if request.status == "PENDING">
                            <form action="/admin/requests/approve/${request.id}" method="post" style="display:inline;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit" class="btn btn-success btn-sm" title="Approve Request">
                                    <i class="fas fa-check"></i> Approve
                                </button>
                            </form>
                            <form action="/admin/requests/reject/${request.id}" method="post" style="display:inline;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit" class="btn btn-danger btn-sm" title="Reject Request">
                                    <i class="fas fa-times"></i> Reject
                                </button>
                            </form>
                        <#elseif request.status == "APPROVED" && !request.completed>
                            <form action="/admin/requests/complete/${request.id}" method="post" style="display:inline;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit" class="btn btn-primary btn-sm" title="Mark as Completed">
                                    <i class="fas fa-check-circle"></i> Mark as Completed
                                </button>
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
                    <span class="legend-icon" style="background-color: purple;"></span>
                    Completed Request
                </li>
                <li>
                    <span class="legend-icon" style="background-color: red;"></span>
                    Other Request
                </li>
            </ul>
        </div>

        <!-- Map -->
        <div id="map" style="width: 100%; height: 600px; margin-bottom: 50px; border: 1px solid #ddd; border-radius: 5px;"></div>
    </div>

    <!-- Additional Styles -->
    <style>
        .badge-completed {
            background-color: purple;
            color: white;
        }
        .legend-icon {
            display: inline-block;
            width: 12px;
            height: 12px;
            margin-right: 5px;
        }
    </style>

    <!-- Preparing Address Data -->
    <script type="text/javascript">
        var requestData = [
            <#list requests as request>
            {
                id: "${request.id}",
                address: "${request.address}",
                status: "${request.status}",
                formattedSelectedDate: "${request.formattedSelectedDate}",
                formattedSelectedTime: "${request.formattedSelectedTime}",
                completed: ${request.completed?c}
            }<#if request_has_next>,</#if>
            </#list>
        ];

        // Static Bases
        var staticBases = [
            {
                address: "Natolin",
                name: "Cleaning Base Natolin"
            },
            {
                address: "Wierzbno",
                name: "Cleaning Base Wierzbno"
            },
            {
                address: "LAZARZ",
                name: "Cleaning Base LAZARZ"
            }
        ];
    </script>

    <!-- Initialize Map and Distance Matrix -->
    <script type="text/javascript">
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

        // Function to validate delete input
        function validateDeleteInput(requestId) {
            var input = document.getElementById('confirmDelete-' + requestId).value;
            if (input === 'DELETE') {
                return true; // Proceed with form submission
            } else {
                alert('Please type "DELETE" to confirm the deletion.');
                return false; // Prevent form submission
            }
        }
    </script>

    <!-- Load Google Maps API -->
    <script async defer
            src="https://maps.googleapis.com/maps/api/js?key=${googleMapsApiKey}&callback=initMap">
    </script>
</@t.template>
