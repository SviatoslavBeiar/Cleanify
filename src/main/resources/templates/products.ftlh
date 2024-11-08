<#import "blocks/template.ftlh" as t>
<@t.template user>
    <!-- Search Form -->
    <div class="container my-4">
        <h1 class="text-center mb-4">Search for Cleaning</h1>
        <form method="get" action="/">
            <div class="row">
                <div class="form-group col-md-3">
                    <label for="searchCity">City</label>
                    <select id="searchCity" name="city" class="form-control">
                        <option value="">Choose City</option>
                        <option value="Warszawa">Warszawa</option>
                        <option value="Gdansk">Gdansk</option>
                        <option value="Poznan">Poznan</option>
                    </select>
                </div>
                <div class="form-group col-md-7">
                    <label for="searchWord">Search for a Cleaning Company</label>
                    <input type="text" name="searchWord" <#if searchWord??>value="${searchWord}"</#if> class="form-control" id="searchWord" placeholder="Enter name or description">
                </div>
                <div class="form-group col-md-2 align-self-end">
                    <button type="submit" class="btn btn-primary btn-block">Search</button>
                </div>
            </div>
        </form>
    </div>

    <!-- Product Grid -->
    <div class="container">
        <#if products?has_content>
            <div class="row">
                <#list products as product>
                    <div class="col-md-4 mb-4">
                        <div class="card h-100 shadow-sm">
                            <a href="/product/${product.id}" class="product-link">
                                <img src="/images/${product.previewImageId}" class="card-img-top" alt="${product.title}" style="height: 200px; object-fit: cover;">
                            </a>
                            <div class="card-body">
                                <h5 class="card-title">${product.title}</h5>
                                <p class="card-text">${product.price} $</p>
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
            <h2 class="text-center">No listings found</h2>
        </#if>
    </div>

    <style>
        .product-link {
            text-decoration: none;
            color: inherit;
        }

        .product-link:hover {
            text-decoration: none;
        }

        .card {
            opacity: 0.8; /* Card transparency */
            transition: opacity 0.3s, transform 0.3s;
        }

        .card:hover {
            opacity: 1; /* Full opacity on hover */
            transform: scale(1.03); /* Slight zoom on hover */
        }
    </style>
</@t.template>
