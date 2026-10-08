<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Dashboard - ClinicManager</title>
  <link rel="stylesheet" href="${ctx}/css/admin/admin.css">
</head>
<body>
<div class="layout">
  <jsp:include page="/WEB-INF/views/doctor/sidebar.jsp"><jsp:param name="active" value="dashboard"/></jsp:include>
  <div class="content">
    <header class="topbar">
      <h1>Dashboard</h1>
      <div class="user"><span><c:out value="${sessionScope.user.fullName}"/></span><div class="avatar">Dr</div></div>
    </header>
    <main class="main">
      <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
      <section class="stats">
        <div class="stat"><div class="ico">📅</div><p>Rendez-vous aujourd'hui</p><b><c:out value="${todayCount}" default="0"/></b></div>
        <div class="stat"><div class="ico">🗓️</div><p>À venir (7 jours)</p><b><c:out value="${upcomingCount}" default="0"/></b></div>
        <div class="stat"><div class="ico">✅</div><p>Consultations terminées</p><b><c:out value="${doneCount}" default="0"/></b></div>
        <div class="stat"><div class="ico">🕒</div><p>Créneaux de disponibilité</p><b><c:out value="${availabilityCount}" default="0"/></b></div>
      </section>

      <section class="grid2">
        <div class="card">
          <div class="card-head"><h2>Rendez-vous du jour</h2><a href="${ctx}/doctor/appointments" class="btn btn-sm">Voir tout</a></div>
          <div class="table-wrap"><table>
            <thead><tr><th>Heure</th><th>Patient</th><th>Type</th><th>Statut</th></tr></thead>
            <tbody>
            <c:forEach var="a" items="${todayAppointments}">
              <tr>
                <td><c:out value="${a.startTime}"/> – <c:out value="${a.endTime}"/></td>
                <td><c:out value="${a.patientName}"/></td>
                <td><c:out value="${a.type}"/></td>
                <td><c:choose>
                  <c:when test="${a.status == 'PLANNED'}"><span class="badge b-blue">Planifié</span></c:when>
                  <c:when test="${a.status == 'DONE'}"><span class="badge b-green">Terminé</span></c:when>
                  <c:otherwise><span class="badge b-red">Annulé</span></c:otherwise>
                </c:choose></td>
              </tr>
            </c:forEach>
            <c:if test="${empty todayAppointments}">
              <tr><td colspan="4" class="empty">Aucun rendez-vous aujourd'hui.</td></tr>
            </c:if>
            </tbody>
          </table></div>
        </div>

        <div class="card">
          <div class="card-head"><h2>Actions rapides</h2></div>
          <div class="card-body quick">
            <a href="${ctx}/doctor/availabilities">➕ Ajouter une disponibilité</a>
            <a href="${ctx}/doctor/appointments">📅 Voir mes rendez-vous</a>
          </div>
        </div>
      </section>
    </main>
  </div>
</div>
</body>
</html>