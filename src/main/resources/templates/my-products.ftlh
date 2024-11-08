<#import "blocks/template.ftlh" as t>
<@t.template user>
    <h1 class="text-center mb-4">My Posts</h1>
    <hr>
    <a class="btn btn-primary mt-3 mb-3 w-100 text-center"
       data-toggle="collapse" href="#collapseExample" role="button"
       aria-expanded="true" aria-controls="collapseExample">
        Add Post
    </a>
    <div class="collapse mb-3" id="collapseExample">
        <form action="/product/create" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="productName">Post Title</label>
                <input type="text" required class="form-control" id="productName" name="title" placeholder="Enter title">
            </div>
            <div class="form-group">
                <label for="price">Product Price</label>
                <div class="input-group mb-3">
                    <input type="number" required class="form-control" id="price" name="price" placeholder="Enter price">
                    <div class="input-group-append">
                        <span class="input-group-text">₽</span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label for="searchCity">City</label>
                <select id="searchCity" required name="city" class="form-control">
                    <option value="">Select City</option>
                    <option value="Warszawa">Warszawa</option>
                    <option value="Poznan">Poznan</option>
                    <option value="Gdansk">Gdansk</option>
                </select>
            </div>
            <div class="form-group">
                <label for="description">Product Description</label>
                <textarea required class="form-control" id="description" name="description" placeholder="Enter description"></textarea>
            </div>
            <div class="form-group">
                <div class="custom-file">
                    <input required type="file" name="file1" id="file1" class="custom-file-input">
                    <label class="custom-file-label" for="file1">First Product Image</label>
                </div>
            </div>
            <div class="form-group">
                <div class="custom-file">
                    <input type="file" name="file2" id="file2" class="custom-file-input">
                    <label class="custom-file-label" for="file2">Second Product Image</label>
                </div>
            </div>
            <div class="form-group">
                <div class="custom-file">
                    <input type="file" name="file3" id="file3" class="custom-file-input">
                    <label class="custom-file-label" for="file3">Third Product Image</label>
                </div>
            </div>
            <input type="hidden" name="_csrf" value="${_csrf.token}"/>
            <button type="submit" class="btn btn-primary w-100">Add Post</button>
        </form>
    </div>

    <div class="card-columns">
        <#list products as product>
            <a href="/product/${product.id}" class="product-link">
                <div class="card bg-light shadow-sm my-3 product">
                    <div class="card-header d-flex justify-content-end p-2">
                        <form action="/product/delete/${product.id}" method="post">
                            <input type="hidden" name="_csrf" value="${_csrf.token}"/>
                            <button type="submit" class="btn btn-outline-danger btn-sm">
                                Delete
                            </button>
                        </form>
                    </div>
                    <img src="/images/${product.previewImageId}" class="card-img-top rounded" alt="${product.title}">
                    <div class="card-body">
                        <h5 class="card-title text-dark">${product.title}</h5>
                        <p class="card-text text-muted">${product.price} ₽</p>
                    </div>
                    <div class="card-footer bg-transparent border-top-0 text-center">
                        <small class="text-secondary">${product.city}</small>
                    </div>
                </div>
            </a>
        <#else>
            <h1 class="text-center text-muted">No Results Found</h1>
        </#list>
    </div>

    <!-- Additional Styles -->
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
