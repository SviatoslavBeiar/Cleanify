<#import "blocks/template.ftlh" as t>
<@t.template user>
    <div class="container mt-5">
        <div class="alert alert-success">
            <h4 class="alert-heading">Payment Successfully Completed!</h4>
            <p>Thank you for your order. Your cleaning request has been successfully created and paid for.</p>
            <hr>
            <p class="mb-0">You can return to the <a href="/">homepage</a> or view your <a href="/my/requests">requests</a>.</p>
        </div>
    </div>
</@t.template>
