<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Spécialités - ClinicManager</title>
    <link rel="stylesheet" href="${ctx}/css/admin/admin.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"><jsp:param name="active" value="specialties"/></jsp:include>
    <div class="content">
        <header class="topbar">
            <h1>Spécialités</h1>
            <div class="user"><span><c:out value="${sessionScope.user.fullName}"/></span><div class="avatar">A</div></div>
        </header>
        <main class="main">
            <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
            <div class="card">
                <div class="card-head">
                    <h2>Liste des spécialités</h2>
                    <div class="tools">
                        <input type="search" placeholder="Rechercher une spécialité">
                        <select>
                            <option>Tous les départements</option>
                            <c:forEach var="d" items="${departments}"><option><c:out value="${d.name}"/></option></c:forEach>
                        </select>
                        <button class="btn" onclick="document.getElementById('specialtyModal').showModal()">➕ Ajouter une spécialité</button>
                    </div>
                </div>
                <div class="table-wrap"><table>
                    <thead><tr><th>Spécialité</th><th>Département</th><th>Description</th><th>Actions</th></tr></thead>
                    <tbody>
                    <c:forEach var="s" items="${specialties}">
                        <tr>
                            <td><b><c:out value="${s.name}"/></b></td>
                            <td><span class="badge b-blue"><c:out value="${s.department.name}"/></span></td>
                            <td><c:out value="${s.description}" default="—"/></td>
                            <td class="actions">
                                <button class="btn btn-sm">✏️ Modifier</button>
                                <form method="post" action="${ctx}/admin/specialties/delete" class="inline"
                                      onsubmit="return confirm('Supprimer cette spécialité ?')">
                                    <input type="hidden" name="id" value="${s.id}">
                                    <button type="submit" class="btn btn-sm btn-del">🗑️</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty specialties}">
                        <tr><td colspan="4" class="empty">Aucune spécialité pour le moment.</td></tr>
                    </c:if>
                    </tbody>
                </table></div>
            </div>

            <dialog id="specialtyModal" class="modal">
                <form method="post" action="${ctx}/admin/specialties/create">
                    <div class="modal-head"><h2>Ajouter une spécialité</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button></div>
                    <c:if test="${not empty error}">
                        <div class="alert alert-error" style="margin:16px 24px 0"><c:out value="${error}"/></div>
                    </c:if>
                    <div class="modal-body">
                        <div class="field full"><label for="sp-name">Nom</label>
                            <input type="text" id="sp-name" name="name" required maxlength="100" placeholder="Ex : Cardiologie"
                                   value="<c:out value='${param.name}'/>">
                            <c:if test="${not empty errors.name}"><small class="field-error"><c:out value="${errors.name}"/></small></c:if>
                        </div>
                        <div class="field full"><label for="sp-departmentId">Département</label>
                            <select id="sp-departmentId" name="departmentId" required>
                                <option value="">-- Choisir --</option>
                                <c:forEach var="d" items="${departments}">
                                    <option value="${d.id}" ${param.departmentId == d.id ? 'selected' : ''}><c:out value="${d.name}"/></option>
                                </c:forEach>
                            </select>
                            <c:if test="${empty departments}"><small class="field-error">Aucun département : créez-en un d'abord.</small></c:if>
                            <c:if test="${not empty errors.departmentId}"><small class="field-error"><c:out value="${errors.departmentId}"/></small></c:if>
                        </div>
                        <div class="field full"><label for="sp-description">Description</label>
                            <input type="text" id="sp-description" name="description" maxlength="500"
                                   value="<c:out value='${param.description}'/>">
                        </div>
                    </div>
                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler</button>
                        <button type="submit" class="btn">Enregistrer</button>
                    </div>
                </form>
            </dialog>

            <script>
                document.querySelectorAll('dialog.modal').forEach(function (d) {
                    d.addEventListener('click', function (e) { if (e.target === d) d.close(); });
                });
                <c:if test="${openModal}">document.getElementById('specialtyModal').showModal();</c:if>
            </script>
        </main>
    </div>
</div>
</body>
</html>