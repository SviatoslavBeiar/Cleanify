<#import "blocks/template.ftlh" as t>
<@t.template user!>
    <link rel="stylesheet" href="/static/css/verify-result.css">

    <h1>Email Verification</h1>
    <hr>
    <p>${message}</p>
</@t.template>
