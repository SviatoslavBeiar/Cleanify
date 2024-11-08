<#import "blocks/template.ftlh" as t>
<@t.template user>
    <h1 style="text-align: center">Login</h1>
    <hr>
    <form action="/login" method="post">
        <!-- Ваши существующие поля формы -->
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" class="form-control <#if RequestParameters.error??>is-invalid</#if>" id="email" name="username">
            <div id="email" class="invalid-feedback">
                Incorrect email
            </div>
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" class="form-control <#if RequestParameters.error??>is-invalid</#if>" id="password" name="password">
            <div id="password" class="invalid-feedback">
                Incorrect password
            </div>
        </div>
        <input type="hidden" name="_csrf" value="${_csrf.token}">
        <button type="submit" style="width: 100%" class="btn btn-dark">Login</button>
    </form>
    <hr>
    <h2 style="text-align: center;">Or</h2>
    <div style="text-align: center; margin-top: 20px;">
        <a href="/oauth2/authorization/google" class="btn btn-primary">Login with Google</a>
    </div>
    <hr>
    <h2>Don't have an account? <a href="/registration">Sign up!</a></h2>
</@t.template>
