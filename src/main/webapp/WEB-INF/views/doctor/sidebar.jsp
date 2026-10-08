<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<aside class="sidebar">
    <a href="${ctx}/" class="brand"><i>+</i> ClinicManager</a>
    <nav class="menu">
        <div class="menu-title">Espace médecin</div>
        <a href="${ctx}/doctor/dashboard"      class="${param.active == 'dashboard' ? 'active' : ''}">📊 Dashboard</a>
        <a href="${ctx}/doctor/availabilities" class="${param.active == 'availabilities' ? 'active' : ''}">🗓️ Mes disponibilités</a>
        <a href="${ctx}/doctor/appointments"   class="${param.active == 'appointments' ? 'active' : ''}">📅 Mes rendez-vous</a>
        <div class="menu-title">Compte</div>
        <a href="${ctx}/logout">🚪 Déconnexion</a>
    </nav>
</aside>