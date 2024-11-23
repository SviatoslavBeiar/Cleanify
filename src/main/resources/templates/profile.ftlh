<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/profile.css">
    <div class="container">
        <h1>My Profile</h1>
        <hr>
        <br>
        <img src="/static/images/avatar.png" height="120">
        <br>
        <br>
        <h2>${user.name}</h2>
        <br>
        Email: <b>${user.email}</b>
        <br>
        Number: <b>${user.phoneNumber}</b>
        <br>
        <br>
        <#if user.isAdmin()>
            <a class="btn btn-dark mb-3" href="/admin">
                Administrator Panel
            </a><br>
            <a class="btn btn-dark mb-3" href="/admin/requests">
                Requests
            </a><br>
            <a class="btn btn-dark mb-3" href="/my/products">
                My Offers
            </a>
        </#if>
        <a class="btn btn-dark mb-3" href="/my/requests">
            My requests
        </a>
        <form action="/logout" method="post">
            <input type="hidden" name="_csrf" value="${_csrf.token}"/>
            <button type="submit" class="btn btn-danger mb-2">
                Log Out
            </button>
        </form>
    </div>
</@t.template>
