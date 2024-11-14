<#import "blocks/template.ftlh" as t>
<@t.template user>
    <!-- Page content container -->
    <div class="container my-5">
        <div class="row">
            <!-- Column with image carousel on the left -->
            <div class="col-md-6">
                <div id="productCarousel" class="carousel slide" data-ride="carousel">
                    <ol class="carousel-indicators">
                        <#list images?sequence as image>
                            <li data-target="#productCarousel" data-slide-to="${image?index}" class="${image.previewImage?then('active', '')}"></li>
                        </#list>
                    </ol>
                    <div class="carousel-inner">
                        <#list images as image>
                            <div class="carousel-item ${image.previewImage?then('active', '')}">
                                <img src="/images/${image.id}" class="d-block w-100" alt="${product.title}" style="height: 400px; object-fit: cover;">
                            </div>
                        </#list>
                    </div>
                    <a class="carousel-control-prev" href="#productCarousel" role="button" data-slide="prev">
                        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                        <span class="sr-only">Previous</span>
                    </a>
                    <a class="carousel-control-next" href="#productCarousel" role="button" data-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="sr-only">Next</span>
                    </a>
                </div>
            </div>

            <!-- Column with product and user information on the right -->
            <div class="col-md-6">
                <!-- Product description and price -->
                <div class="description-price text-container p-3 mb-4">
                    <h1>${product.title}</h1>
                    <h3 class="text-success">${product.price} $</h3>
                    <p class="text-muted">City: ${product.city}</p>
                    <p>${product.description}</p>
                </div>

                <!-- Seller contact information -->
                <div class="contact-info text-container p-3 mb-4">
                    <h5>Seller Contact Information</h5>
                    <p>Name: <a href="/user/${authorProduct.id}">${authorProduct.name}</a></p>
                    <p>Phone: <b>${authorProduct.phoneNumber}</b></p>
                    <a href="tel:${authorProduct.phoneNumber}" class="btn btn-primary">Call the Seller</a>
                </div>
            </div>
        </div>

        <!-- Row with request form and comments section below main information -->
        <div class="row mt-5">
            <!-- Column for request form -->
            <div class="col-md-12">
                <#if user.name??>
                    <div class="request-form text-container p-3 mb-4">
                        <h5>Create a Cleaning Request:</h5>
                        <!-- Display error message if present -->
                        <#if errorMessage??>
                            <div class="alert alert-danger">${errorMessage}</div>
                        </#if>
                        <form action="/product/${product.id}/request" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                            <!-- Apartment Size Selection -->
                            <div class="form-group">
                                <label for="apartmentSize">Select Apartment Size:</label>
                                <select class="form-control" name="apartmentSize" id="apartmentSize" required>
                                    <option value="">--Select Size--</option>
                                    <option value="1">1 room</option>
                                    <option value="2">2 rooms</option>
                                    <option value="3">3 rooms</option>
                                    <option value="4">4 rooms</option>
                                    <option value="5">5 rooms</option>
                                </select>
                            </div>

                            <!-- Date Selection -->
                            <div class="form-group">
                                <label for="selectedDate">Select Date:</label>
                                <input type="date" class="form-control" name="selectedDate" id="selectedDate" required>
                            </div>

                            <!-- Time Slots -->
                            <div class="form-group">
                                <label>Select Time:</label>
                                <div class="time-slots" id="timeSlots">
                                    <!-- Time slots will be dynamically loaded here -->
                                </div>
                            </div>

                            <!-- Available Teams Info -->
                            <div id="teamsInfo" style="position: absolute; bottom: 10px; right: 10px; font-weight: bold; background-color: #f8f9fa; padding: 10px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);">
                                <!-- Teams availability info will be displayed here -->
                            </div>

                            <button type="submit" id="submitButton" class="btn btn-primary">Submit Request</button>
                        </form>
                    </div>
                <#else>
                    <p>To create a request, please <a href="/login">log in</a>.</p>
                </#if>
            </div>

            <!-- Column for comments section -->
            <div class="col-md-12">
                <div class="comments-section text-container p-3">
                    <h3>Comments</h3>
                    <hr>
                    <#if product.comments?has_content>
                        <#list product.comments as comment>
                            <div class="media mb-4">
                                <img src="/static/images/avatar.png" class="mr-3 rounded-circle" alt="${comment.user.name}" width="50" height="50">
                                <div class="media-body">
                                    <h5 class="mt-0">${comment.user.name}</h5>
                                    <p class="text-muted">${comment.dateOfCreated?string("dd.MM.yyyy HH:mm")}</p>
                                    <p>${comment.text}</p>
                                </div>
                            </div>
                        </#list>
                    <#else>
                        <p>No comments yet. Be the first to comment!</p>
                    </#if>
                </div>

                <!-- Form to add a comment -->
                <#if user.name??>
                    <div class="card my-4">
                        <h5 class="card-header">Leave a Comment:</h5>
                        <div class="card-body">
                            <form action="/product/${product.id}/comment" method="post">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <div class="form-group">
                                    <textarea class="form-control" name="text" rows="3" placeholder="Enter your comment"></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary">Submit</button>
                            </form>
                        </div>
                    </div>
                <#else>
                    <p>To leave a comment, please <a href="/login">log in</a>.</p>
                </#if>
            </div>
        </div>
    </div>

    <!-- Styles for the template -->
    <style>
        /* Remove bottom margin from last comment list item */
        .media:last-child {
            margin-bottom: 0;
        }

        /* Styles for the comment form card */
        .card-header {
            background-color: #f8f9fa;
            font-weight: bold;
        }

        /* Semi-transparent container for text */
        .text-container {
            background-color: rgba(255, 255, 255, 0.8); /* White with transparency */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Light shadow for emphasis */
            border-radius: 10px; /* Rounded edges */
        }

        /* Increase padding within the container */
        .text-container p, .text-container h1, .text-container h3 {
            margin: 10px 0;
        }

        /* Style for the request form */
        .request-form h5 {
            margin-bottom: 15px;
        }

        /* Style for time slots */
        .time-slots {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .time-slot {
            position: relative;
        }

        .time-slot input[type="radio"] {
            display: none;
        }

        .time-slot label {
            display: inline-block;
            padding: 10px 15px;
            background-color: #f0f0f0;
            border: 2px solid #ccc;
            border-radius: 5px;
            cursor: pointer;
            user-select: none;
        }

        .time-slot input[type="radio"]:checked + label {
            background-color: #007bff;
            border-color: #007bff;
            color: #fff;
        }

        /* Style for booked time slots */
        .time-slot label.booked {
            background-color: #ccc;
            border-color: #ccc;
            color: #666;
            cursor: not-allowed;
        }

        .time-slot input[type="radio"]:disabled + label {
            background-color: #ccc;
            border-color: #ccc;
            color: #666;
            cursor: not-allowed;
        }

        /* Style for error message */
        .alert-danger {
            margin-top: 15px;
        }

        /* Animation for time slots */
        .fade-in {
            animation: fadeInAnimation 0.5s ease-in-out;
        }

        @keyframes fadeInAnimation {
            0% { opacity: 0; transform: translateY(-10px); }
            100% { opacity: 1; transform: translateY(0); }
        }
    </style>

    <!-- JavaScript for dynamic time slots with animation -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var selectedDateInput = document.getElementById('selectedDate');
            var apartmentSizeInput = document.getElementById('apartmentSize');
            var timeSlotsContainer = document.getElementById('timeSlots');
            var productId = ${product.id};

            function getCleaningDuration() {
                var size = apartmentSizeInput.value;
                var durationMap = {
                    '1': 1,   // 1 комната - 1 час
                    '2': 1.5, // 2 комнаты - 1.5 часа
                    '3': 2,   // 3 комнаты - 2 часа
                    '4': 2.5, // 4 комнаты - 2.5 часа
                    '5': 3    // 5 комнат - 3 часа
                };
                return durationMap[size] || 1; // по умолчанию 1 час
            }

            function loadTimeWindows() {
                var selectedDate = selectedDateInput.value;
                var apartmentSize = apartmentSizeInput.value;
                var teamsInfoContainer = document.getElementById('teamsInfo');
                teamsInfoContainer.innerHTML = ''; // Очищаем информацию о командах

                if (!selectedDate || !apartmentSize) {
                    timeSlotsContainer.innerHTML = '<p>Please select a date and apartment size to view available time slots.</p>';
                    return;
                }

                var duration = getCleaningDuration();
                fetch('/product/' + productId + '/available-time-windows?date=' + selectedDate + '&duration=' + duration)
                    .then(response => response.json())
                    .then(timeWindows => {
                        timeSlotsContainer.innerHTML = '';

                        if (timeWindows.length === 0) {
                            timeSlotsContainer.innerHTML = '<p>No available time slots for the selected date and apartment size.</p>';
                            return;
                        }

                        timeWindows.forEach(function(timeWindow) {
                            var timeSlotDiv = document.createElement('div');
                            timeSlotDiv.className = 'time-slot fade-in';

                            var input = document.createElement('input');
                            input.type = 'radio';
                            input.id = 'time_' + timeWindow.replace(/[:\-]/g, '');
                            input.name = 'selectedTimeWindow';
                            input.value = timeWindow;
                            input.required = true;

                            var label = document.createElement('label');
                            label.htmlFor = input.id;
                            label.textContent = timeWindow;

                            // Добавляем обработчик клика для загрузки количества доступных команд
                            input.addEventListener('change', function() {
                                loadAvailableTeams(timeWindow);
                            });

                            timeSlotDiv.appendChild(input);
                            timeSlotDiv.appendChild(label);
                            timeSlotsContainer.appendChild(timeSlotDiv);
                        });
                    })
                    .catch(error => {
                        console.error('Error fetching available time windows:', error);
                        timeSlotsContainer.innerHTML = '<p>Error loading time slots. Please try again later.</p>';
                    });
            }

            function loadAvailableTeams(timeWindow) {
                var selectedDate = selectedDateInput.value;

                fetch('/product/' + productId + '/available-teams?date=' + selectedDate + '&timeWindow=' + timeWindow)
                    .then(response => response.json())
                    .then(availableTeams => {
                        var teamsInfoContainer = document.getElementById('teamsInfo');
                        if (availableTeams > 0) {
                            teamsInfoContainer.innerHTML = 'Available teams: ' + availableTeams;
                        } else {
                            teamsInfoContainer.innerHTML = 'No teams available for this time slot.';
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching available teams:', error);
                    });
            }

            selectedDateInput.addEventListener('change', loadTimeWindows);
            apartmentSizeInput.addEventListener('change', loadTimeWindows);

            // Initialize time slots if date and size are already selected
            if (selectedDateInput.value && apartmentSizeInput.value) {
                loadTimeWindows();
            }
        });

        document.addEventListener('DOMContentLoaded', function() {
            var apartmentSizeInput = document.getElementById('apartmentSize');
            var submitButton = document.getElementById('submitButton');

            function updateSubmitButtonCost() {
                var size = apartmentSizeInput.value;
                var cost = 0;

                switch (size) {
                    case '1':
                        cost = 100;
                        break;
                    case '2':
                        cost = 200;
                        break;
                    case '3':
                        cost = 300;
                        break;
                    case '4':
                        cost = 400;
                        break;
                    case '5':
                        cost = 500;
                        break;
                    default:
                        cost = 0;
                }

                if (cost > 0) {
                    submitButton.textContent = 'Submit Request (' + cost + ' zł)';
                } else {
                    submitButton.textContent = 'Submit Request';
                }
            }

            apartmentSizeInput.addEventListener('change', updateSubmitButtonCost);
        });
    </script>
</@t.template>
