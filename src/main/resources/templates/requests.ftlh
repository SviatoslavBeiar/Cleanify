<#import "blocks/template.ftlh" as t>
<@t.template user>
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

        <!-- Карта -->
        <div id="map" style="width: 100%; height: 400px; margin-bottom: 50px; border: 1px solid #ddd; border-radius: 5px;"></div>
    </div>

    <!-- Additional styles for improved appearance -->
    <style>
        h2 {
            font-size: 2rem;
            font-weight: bold;
            color: #2c3e50;
            text-align: center;
            text-transform: uppercase;
        }

        .table {
            border: 1px solid #ddd;
            margin-bottom: 50px;
        }

        .table-hover tbody tr:hover {
            background-color: #f5f5f5;
        }

        .table thead th {
            background-color: #4CAF50;
            color: white;
            text-align: center;
        }

        td, th {
            vertical-align: middle !important;
            text-align: center;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .badge-warning {
            background-color: #ffc107;
            color: #212529;
        }
        .badge-success {
            background-color: #28a745;
            color: white;
        }
        .badge-danger {
            background-color: #dc3545;
            color: white;
        }

        .btn-sm {
            margin: 0 5px;
        }
    </style>

    <!-- Address preparation -->
    <script type="text/javascript">
        var requestData = [
            <#list requests as request>
            {
                address: "${request.address}",
                status: "${request.status}"
            }<#if request_has_next>,</#if>
            </#list>
        ];

        // Static base locations
        var staticBases = [
            {
                address: "Ursus",
                name: "Cleaning Base"
            },
            {
                address: "Gotslaw",
                name: "Cleaning Base"
            }
        ];
    </script>

    <!-- Map initialization and markers -->
    <script type="text/javascript">
        var map;

        function initMap() {
            var geocoder = new google.maps.Geocoder();

            // Center map on the first address
            geocoder.geocode({'address': requestData[0].address}, function(results, status) {
                if (status === 'OK') {
                    map = new google.maps.Map(document.getElementById('map'), {
                        zoom: 10,
                        center: results[0].geometry.location,
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

                    for (var i = 0; i < requestData.length; i++) {
                        geocodeAddress(requestData[i], geocoder, map);
                    }

                    // Add static bases
                    for (var j = 0; j < staticBases.length; j++) {
                        addStaticBase(staticBases[j], geocoder, map);
                    }
                } else {
                    console.error('Geocoding failed for the first address: ' + status);
                }
            });
        }

        function geocodeAddress(request, geocoder, map) {
            geocoder.geocode({'address': request.address}, function(results, status) {
                if (status === 'OK') {
                    var markerColor = request.status === "APPROVED"
                        ? "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
                        : "http://maps.google.com/mapfiles/ms/icons/red-dot.png";

                    var marker = new google.maps.Marker({
                        map: map,
                        position: results[0].geometry.location,
                        icon: markerColor,
                        title: request.address
                    });

                    var infowindow = new google.maps.InfoWindow({
                        content: '<strong>' + request.address + '</strong><br>Status: ' + request.status
                    });

                    marker.addListener('click', function() {
                        infowindow.open(map, marker);
                    });
                } else {
                    console.error('Geocoding failed for address: ' + status);
                }
            });
        }

        function addStaticBase(base, geocoder, map) {
            geocoder.geocode({'address': base.address}, function(results, status) {
                if (status === 'OK') {
                    var marker = new google.maps.Marker({
                        map: map,
                        position: results[0].geometry.location,
                        icon: "http://maps.google.com/mapfiles/ms/icons/black-dot.png",
                        title: base.name + " - " + base.address
                    });

                    var infowindow = new google.maps.InfoWindow({
                        content: '<strong>' + base.name + '</strong><br>Address: ' + base.address
                    });

                    marker.addListener('click', function() {
                        infowindow.open(map, marker);
                    });
                } else {
                    console.error('Geocoding failed for static base: ' + status);
                }
            });
        }
    </script>

    <!-- Load Google Maps API -->
    <script async defer
            src="https://maps.googleapis.com/maps/api/js?key=${googleMapsApiKey}&callback=initMap">
    </script>
</@t.template>
