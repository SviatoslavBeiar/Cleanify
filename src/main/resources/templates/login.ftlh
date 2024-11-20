<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/login.css">
    <div class="container">
        <div class="login-container">
            <h1 style="text-align: center;">Login</h1>
            <hr>
            <form action="/login" method="post">
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" class="form-control <#if RequestParameters.error??>is-invalid</#if>" id="email" name="username">
                    <div class="invalid-feedback">
                        Incorrect email
                    </div>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" class="form-control <#if RequestParameters.error??>is-invalid</#if>" id="password" name="password">
                    <div class="invalid-feedback">
                        Incorrect password
                    </div>
                </div>
                <input type="hidden" name="_csrf" value="${_csrf.token}">
                <button type="submit" class="btn btn-dark btn-block">Login</button>
            </form>

            <h2 style="text-align: center;">Don't have an account? <a href="/registration">Sign up!</a></h2>
        </div>
    </div>
</@t.template>
