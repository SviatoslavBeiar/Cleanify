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

    <!-- Function to validate delete input -->
    <script type="text/javascript">
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

    <!-- Include the Google Maps JavaScript file -->
    <script src="/static/js/google-maps-admin.js"></script>

    <!-- Load Google Maps API -->
    <script async defer
            src="https://maps.googleapis.com/maps/api/js?key=${googleMapsApiKey}&callback=initMap">
    </script>
</@t.template>