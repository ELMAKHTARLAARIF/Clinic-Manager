<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Médecins - ClinicManager</title>
    <link rel="stylesheet" href="${ctx}/css/admin/admin.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
        <jsp:param name="active" value="doctors"/>
    </jsp:include>
    <div class="content">
        <header class="topbar">
            <h1>Médecins</h1>
            <div class="user"><span><c:out value="${sessionScope.user.fullName}"/></span>
                <div class="avatar">A</div>
            </div>
        </header>
        <main class="main">
            <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
            <div class="card">
                <div class="card-head">
                    <h2>Liste des médecins</h2>
                    <div class="tools">
                        <input type="search" placeholder="Rechercher (nom, matricule)">
                        <select>
                            <option>Toutes les spécialités</option>
                            <option>Cardiologie</option>
                            <option>Dermatologie</option>
                            <option>Neurologie</option>
                        </select>
                        <button class="btn" onclick="document.getElementById('doctorModal').showModal()">➕ Ajouter un
                            médecin
                        </button>
                    </div>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Matricule</th>
                            <th>Médecin</th>
                            <th>Spécialité</th>
                            <th>Département</th>
                            <th>Téléphone</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tbody>
                        <c:forEach var="doc" items="${doctors}">
                            <tr>
                                <td><c:out value="${doc.matricule}"/></td>
                                <td>
                                    <c:out value="${doc.title}"/> <c:out value="${doc.user.firstName}"/> <c:out
                                        value="${doc.user.lastName}"/>
                                    <small><c:out value="${doc.user.email}"/></small>
                                </td>
                                <td><c:out value="${doc.specialty.name}"/></td>
                                <td><c:out value="${doc.department.name}"/></td>
                                <td><c:out value="${doc.user.phone}"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${doc.user.active}"><span
                                                class="badge b-green">Actif</span></c:when>
                                        <c:otherwise><span class="badge b-gray">Désactivé</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="actions">
                                    <button class="btn btn-sm">📅 Agenda</button>
                                    <button class="btn btn-sm">✏️</button>
                                    <button class="btn btn-sm btn-del">🗑️</button>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty doctors}">
                            <tr>
                                <td colspan="7" class="empty">Aucun médecin pour le moment.</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
                <div class="pager"><span>1-3 sur 12 médecins</span>
                    <div class="tools">
                        <button class="btn btn-sm">← Précédent</button>
                        <button class="btn btn-sm">Suivant →</button>
                    </div>
                </div>
            </div>

            <dialog id="doctorModal" class="modal">
                <form method="post" action="${ctx}/admin/doctor/create">
                    <div class="modal-head"><h2>Ajouter un médecin</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button>
                    </div>
                    <c:if test="${not empty error}">
                        <div class="alert alert-error" style="margin:16px 24px 0"><c:out value="${error}"/></div>
                    </c:if>
                    <c:if test="${not empty errors}">
                        <div class="alert alert-error" style="margin:16px 24px 0">
                            <c:forEach var="e" items="${errors}">
                                <div><c:out value="${e.value}"/></div>
                            </c:forEach>
                        </div>
                    </c:if>
                    <div class="modal-body">
                        <div class="field"><label for="doctorModal-lastName">Nom</label>
                            <input type="text" id="doctorModal-lastName" name="lastName" required></div>
                        <div class="field"><label for="doctorModal-firstName">Prénom</label>
                            <input type="text" id="doctorModal-firstName" name="firstName" required></div>
                        <div class="field"><label for="doctorModal-email">Email</label>
                            <input type="email" id="doctorModal-email" name="email" required></div>
                        <div class="field"><label for="doctorModal-phone">Téléphone</label>
                            <input type="tel" id="doctorModal-phone" name="phone" placeholder="+212 5 00 00 00 00">
                        </div>
                        <div class="field"><label for="doctorModal-password">Mot de passe</label>
                            <input type="password" id="doctorModal-password" name="password" required></div>
                        <div class="field"><label for="doctorModal-matricule">Matricule</label>
                            <input type="text" id="doctorModal-matricule" name="matricule" required
                                   placeholder="MED-004"></div>
                        <div class="field"><label for="doctorModal-title">Titre</label>
                            <input type="text" id="doctorModal-title" name="title" placeholder="Dr, Pr..."></div>
                        <div class="field">
                            <label for="doctorModal-departmentId">Département</label>
                            <select id="doctorModal-departmentId" name="departmentId" required>
                                <option value="">-- Choisir --</option>
                                <c:forEach var="d" items="${departments}">
                                    <option value="${d.id}" ${param.departmentId == d.id ? 'selected' : ''}>
                                        <c:out value="${d.name}"/>
                                    </option>
                                </c:forEach>
                            </select><c:if test="${not empty errors.departmentId}"><small class="field-error"><c:out value="${errors.departmentId}"/></small></c:if>
                        </div>

                        <div class="field full">
                            <label for="doctorModal-specialtyId">Spécialité</label>
                            <select id="doctorModal-specialtyId" name="specialtyId" required>
                                <option value="">-- Choisir --</option>
                                <c:forEach var="s" items="${specialties}">
                                    <option value="${s.id}" ${param.specialtyId == s.id ? 'selected' : ''}>
                                        <c:out value="${s.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler
                        </button>
                        <button type="submit" class="btn">register</button>
                    </div>
                </form>
            </dialog>

            <script>
                <c:if test="${openModal}">document.getElementById('doctorModal').showModal();</c:if>
                document.querySelectorAll('dialog.modal').forEach(function (d) {
                    d.addEventListener('click', function (e) {
                        if (e.target === d) d.close();
                    });   // clic sur le fond
                });

            </script>
        </main>
    </div>
</div>
</body>
</html>