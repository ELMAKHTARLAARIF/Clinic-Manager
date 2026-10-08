<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<aside class="sidebar">
    <a href="${ctx}/" class="brand"><i>+</i> ClinicManager</a>
    <nav class="menu">
        <div class="menu-title">Espace patient</div>
        <a href="${ctx}/patient/dashboard"    class="${param.active == 'dashboard' ? 'active' : ''}">📊 Dashboard</a>
        <a href="${ctx}/patient/book"         class="${param.active == 'book' ? 'active' : ''}">➕ Prendre rendez-vous</a>
        <a href="${ctx}/patient/appointments" class="${param.active == 'appointments' ? 'active' : ''}">📅 Mes rendez-vous</a>
        <a href="${ctx}/patient/history"      class="${param.active == 'history' ? 'active' : ''}">📋 Historique</a>
        <a href="${ctx}/patient/profile"      class="${param.active == 'profile' ? 'active' : ''}">👤 Mon profil</a>
        <div class="menu-title">Compte</div>
        <a href="${ctx}/logout">🚪 Déconnexion</a>
    </nav>
</aside>