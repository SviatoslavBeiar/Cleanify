<#import "blocks/template.ftlh" as t>
<@t.template user>
    <h1 style="text-align: center">My profile</h1>
    <hr>
    <br>
    <div style="text-align: center">
        <img src="/static/images/avatar.png"
             style="border:2px solid black; border-radius: 20px" height="120">
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
            <a class="btn btn-dark mb-3" style="text-align: center; width: 100%"
               href="/admin">
                administartor panel
            </a><br>
            <a class="btn btn-dark mb-3" style="text-align: center; width: 100%"
               href="/admin/requests">
                requests
            </a><br>
            <a class="btn btn-dark mb-3" style="text-align: center; width: 100%"
               href="/my/products">
                my offers
            </a>
        </#if>

        <form action="/logout" method="post">
            <input type="hidden" name="_csrf" value="${_csrf.token}"/>
            <button type="submit" style="text-align: center; width: 100%" class="btn btn-danger mb-2">
                log out
            </button>
        </form>
    </div>
</@t.template>