<#import "blocks/template.ftlh" as t>
<@t.template user>
    <link rel="stylesheet" href="/static/css/my-requests.css">
    <div class="container">
        <h1>My Requests</h1>
        <hr>
        <br>

        <!-- Display Success and Error Messages -->
        <#if successMessage??>
            <div class="alert alert-success">
                ${successMessage}
            </div>
        </#if>

        <#if errorMessage??>
            <div class="alert alert-danger">
                ${errorMessage}
            </div>
        </#if>

        <#if requests?size == 0>
            <p>You have no product requests at the moment.</p>
        <#else>
            <table class="requests-table">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Product Title</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <#list requests as request>
                    <tr>
                        <td>${request.id}</td>
                        <td>${request.product.title}</td>
                        <td>${request.formattedSelectedDate}</td>
                        <td>${request.formattedSelectedTime}</td>
                        <td>
                            <#if request.status == "APPROVED">
                                <span class="status-approved">Approved</span>
                            <#elseif request.status == "PENDING">
                                <span class="status-pending">Pending</span>
                            <#elseif request.status == "REJECTED">
                                <span class="status-rejected">Rejected</span>
                            <#else>
                                ${request.status}
                            </#if>
                        </td>
                        <td>
                            <#if request.status == "PENDING">
                                <form action="/requests/cancel" method="post" class="cancel-form">
                                    <input type="hidden" name="_csrf" value="${_csrf.token}"/>
                                    <input type="hidden" name="requestId" value="${request.id}">
                                    <button type="submit" class="btn btn-warning btn-sm">Cancel</button>
                                </form>
                            <#else>
                                N/A
                            </#if>
                        </td>
                    </tr>
                </#list>
                </tbody>
            </table>
        </#if>
    </div>
</@t.template>
