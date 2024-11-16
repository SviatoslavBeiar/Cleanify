<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/requests.css">

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

                            <!-- Google Map Container -->


                            <div id="map_div" style="width: 100%; height: 300px; margin-top: 20px;"></div>
                            <div class="form-group">
                                <label for="addressInput">Enter Address:</label>
                                <input type="text" class="form-control" name="address" id="addressInput" placeholder="Enter your address" required>
                            </div>

                            <button type="submit" id="submitButton" class="btn btn-primary mt-3">Submit Request</button>
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

    <!-- Передаем необходимые переменные в JavaScript -->
    <script>
        var productId = ${product.id};
        var csrfToken = '${_csrf.token}';
    </script>



    <script>
        let map;
        let marker;
        let geocoder;

        function initMap() {
            map = new google.maps.Map(document.getElementById("map_div"), {
                zoom: 8,
                center: { lat: 37.7749, lng: -122.4194 }, // Центр карты
            });
            geocoder = new google.maps.Geocoder();
            marker = new google.maps.Marker({
                map: map,
                visible: false, // Маркер скрыт по умолчанию
            });

            // Получаем элементы ввода и кнопки
            const addressInput = document.getElementById("addressInput");
            const submitButton = document.getElementById("submitButton");

            // Событие на нажатие Enter в поле ввода адреса
            addressInput.addEventListener("keydown", (event) => {
                if (event.key === "Enter") {
                    event.preventDefault(); // Предотвращаем стандартное поведение Enter
                    const address = addressInput.value;
                    if (address) {
                        geocodeAddress(address); // Устанавливаем маркер
                    }
                }
            });

            // Событие нажатия кнопки Submit
            submitButton.addEventListener("click", (event) => {
                // Форма отправляется, данные обрабатываются на сервере
            });
        }

        // Функция геокодинга и установки маркера
        function geocodeAddress(address) {
            geocoder.geocode({ address: address }, (results, status) => {
                if (status === "OK") {
                    const location = results[0].geometry.location;
                    map.setCenter(location); // Центрируем карту
                    marker.setPosition(location); // Устанавливаем маркер
                    marker.setVisible(true); // Делаем маркер видимым
                } else {
                    alert("Geocode was not successful for the following reason: " + status);
                }
            });
        }

        // Инициализация карты
        window.initMap = initMap;
    </script>

    <!-- Подключение Google Maps API -->
    <script async
            src="https://maps.googleapis.com/maps/api/js?key=AIzaSyC4SgRYYdtLVAyj3KgXYXa8utF0IYUa0hU&callback=initMap">
    </script>




    <!-- Подключение вашего внешнего JavaScript-файла -->
    <script src="/static/js/AJAXreq.js"></script>

</@t.template>
