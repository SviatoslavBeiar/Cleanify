<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/product-info.css">

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
                    <p class="text-muted">City: ${product.city}</p>
                    <p>${product.description}</p>
                </div>

                <!-- Seller contact information -->
                <div class="contact-info text-container p-3 mb-4">
                    <h5>Seller Contact Information</h5>
                    <p>Name: <a>${authorProduct.name}</a></p>
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
                        <form action="/product/${product.id}/pay" method="post">
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
                            <div class="form-group mt-3">
                                <label for="addressInput">Make sure that your address is in "${product.city}"</label>
                                <label for="addressInput">Enter Address:</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" name="address" id="addressInput" placeholder="Enter your address" required>
                                    <div class="input-group-append">
                                        <button type="button" id="findAddressButton" class="btn btn-secondary">Find Address</button>
                                    </div>
                                </div>
                            </div>

                            <!-- Warning for mismatched area -->
                            <div id="cityWarning" class="alert alert-warning mt-3" style="display: none;">
                                <strong>Warning!</strong> The entered address is not within "${product.city}". Please enter an address within "${product.city}".
                            </div>

                            <button type="submit" id="submitButton" class="btn btn-primary mt-3 paypal-button" disabled>Pay with PayPal</button>
                        </form>
                        <div class="alert alert-success">
                            <strong>Testing Credit cards</strong>
                            <div>Type: <strong>Visa/Mastercard</strong></div>
                            <div>Card Number: <strong></strong></div>
                            <div>Expiry: <strong>12/29</strong></div>
                            <div>CVC Code: <strong>Any 3 digits</strong></div>
                        </div>
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
    <script>
        var productId = ${product.id};
        var csrfToken = '${_csrf.token}';
        var initialCity = "${product.city}";
        var googleMapsApiKey = "${googleMapsApiKey}";
    </script>

    <!-- Include your external JavaScript files -->
    <script src="/static/js/AJAXreq.js"></script>
    <script src="/static/js/product-map.js"></script>

    <!-- Include Google Maps API -->
    <script async
            src="https://maps.googleapis.com/maps/api/js?key=${googleMapsApiKey}&callback=initMap">
    </script>

</@t.template>
