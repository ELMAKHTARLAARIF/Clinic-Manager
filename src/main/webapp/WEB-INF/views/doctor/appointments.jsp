<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mes rendez-vous - ClinicManager</title>
    <link rel="stylesheet" href="${ctx}/css/admin/admin.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/doctor/sidebar.jsp"><jsp:param name="active" value="appointments"/></jsp:include>
    <div class="content">
        <header class="topbar">
            <h1>Mes rendez-vous</h1>
            <div class="user"><span><c:out value="${sessionScope.user.fullName}"/></span><div class="avatar">Dr</div></div>
        </header>
        <main class="main">
            <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
            <div class="card">
                <div class="card-head">
                    <h2>Liste des rendez-vous</h2>
                    <div class="tools">
                        <input type="date">
                        <select><option>Tous les statuts</option><option>Planifié</option><option>Terminé</option><option>Annulé</option></select>
                    </div>
                </div>
                <div class="table-wrap"><table>
                    <thead><tr><th>Date</th><th>Heure</th><th>Patient</th><th>Type</th><th>Motif</th><th>Statut</th><th>Actions</th></tr></thead>
                    <tbody>
                    <c:forEach var="a" items="${appointments}">
                        <tr>
                            <td><c:out value="${a.date}"/></td>
                            <td><c:out value="${a.startTime}"/> – <c:out value="${a.endTime}"/></td>
                            <td><c:out value="${a.patientName}"/></td>
                            <td><c:out value="${a.type}"/></td>
                            <td><c:out value="${a.reason}" default="—"/></td>
                            <td><c:choose>
                                <c:when test="${a.status == 'PLANNED'}"><span class="badge b-blue">Planifié</span></c:when>
                                <c:when test="${a.status == 'DONE'}"><span class="badge b-green">Terminé</span></c:when>
                                <c:otherwise><span class="badge b-red">Annulé</span></c:otherwise>
                            </c:choose></td>
                            <td class="actions">
                                <c:if test="${a.status == 'PLANNED'}">
                                    <form method="post" action="${ctx}/doctor/appointments/done" class="inline">
                                        <input type="hidden" name="id" value="${a.id}">
                                        <button type="submit" class="btn btn-sm">✔ Terminer</button>
                                    </form>
                                </c:if>
                                <c:if test="${a.status == 'DONE'}">
                                    <a href="${ctx}/doctor/notes/new?appointmentId=${a.id}" class="btn btn-sm">📝 Note médicale</a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty appointments}">
                        <tr><td colspan="7" class="empty">Aucun rendez-vous pour le moment.</td></tr>
                    </c:if>
                    </tbody>
                </table></div>
            </div>
        </main>
    </div>
</div>
</body>
</html>