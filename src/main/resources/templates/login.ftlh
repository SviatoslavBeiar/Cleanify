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
                    <input
                            type="email"
                            class="form-control <#if RequestParameters.error??>is-invalid</#if>"
                            id="email"
                            name="username"
                            required
                    >
                    <div class="invalid-feedback">
                        Incorrect email
                    </div>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input
                            type="password"
                            class="form-control <#if RequestParameters.error??>is-invalid</#if>"
                            id="password"
                            name="password"
                            required
                    >
                    <div class="invalid-feedback">
                        Incorrect password
                    </div>
                </div>
                <input type="hidden" name="_csrf" value="${_csrf.token}">
                <button type="submit" class="btn btn-dark btn-block">
                    Login
                </button>
            </form>

            <div style="text-align: center; margin-top: 20px;">
                <h3>Or login with:</h3>
                <a href="/oauth2/authorization/google" class="btn btn-danger">
                    Login with Google
                </a>
                <!-- Add more OAuth2 providers as needed -->
            </div>

            <h2 style="text-align: center; margin-top: 20px;">
                Don't have an account?
                <a href="/registration">Sign up!</a>
            </h2>
        </div>
    </div>
</@t.template>
