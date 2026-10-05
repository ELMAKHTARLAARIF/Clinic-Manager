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
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="active" value="dashboard"/></jsp:include>
    <div class="content">
        <header class="topbar">
            <h1>Dashboard</h1>
            <div class="user"><span><c:out value="${sessionScope.user.fullName}"/></span><div class="avatar">A</div></div>
        </header>
        <main class="main">
            <section class="stats">
                <div class="stat"><div class="ico">🧑‍⚕️</div><p>Patients</p><b>1 284</b><small>+8,2 %</small></div>
                <div class="stat"><div class="ico">🩺</div><p>Médecins</p><b>12</b><small>10 disponibles</small></div>
                <div class="stat"><div class="ico">📅</div><p>Rendez-vous aujourd'hui</p><b>24</b></div>
                <div class="stat"><div class="ico">🎓</div><p>Spécialités</p><b>9</b></div>
            </section>

            <section class="grid2">
                <div class="card">
                    <div class="card-head"><h2>Rendez-vous du jour</h2><a href="${ctx}/admin/appointments" class="btn btn-sm">Voir tout</a></div>
                    <div class="table-wrap"><table>
                        <thead><tr><th>Heure</th><th>Patient</th><th>Médecin</th><th>Type</th><th>Statut</th></tr></thead>
                        <tbody>
                        <tr><td>09:00</td><td>Sara Alaoui</td><td>Dr. Benali</td><td>CONSULTATION</td><td><span class="badge b-blue">PLANNED</span></td></tr>
                        <tr><td>09:35</td><td>Youssef Amrani</td><td>Dr. Idrissi</td><td>FOLLOW_UP</td><td><span class="badge b-green">DONE</span></td></tr>
                        <tr><td>10:10</td><td>Hajar Tazi</td><td>Dr. Benali</td><td>URGENT</td><td><span class="badge b-blue">PLANNED</span></td></tr>
                        <tr><td>11:00</td><td>Omar Fassi</td><td>Dr. Chraibi</td><td>CONSULTATION</td><td><span class="badge b-red">CANCELED</span></td></tr>
                        </tbody>
                    </table></div>
                </div>

                <div class="card">
                    <div class="card-head"><h2>Actions rapides</h2></div>
                    <div class="card-body quick">
                        <a href="${ctx}/admin/patients">➕ Ajouter un patient</a>
                        <a href="${ctx}/admin/doctors">➕ Ajouter un médecin</a>
                        <a href="${ctx}/admin/specialties">➕ Nouvelle spécialité</a>
                        <a href="${ctx}/admin/users">👤 Gérer les utilisateurs</a>
                    </div>
                </div>
            </section>
        </main>
    </div>
</div>
</body>
</html>