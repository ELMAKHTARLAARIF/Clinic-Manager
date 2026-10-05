<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<aside class="sidebar">
    <a href="${ctx}/" class="brand"><i>+</i> ClinicManager</a>
    <nav class="menu">
        <div class="menu-title">Général</div>
        <a href="${ctx}/admin/dashboard" class="${param.active == 'dashboard' ? 'active' : ''}">📊 Dashboard</a>
        <div class="menu-title">Gestion</div>
        <a href="${ctx}/admin/patients"    class="${param.active == 'patients' ? 'active' : ''}">🧑‍⚕️ Patients</a>
        <a href="${ctx}/admin/doctors"     class="${param.active == 'doctors' ? 'active' : ''}">🩺 Médecins</a>
        <a href="${ctx}/admin/specialties" class="${param.active == 'specialties' ? 'active' : ''}">🎓 Spécialités</a>
        <a href="${ctx}/admin/departments" class="${param.active == 'departments' ? 'active' : ''}">🏥 Départements</a>
        <a href="${ctx}/admin/users"       class="${param.active == 'users' ? 'active' : ''}">👤 Utilisateurs</a>
        <div class="menu-title">Compte</div>
        <a href="${ctx}/logout">🚪 Déconnexion</a>
    </nav>
</aside>