<#import "blocks/template.ftlh" as t>
<@t.template user>
    <!-- Info Section -->
    <link rel="stylesheet" href="/static/css/products.css">
    <div class="container my-4">
        <div class="info-section text-center p-4">
            <h1>Perfect Cleaning Solutions</h1>
            <p class="mt-3">
                We deliver top-notch cleaning services tailored for your home or office. Efficient, reliable, and hassle-free!
            </p>
        </div>
    </div>

    <!-- Search Form -->
    <div class="container my-4">
        <h2 class="text-center mb-4">Search for Cleaning</h2>
        <form method="get" action="/" style="background: rgba(255, 255, 255, 0.8);">
            <div class="row">
                <div class="form-group col-md-10">
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
                        <div class="card h-100 shadow-sm" style="background: rgba(255, 255, 255, 0.8);">
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
</@t.template>
