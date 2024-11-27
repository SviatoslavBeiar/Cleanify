<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/my-products.css">
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
                    <option value="Warszawa">Warsaw</option>
                    <option value="Poznan">Poznań</option>
                    <option value="Gdansk">Gdańsk</option>
                    <option value="Wrocław">Wrocław</option>
                    <option value="Łódź">Łódź</option>
                    <option value="Katowice">Katowice</option>
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

    <div class="card-grid">
        <#list products as product>
            <a href="/product/${product.id}" class="product-link">
                <div class="card">
                    <div class="card-header d-flex justify-content-between p-2">
                        <span>Status: <#if product.deleted>Deleted<#else>Active</#if></span>
                        <#if !product.deleted>
                            <form action="/product/delete/${product.id}" method="post">
                                <input type="hidden" name="_csrf" value="${_csrf.token}"/>
                                <button type="submit" class="btn btn-outline-danger btn-sm">
                                    Delete
                                </button>
                            </form>
                        <#else>
                            <form action="/product/restore/${product.id}" method="post">
                                <input type="hidden" name="_csrf" value="${_csrf.token}"/>
                                <button type="submit" class="btn btn-outline-success btn-sm">
                                    Restore
                                </button>
                            </form>
                        </#if>
                    </div>
                    <img src="/images/${product.previewImageId}" class="card-img-top" alt="${product.title}">
                    <div class="card-body">
                        <h5 class="card-title text-dark">${product.title}</h5>
                        <p class="card-text text-muted">${product.price}</p>
                    </div>
                    <div class="card-footer bg-transparent">
                        <small class="text-secondary">${product.city}</small>
                    </div>
                </div>
            </a>
        <#else>
            <h1 class="text-center text-muted">No Results Found</h1>
        </#list>
    </div>

    <script>
        document.querySelectorAll('.custom-file-input').forEach(input => {
            input.addEventListener('change', event => {
                const fileName = event.target.files[0]?.name || 'Choose file';
                const label = event.target.nextElementSibling;
                if (label) {
                    label.textContent = fileName;
                }
            });
        });
    </script>
</@t.template>
