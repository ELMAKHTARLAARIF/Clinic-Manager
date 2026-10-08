<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mes disponibilités - ClinicManager</title>
    <link rel="stylesheet" href="${ctx}/css/admin/admin.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/doctor/sidebar.jsp"><jsp:param name="active" value="availabilities"/></jsp:include>
    <div class="content">
        <header class="topbar">
            <h1>Mes disponibilités</h1>
            <%-- login stocke l'utilisateur sous la clé "currentUser" --%>
            <div class="user">
                <span><c:out value="${sessionScope.currentUser.firstName}"/> <c:out value="${sessionScope.currentUser.lastName}"/></span>
                <div class="avatar">Dr</div>
            </div>
        </header>
        <main class="main">
            
            <c:if test="${param.created == '1'}">
                <div class="alert alert-success" data-auto-dismiss>Disponibilité ajoutée avec succès.</div>
            </c:if>
            <c:if test="${param.deleted == '1'}">
                <div class="alert alert-success" data-auto-dismiss>Disponibilité supprimée avec succès.</div>
            </c:if>
            <c:if test="${param.updated == '1'}">
                <div class="alert alert-success" data-auto-dismiss>Disponibilité modifiée avec succès.</div>
            </c:if>

            <div class="card">
                <div class="card-head">
                    <h2>Mes horaires</h2>
                    <div class="tools">
                        <button type="button" class="btn" onclick="openCreate()">➕ Ajouter une disponibilité</button>
                    </div>
                </div>
                <div class="table-wrap"><table>
                    <thead><tr><th>Jour</th><th>Horaire</th><th>Période de validité</th><th>Statut</th><th>Actions</th></tr></thead>
                    <tbody>
                    <c:forEach var="v" items="${availabilities}">
                        <tr>
                            <td><b><c:out value="${v.dayLabel}"/></b></td>
                            <td><c:out value="${v.startTime}"/> → <c:out value="${v.endTime}"/></td>
                            <td><c:out value="${v.validFrom}"/> → <c:out value="${v.validTo}" default="sans fin"/></td>
                            <td><c:choose>
                                <c:when test="${v.status == 'AVAILABLE'}"><span class="badge b-green">Disponible</span></c:when>
                                <c:when test="${v.status == 'LEAVE'}"><span class="badge b-blue">Congé</span></c:when>
                                <c:otherwise><span class="badge b-gray">Absence</span></c:otherwise>
                            </c:choose></td>
                            <td class="actions">
                                <button type="button" class="btn btn-sm btn-del"
                                        data-id="${v.id}"
                                        data-label="<c:out value='${v.dayLabel} ${v.startTime} → ${v.endTime}'/>"
                                        onclick="confirmDelete(this)">🗑️</button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty availabilities}">
                        <tr><td colspan="5" class="empty">Aucune disponibilité. Ajoutez vos horaires pour recevoir des rendez-vous.</td></tr>
                    </c:if>
                    </tbody>
                </table></div>
            </div>

            <dialog id="availabilityModal" class="modal">
                <form method="post" action="${ctx}/doctor/availabilities/create">
                    <div class="modal-head"><h2>Ajouter une disponibilité</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button></div>

                    <%-- Erreur générale (disparaît après 4 secondes) --%>
                    <c:if test="${not empty error}">
                        <div class="alert alert-error" data-auto-dismiss style="margin:16px 24px 0"><c:out value="${error}"/></div>
                    </c:if>
                    <%-- Erreurs de validation par champ (restent visibles) --%>
                    <c:if test="${not empty errors}">
                        <div class="alert alert-error" style="margin:16px 24px 0">
                            <c:forEach var="e" items="${errors}"><div><c:out value="${e.value}"/></div></c:forEach>
                        </div>
                    </c:if>

                    <div class="modal-body">
                        <div class="field"><label for="a-day">Jour</label>
                            <select id="a-day" name="dayOfWeek" required>
                                <option value="">-- Choisir --</option>
                                <option value="MONDAY" ${param.dayOfWeek == 'MONDAY' ? 'selected' : ''}>Lundi</option>
                                <option value="TUESDAY" ${param.dayOfWeek == 'TUESDAY' ? 'selected' : ''}>Mardi</option>
                                <option value="WEDNESDAY" ${param.dayOfWeek == 'WEDNESDAY' ? 'selected' : ''}>Mercredi</option>
                                <option value="THURSDAY" ${param.dayOfWeek == 'THURSDAY' ? 'selected' : ''}>Jeudi</option>
                                <option value="FRIDAY" ${param.dayOfWeek == 'FRIDAY' ? 'selected' : ''}>Vendredi</option>
                                <option value="SATURDAY" ${param.dayOfWeek == 'SATURDAY' ? 'selected' : ''}>Samedi</option>
                            </select></div>
                        <div class="field"><label for="a-status">Statut</label>
                            <select id="a-status" name="status" required>
                                <option value="AVAILABLE" ${empty param.status || param.status == 'AVAILABLE' ? 'selected' : ''}>Disponible</option>
                                <option value="ABSENCE" ${param.status == 'ABSENCE' ? 'selected' : ''}>Absence</option>
                                <option value="LEAVE" ${param.status == 'LEAVE' ? 'selected' : ''}>Congé</option>
                            </select></div>
                        <div class="field"><label for="a-start">Heure de début</label>
                            <input type="time" id="a-start" name="startTime" required value="<c:out value='${param.startTime}'/>"></div>
                        <div class="field"><label for="a-end">Heure de fin</label>
                            <input type="time" id="a-end" name="endTime" required value="<c:out value='${param.endTime}'/>"></div>
                        <div class="field"><label for="a-from">Valable à partir du</label>
                            <input type="date" id="a-from" name="validFrom" required value="<c:out value='${param.validFrom}'/>"></div>
                        <div class="field"><label for="a-to">Jusqu'au (facultatif)</label>
                            <input type="date" id="a-to" name="validTo" value="<c:out value='${param.validTo}'/>"></div>
                        <div class="field full">
                            <small style="color:#6b7280">Les créneaux de 30 min sont générés automatiquement. La pause 12:00–13:00 et le dimanche sont exclus.</small>
                        </div>
                    </div>

                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler</button>
                        <button type="submit" class="btn">Enregistrer</button>
                    </div>
                </form>
            </dialog>

            <dialog id="deleteModal" class="modal modal-sm">
                <form method="post" action="${ctx}/doctor/availabilities/delete">
                    <input type="hidden" name="id" id="deleteId">
                    <div class="modal-head"><h2>Supprimer la disponibilité</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button></div>
                    <div class="confirm-body">
                        <p>Supprimer <b id="deleteLabel"></b> ?</p>
                        <p class="muted">Les rendez-vous déjà pris ne sont pas annulés.</p>
                    </div>
                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler</button>
                        <button type="submit" class="btn btn-danger">Supprimer</button>
                    </div>
                </form>
            </dialog>

            <script>
                function byId(id) {
                    var e = document.getElementById(id);
                    if (!e) console.error('Introuvable : #' + id);
                    return e;
                }

                function openCreate() { byId('availabilityModal').showModal(); }

                function confirmDelete(btn) {
                    byId('deleteLabel').textContent = btn.dataset.label;
                    byId('deleteId').value = btn.dataset.id;
                    byId('deleteModal').showModal();
                }

                // Fermer un modal en cliquant sur le fond
                ['availabilityModal', 'deleteModal'].forEach(function (id) {
                    var d = document.getElementById(id);
                    if (d) d.addEventListener('click', function (e) { if (e.target === d) d.close(); });
                });

                // Messages : disparition automatique après 4 secondes
                document.querySelectorAll('[data-auto-dismiss]').forEach(function (msg) {
                    setTimeout(function () {
                        msg.style.transition = 'opacity .4s';
                        msg.style.opacity = '0';
                        setTimeout(function () { msg.remove(); }, 400);
                    }, 4000);
                });

                // Nettoyer l'URL (?created=1 ...) pour ne pas réafficher le message au rafraîchissement
                if (window.location.search) {
                    history.replaceState(null, '', window.location.pathname);
                }

                <c:if test="${openModal}">byId('availabilityModal').showModal();</c:if>
            </script>
        </main>
    </div>
</div>
</body>
</html>