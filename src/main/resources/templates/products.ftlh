<#import "blocks/template.ftlh" as t>
<@t.template user>

    <link rel="stylesheet" href="/static/css/products.css">


    <div class="container my-4">
        <div class="info-section text-center p-4">
            <h1>Perfect Cleaning Solutions</h1>
            <p class="mt-3">
                We deliver top-notch cleaning services tailored for your home or office. Efficient, reliable, and hassle-free!
            </p>
        </div>
    </div>


    <div class="container my-4">
        <h2 class="text-center mb-4">Search for Cleaning</h2>
        <form method="get" action="/" style="background: rgba(255, 255, 255, 0.8);">
            <div class="row">

                <div class="form-group col-md-8">
                    <label for="searchWord">Search for a Cleaning Company</label>
                    <input type="text" name="searchWord" <#if searchWord??>value="${searchWord}"</#if> class="form-control" id="searchWord" placeholder="Enter name">
                </div>
                <!-- Filter by City -->
                <div class="form-group col-md-4">
                    <label for="cityFilter">Filter by City</label>
                    <select id="cityFilter" name="city" class="form-control">
                        <option value="all">All Cities</option>
                        <#-- Unique City Extraction -->
                        <#assign uniqueCities = []>
                        <#list products as product>
                            <#if !(uniqueCities?seq_contains(product.city))>
                                <#assign uniqueCities = uniqueCities + [product.city]>
                            </#if>
                        </#list>
                        <#list uniqueCities as city>
                            <option value="${city}">${city}</option>
                        </#list>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Search</button>
        </form>
    </div>


    <div class="container">
        <#if products?has_content>
            <div class="row" id="productGrid">
                <#list products as product>
                    <div class="col-md-4 mb-4 product-item" data-city="${product.city}">
                        <div class="card h-100 shadow-sm" style="background: rgba(255, 255, 255, 0.6);">
                            <a href="/product/${product.id}" class="product-link">
                                <img src="/images/${product.previewImageId}" class="card-img-top" alt="${product.title}" style="height: 200px; object-fit: cover;">
                            </a>
                            <div class="card-body">
                                <h5 class="card-title text-dark">${product.title}</h5>
                                <p class="card-text text-muted">${product.city}</p>
                            </div>
                            <div class="card-footer bg-transparent border-0">
                                <a href="/product/${product.id}" class="btn btn-outline-primary btn-block">More Information</a>
                            </div>
                        </div>
                    </div>
                </#list>
            </div>
        <#else>
            <h2 class="text-center text-muted">No listings found</h2>
        </#if>
    </div>

    <!-- Service Highlights Section with Adjusted Container Width -->
    <div class="container py-5 service-highlights">
        <h2 class="text-center mb-4">Our Services</h2>
        <div class="row justify-content-center text-center">
            <div class="col-md-4">
                <img src="/images/prod/photo1.webp" class="rounded-circle mb-3" alt="Service 1" style="width: 150px; height: 150px; object-fit: cover;">
                <p class="font-weight-bold">We ensure excellent cleaning</p>
            </div>
            <div class="col-md-4">
                <img src="/images/prod/photo2.jpg" class="rounded-circle mb-3" alt="Service 2" style="width: 150px; height: 150px; object-fit: cover;">
                <p class="font-weight-bold">Friendly and professional staff</p>
            </div>
            <div class="col-md-4">
                <img src="/images/prod/photo3.jpg" class="rounded-circle mb-3" alt="Service 3" style="width: 150px; height: 150px; object-fit: cover;">
                <p class="font-weight-bold">Fast and reliable service</p>
            </div>
        </div>

        <div class="row mt-4">
            <div class="col text-center">
                <p style="max-width: 800px; margin: 0 auto;">
                    Our mission at Perfect Cleaning Solutions is to deliver quality and convenience, ensuring every corner of your home or office is spotless.
                    We bring together experienced professionals who take pride in their work, using eco-friendly products and cutting-edge techniques to achieve impeccable results.
                    Our core values revolve around integrity, responsibility, and an unwavering commitment to customer satisfaction.
                    Whether you need a one-time deep clean or regular maintenance, we tailor our services to your specific needs,
                    ensuring that every time you step into your space, you are greeted with freshness, comfort, and peace of mind.
                </p>
            </div>
        </div>
    </div>

    <!-- Subscribe to Newsletter Section -->
    <div class="container my-4">
        <h2 class="text-center mb-4">Subscribe to Our Newsletter</h2>
        <form class="newsletter-form" method="post" action="#" id="newsletter-form">
            <div class="form-row justify-content-center">
                <div class="col-md-6">
                    <input type="email" name="email" class="form-control" placeholder="Enter your email address" required>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary btn-block">Subscribe</button>
                </div>
            </div>
        </form>
        <!-- Confirmation Message -->
        <div id="newsletter-message" class="mt-3 text-center text-success" style="display: none;">
            Thank you for subscribing!
        </div>
    </div>

    <!-- Footer with Social Media Icons -->
    <footer class="text-center py-4">
        <div class="container">
            <p>Follow us on:</p>
            <a href="#" class="mx-2"><img src="/images/prod/instagram-icon.png" alt="Instagram" style="width:30px;"></a>
            <a href="#" class="mx-2"><img src="/images/prod/telegram-icon.png" alt="Telegram" style="width:30px;"></a>
            <a href="#" class="mx-2"><img src="/images/prod/facebook-icon.png" alt="Facebook" style="width:30px;"></a>
        </div>
    </footer>


    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const cityFilter = document.getElementById('cityFilter');
            const productGrid = document.getElementById('productGrid');
            const products = productGrid ? productGrid.querySelectorAll('.product-item') : [];

            if (cityFilter && products.length > 0) {
                cityFilter.addEventListener('change', function (e) {
                    e.preventDefault();

                    const selectedCity = this.value.toLowerCase();
                    let visibleCount = 0;

                    products.forEach(product => {
                        const productCity = product.getAttribute('data-city').toLowerCase();
                        if (selectedCity === 'all' || productCity === selectedCity) {
                            product.style.display = 'block';
                            visibleCount++;
                        } else {
                            product.style.display = 'none';
                        }
                    });

                    let noResults = document.querySelector('.no-results');
                    if (visibleCount === 0) {
                        if (!noResults) {
                            noResults = document.createElement('h2');
                            noResults.className = 'text-center text-muted no-results';
                            noResults.textContent = 'No listings found';
                            productGrid.parentNode.insertBefore(noResults, productGrid.nextSibling);
                        }
                    } else {
                        if (noResults) {
                            noResults.remove();
                        }
                    }
                });
            }

            // Handle Newsletter Form Submission
            const newsletterForm = document.getElementById('newsletter-form');
            const newsletterMessage = document.getElementById('newsletter-message');

            if (newsletterForm) {
                newsletterForm.addEventListener('submit', function (e) {
                    e.preventDefault(); // Prevent actual form submission

                    // Check if the form is valid
                    if (newsletterForm.checkValidity()) {
                        // Display the confirmation message
                        newsletterMessage.style.display = 'block';

                        // Optionally, reset the form
                        newsletterForm.reset();
                    } else {
                        // If form is invalid, let the browser show the validation errors
                        newsletterForm.reportValidity();
                    }
                });
            }

            const searchForm = document.querySelector('form');
            if (searchForm) {
                searchForm.addEventListener('submit', function () {
                    // Additional submit handling if needed
                });
            }

            <#if city??>
            cityFilter.value = "${city}";
            const event = new Event('change');
            cityFilter.dispatchEvent(event);
            </#if>
        });
    </script>
</@t.template>

