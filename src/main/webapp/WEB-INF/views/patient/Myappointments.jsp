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
    <link rel="stylesheet" href="${ctx}/css/patient/appointments.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/patient/sidebar.jsp"><jsp:param name="active" value="appointments"/></jsp:include>
    <div class="content">
        <header class="topbar">
            <h1>Mes rendez-vous</h1>
<%--            <div class="user"><span><c:out value="${sessionScope.currentUser.fullName}"/></span><div class="avatar">P</div></div>--%>
        </header>
        <main class="main">
            <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
            <c:if test="${not empty error}"><div class="alert alert-error"><c:out value="${error}"/></div></c:if>

            <div class="card">
                <div class="card-head">
                    <h2>Historique et rendez-vous à venir</h2>
                    <div class="tools"><a href="${ctx}/patient/book" class="btn">➕ Nouveau rendez-vous</a></div>
                </div>

                <div class="appt-tabs">
                    <button type="button" class="appt-tab" data-filter="upcoming">À venir<span class="count"></span></button>
                    <button type="button" class="appt-tab" data-filter="past">Passés<span class="count"></span></button>
                    <button type="button" class="appt-tab" data-filter="canceled">Annulés<span class="count"></span></button>
                    <button type="button" class="appt-tab" data-filter="all">Tous<span class="count"></span></button>
                </div>

                <div class="appt-list">
                    <c:forEach var="a" items="${appointments}">
                        <article class="appt" data-group="${a.group}">
                            <div class="appt-date"><b><c:out value="${a.dayNumber}"/></b><span><c:out value="${a.monthLabel}"/></span></div>

                            <div class="appt-main">
                                <h3><c:out value="${a.doctorName}"/><small><c:out value="${a.specialty}"/></small></h3>
                                <p class="appt-time">🕒 <c:out value="${a.fullDate}"/> · <c:out value="${a.startTime}"/> – <c:out value="${a.endTime}"/></p>
                                <p class="appt-meta"><span class="badge b-gray"><c:out value="${a.type}"/></span>
                                    <c:out value="${a.reason}" default="—"/></p>
                            </div>

                            <div class="appt-side">
                                <c:choose>
                                    <c:when test="${a.status == 'PLANNED'}"><span class="badge b-blue">Planifié</span></c:when>
                                    <c:when test="${a.status == 'DONE'}"><span class="badge b-green">Terminé</span></c:when>
                                    <c:otherwise><span class="badge b-red">Annulé</span></c:otherwise>
                                </c:choose>

                                <c:if test="${a.canCancel}">
                                    <button type="button" class="btn btn-sm btn-del"
                                            data-id="${a.id}"
                                            data-label="<c:out value='${a.doctorName} · ${a.fullDate} à ${a.startTime}'/>"
                                            onclick="openCancel(this)">Annuler</button>
                                </c:if>
                                <c:if test="${a.status == 'PLANNED' && a.group == 'upcoming' && !a.canCancel}">
                                    <small>Annulation impossible à moins de 12 h du rendez-vous.</small>
                                </c:if>
                            </div>
                        </article>
                    </c:forEach>

                    <c:if test="${empty appointments}">
                        <div class="empty-box">Vous n'avez encore aucun rendez-vous.<br>
                            <a href="${ctx}/patient/book" class="btn" style="margin-top:14px">Prendre un rendez-vous</a></div>
                    </c:if>

                    <div class="empty-box" id="emptyFilter" style="display:none">Aucun rendez-vous dans cette catégorie.</div>
                </div>
            </div>

            <!-- Modale de confirmation d'annulation -->
            <dialog id="cancelModal" class="modal modal-sm">
                <form method="post" action="${ctx}/patient/appointments/cancel">
                    <input type="hidden" name="id" id="cancelId">
                    <div class="modal-head"><h2>Annuler le rendez-vous</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button></div>
                    <div class="confirm-body">
                        <p>Voulez-vous vraiment annuler <b id="cancelLabel"></b> ?</p>
                        <p class="muted">Le rendez-vous restera visible dans votre historique, avec le statut « Annulé ».</p>
                    </div>
                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Retour</button>
                        <button type="submit" class="btn btn-danger">Annuler le rendez-vous</button>
                    </div>
                </form>
            </dialog>

            <script>
                var tabs = document.querySelectorAll('.appt-tab');
                var items = document.querySelectorAll('.appt');
                var cancelModal = document.getElementById('cancelModal');

                function countGroup(filter) {
                    var n = 0;
                    items.forEach(function (it) { if (filter === 'all' || it.dataset.group === filter) n++; });
                    return n;
                }

                function applyFilter(filter) {
                    var shown = 0;
                    items.forEach(function (it) {
                        var ok = filter === 'all' || it.dataset.group === filter;
                        it.style.display = ok ? '' : 'none';
                        if (ok) shown++;
                    });
                    tabs.forEach(function (t) { t.classList.toggle('active', t.dataset.filter === filter); });
                    document.getElementById('emptyFilter').style.display = (items.length && !shown) ? 'block' : 'none';
                }

                tabs.forEach(function (t) {
                    t.querySelector('.count').textContent = '(' + countGroup(t.dataset.filter) + ')';
                    t.addEventListener('click', function () { applyFilter(t.dataset.filter); });
                });

                function openCancel(btn) {
                    document.getElementById('cancelLabel').textContent = btn.dataset.label;   // textContent : pas d'injection HTML
                    document.getElementById('cancelId').value = btn.dataset.id;
                    cancelModal.showModal();
                }

                cancelModal.addEventListener('click', function (e) { if (e.target === cancelModal) cancelModal.close(); });

                applyFilter(countGroup('upcoming') ? 'upcoming' : 'all');   // à venir d'abord, sinon tout
            </script>
        </main>
    </div>
</div>
</body>
</html>