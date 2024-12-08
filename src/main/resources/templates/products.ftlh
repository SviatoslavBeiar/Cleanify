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
                <!-- Фільтр по місту -->
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


    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const cityFilter = document.getElementById('cityFilter');
            const productGrid = document.getElementById('productGrid');
            const products = productGrid ? productGrid.querySelectorAll('.product-item') : [];
            const existingNoResults = document.querySelector('.no-results');

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


            const searchForm = document.querySelector('form');
            if (searchForm) {
                searchForm.addEventListener('submit', function () {

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
