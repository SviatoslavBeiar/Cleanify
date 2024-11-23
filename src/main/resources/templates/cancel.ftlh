<#import "blocks/template.ftlh" as t>
<@t.template user>
    <div class="container mt-5">
        <div class="alert alert-warning">
            <h4 class="alert-heading">Payment Canceled</h4>
            <p>You have canceled the payment. Your request was not created.</p>
            <hr>
            <p class="mb-0">You can return to the <a href="/product/${productId}">service page</a> and try again.</p>
        </div>
    </div>
</@t.template>
