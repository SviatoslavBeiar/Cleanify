<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/registration.css">
    <div class="registration-container">
        <h1>Registration</h1>
        <form action="/registration" method="post">
            <div class="form-group">
                <label for="name">Username</label>
                <div class="input-wrapper">
                    <span class="icon">👤</span>
                    <input type="text" class="form-control" id="name" name="name" required placeholder="Enter your username">
                </div>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <div class="input-wrapper">
                    <span class="icon">📧</span>
                    <input type="email" class="form-control" id="email" name="email" required placeholder="Enter your email">
                </div>
            </div>
            <div class="form-group">
                <label for="phoneNumber">Phone Number</label>
                <div class="input-wrapper">
                    <span class="icon">📱</span>
                    <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" required placeholder="Enter your phone number">
                </div>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrapper">
                    <span class="icon">🔒</span>
                    <input type="password" class="form-control" id="password" name="password" required placeholder="Enter your password">
                </div>
            </div>
            <input type="hidden" name="_csrf" value="${_csrf.token}">
            <button type="submit" class="btn-dark">Register</button>
        </form>
        <div class="message-container">
            <#if errorMessage??>
                <h2 class="message error">${errorMessage}</h2>
            <#elseif successMessage??>
                <h2 class="message success">${successMessage}</h2>
            </#if>
        </div>
    </div>
</@t.template>
