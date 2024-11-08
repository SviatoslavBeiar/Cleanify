<#import "blocks/template.ftlh" as t>
<@t.template user>
    <div class="container my-5">
        <h2 class="mb-4">User Requests List</h2>
        <table class="table table-bordered table-hover">
            <thead class="thead-dark">
            <tr>
                <th>Request ID</th>
                <th>User ID</th>
                <th>User Email</th>
                <th>Product ID</th>
                <th>Product Name</th>
                <th>Selected Date</th>
                <th>Selected time</th>
                <th>Request Creation Date</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <#list requests as request>
                <tr>
                    <td>${request.id}</td>
                    <td>${request.user.id}</td>
                    <td>${request.user.email}</td>
                    <td>${request.product.id}</td>
                    <td>${request.product.title}</td>
                    <td>${request.formattedSelectedDate}</td>
                    <td>${request.formattedSelectedTime}</td>
                    <td>${request.formattedDateOfCreated}</td>
                    <td>
                        <#if request.status == "PENDING">
                            <span class="badge badge-warning">Pending</span>
                        <#elseif request.status == "APPROVED">
                            <span class="badge badge-success">Approved</span>
                        <#elseif request.status == "REJECTED">
                            <span class="badge badge-danger">Rejected</span>
                        </#if>
                    </td>
                    <td>
                        <#if request.status == "PENDING">
                            <form action="/admin/requests/approve/${request.id}" method="post" style="display:inline;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit" class="btn btn-success btn-sm">Approve</button>
                            </form>
                            <form action="/admin/requests/reject/${request.id}" method="post" style="display:inline;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit" class="btn btn-danger btn-sm">Reject</button>
                            </form>
                        <#else>
                            <span class="text-muted">No actions available</span>
                        </#if>
                    </td>
                </tr>
            </#list>
            </tbody>
        </table>
    </div>

    <!-- Additional styles for improved appearance -->
    <style>
        /* Increase header size */
        h2 {
            font-size: 2rem;
            font-weight: bold;
        }

        /* Vertically align text in cells */
        td, th {
            vertical-align: middle !important;
        }

        /* Center content in ID columns */
        td:nth-child(1), td:nth-child(2), td:nth-child(4) {
            text-align: center;
        }

        /* Limit width of action column */
        td:last-child {
            white-space: nowrap;
            width: 150px;
        }

        /* Action button styles */
        .btn-sm {
            margin-right: 5px;
        }

        /* Row color alternation */
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        /* Status badge styles */
        .badge-warning {
            background-color: #ffc107;
            color: #212529;
        }

        .badge-success {
            background-color: #28a745;
        }

        .badge-danger {
            background-color: #dc3545;
        }
    </style>
</@t.template>
