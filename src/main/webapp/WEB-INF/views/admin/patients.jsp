<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Patients - ClinicManager</title>
    <link rel="stylesheet" href="${ctx}/css/admin/admin.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp">
        <jsp:param name="active" value="patients"/>
    </jsp:include>
    <div class="content">
        <header class="topbar">
            <h1>Patients</h1>
            <div class="user"><span><c:out value="${sessionScope.user.fullName}"/></span>
                <div class="avatar">A</div>
            </div>
        </header>
        <main class="main">
            <c:if test="${not empty success or not empty param.success}">
                <div class="alert alert-success auto-dismiss">
                    <c:choose>
                        <c:when test="${not empty success}">
                            <c:out value="${success}"/>
                        </c:when>
                        <c:when test="${param.success == 'deleted'}">
                            Patient supprimé avec succès !
                        </c:when>
                        <c:when test="${param.success == 'created'}">
                            Patient ajouté avec succès !
                        </c:when>
                        <c:when test="${param.success == 'updated'}">
                            Patient modifié avec succès !
                        </c:when>
                        <c:otherwise>
                            Opération réussie !
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            <div class="card">
                <div class="card-head">
                    <h2>Liste des patients</h2>
                    <div class="tools">
                        <input type="search" placeholder="Rechercher (nom, CIN, email)">
                        <select>
                            <option>Tous les statuts</option>
                            <option>Actif</option>
                            <option>Désactivé</option>
                        </select>
                        <button type="button" class="btn" onclick="openCreate()">➕ Ajouter un patient</button>
                    </div>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>CIN</th>
                            <th>Patient</th>
                            <th>Téléphone</th>
                            <th>Naissance</th>
                            <th>Groupe</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="p" items="${patients}">
                        <tr>
                            <td><c:out value="${p.cin}" default="—"/></td>
                            <td><c:out value="${p.user.firstName}"/> <c:out value="${p.user.lastName}"/>
                                <small><c:out value="${p.user.email}"/></small></td>
                            <td><c:out value="${p.user.phone}" default="—"/></td>
                            <td><c:out value="${p.birthDate}" default="—"/></td>
                            <td><c:out value="${p.bloodGroup}" default="—"/></td>
                            <td><c:choose>
                                <c:when test="${p.user.active}"><span class="badge b-green">Actif</span></c:when>
                                <c:otherwise><span class="badge b-gray">Désactivé</span></c:otherwise>
                            </c:choose></td>
                            <td class="actions">
                                <button type="button" class="btn btn-sm" onclick="openEdit(${p.id})">✏️ Modifier</button>
                                <button type="button" class="btn btn-sm btn-del"
                                        data-id="${p.id}"
                                        data-name="<c:out value='${p.user.firstName} ${p.user.lastName}'/>"
                                        onclick="confirmDelete(this)">🗑️</button>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty patients}">
                            <tr>
                                <td colspan="7" class="empty">Aucun patient pour le moment.</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Une seule modale pour créer ET modifier -->
            <dialog id="patientModal" class="modal">
                <form id="patientForm" method="post"
                      action="${ctx}/admin/patients/${empty param.id ? 'create' : 'update'}">
                    <input type="hidden" name="id" value="<c:out value='${param.id}'/>">

                    <div class="modal-head">
                        <h2 id="patientModal-title">${empty param.id ? 'Ajouter un patient' : 'Modifier le patient'}</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-error" style="margin:16px 24px 0"><c:out value="${error}"/></div>
                    </c:if>
                    <c:if test="${not empty errors}">
                        <div class="alert alert-error auto-dismiss"><c:out value="${error}"/></div>
                    </c:if>

                    <div class="modal-body">
                        <div class="field"><label for="p-lastName">Nom</label>
                            <input type="text" id="p-lastName" name="lastName" required
                                   value="<c:out value='${param.lastName}'/>"></div>
                        <div class="field"><label for="p-firstName">Prénom</label>
                            <input type="text" id="p-firstName" name="firstName" required
                                   value="<c:out value='${param.firstName}'/>"></div>
                        <div class="field"><label for="p-email">Email</label>
                            <input type="email" id="p-email" name="email" required
                                   value="<c:out value='${param.email}'/>"></div>
                        <div class="field"><label for="p-phone">Téléphone</label>
                            <input type="tel" id="p-phone" name="phone" placeholder="+212 6 00 00 00 00"
                                   value="<c:out value='${param.phone}'/>"></div>
                        <div class="field"><label for="p-password">Mot de passe</label>
                            <input type="password" id="p-password" name="password" ${empty param.id ? 'required' : ''}>
                            <small id="p-password-hint"
                                   style="color:#6b7280">${empty param.id ? '' : 'Laisser vide pour ne pas changer.'}</small>
                        </div>
                        <div class="field"><label for="p-cin">CIN</label>
                            <input type="text" id="p-cin" name="cin" required value="<c:out value='${param.cin}'/>">
                        </div>
                        <div class="field"><label for="p-birthDate">Date de naissance</label>
                            <input type="date" id="p-birthDate" name="birthDate" required
                                   value="<c:out value='${param.birthDate}'/>"></div>
                        <div class="field"><label for="p-gender">Genre</label>
                            <select id="p-gender" name="gender" required>
                                <option value="">-- Choisir --</option>
                                <option value="MALE"   ${param.gender == 'MALE' ? 'selected' : ''}>Homme</option>
                                <option value="FEMALE" ${param.gender == 'FEMALE' ? 'selected' : ''}>Femme</option>
                            </select></div>
                        <div class="field"><label for="p-bloodGroup">Groupe sanguin</label>
                            <select id="p-bloodGroup" name="bloodGroup" required>
                                <option value="">-- Choisir --</option>
                                <option value="A_POS"  ${param.bloodGroup == 'A_POS' ? 'selected' : ''}>A+</option>
                                <option value="A_NEG"  ${param.bloodGroup == 'A_NEG' ? 'selected' : ''}>A-</option>
                                <option value="B_POS"  ${param.bloodGroup == 'B_POS' ? 'selected' : ''}>B+</option>
                                <option value="B_NEG"  ${param.bloodGroup == 'B_NEG' ? 'selected' : ''}>B-</option>
                                <option value="AB_POS" ${param.bloodGroup == 'AB_POS' ? 'selected' : ''}>AB+</option>
                                <option value="AB_NEG" ${param.bloodGroup == 'AB_NEG' ? 'selected' : ''}>AB-</option>
                                <option value="O_POS"  ${param.bloodGroup == 'O_POS' ? 'selected' : ''}>O+</option>
                                <option value="O_NEG"  ${param.bloodGroup == 'O_NEG' ? 'selected' : ''}>O-</option>
                            </select></div>
                        <div class="field full"><label for="p-address">Adresse</label>
                            <input type="text" id="p-address" name="address" value="<c:out value='${param.address}'/>">
                        </div>
                    </div>

                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler
                        </button>
                        <button type="submit" class="btn">Enregistrer</button>
                    </div>
                </form>
            </dialog>

            <!-- Modale de confirmation de suppression -->
            <dialog id="deleteModal" class="modal modal-sm">
                <form method="post" action="${ctx}/admin/patients/delete">
                    <input type="hidden" name="id" id="deleteId">
                    <div class="modal-head">
                        <h2>Supprimer le patient</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button>
                    </div>
                    <div class="confirm-body">
                        <p>Voulez-vous vraiment supprimer <b id="deleteName"></b> ?</p>
                        <p class="muted">Cette action est irréversible.</p>
                    </div>
                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler
                        </button>
                        <button type="submit" class="btn btn-danger">Supprimer</button>
                    </div>
                </form>
            </dialog>

            <script>
                var ctx = '${ctx}';
                var FIELDS = ['lastName', 'firstName', 'email', 'phone', 'cin', 'birthDate', 'gender', 'bloodGroup', 'address'];

                function el(id) {
                    var e = document.getElementById(id);
                    if (!e) console.error('Élément introuvable dans la page : #' + id);
                    return e;
                }

                // ---------- création / modification (même modale) ----------
                function setMode(editing) {
                    el('patientForm').action = ctx + '/admin/patients/' + (editing ? 'update' : 'create');
                    el('patientModal-title').textContent = editing ? 'Modifier le patient' : 'Ajouter un patient';
                    el('p-password').required = !editing;
                    el('p-password-hint').textContent = editing ? 'Laisser vide pour ne pas changer.' : '';
                }

                function openCreate() {
                    var form = el('patientForm');
                    FIELDS.forEach(function (f) {
                        form.elements[f].value = '';
                    });
                    form.elements['password'].value = '';
                    form.elements['id'].value = '';
                    setMode(false);
                    el('patientModal').showModal();
                }

                function openEdit(id) {
                    var form = el('patientForm');
                    fetch(ctx + '/admin/patients/get?id=' + id, {headers: {'Accept': 'application/json'}})
                        .then(function (r) {
                            if (!r.ok) throw new Error('Erreur serveur : ' + r.status);
                            var type = r.headers.get('content-type') || '';
                            if (type.indexOf('application/json') === -1)
                                throw new Error('Le serveur n\'a pas renvoyé du JSON : mauvaise route ou session expirée.');
                            return r.json();
                        })
                        .then(function (p) {
                            FIELDS.forEach(function (f) {
                                form.elements[f].value = p[f] || '';
                            });
                            form.elements['password'].value = '';
                            form.elements['id'].value = p.id;
                            setMode(true);
                            el('patientModal').showModal();
                        })
                        .catch(function (e) {
                            alert(e.message);
                        });
                }

                // ---------- suppression (modale de confirmation) ----------
                function confirmDelete(btn) {
                    el('deleteName').textContent = btn.dataset.name;
                    el('deleteId').value = btn.dataset.id;
                    // 7ttina id patient f heddin input bach nsiftoh f req
                    el('deleteModal').showModal();
                }

                // ---------- clic sur le fond = fermer ----------
                ['patientModal', 'deleteModal'].forEach(function (id) {
                    var d = document.getElementById(id);
                    if (d) d.addEventListener('click', function (e) {
                        if (e.target === d) d.close();
                    });
                });

                document.addEventListener("DOMContentLoaded", function () {
                    var alerts = document.querySelectorAll('.auto-dismiss');

                    if (alerts.length > 0) {
                        setTimeout(function () {
                            alerts.forEach(function (alert) {
                                alert.style.transition = 'opacity 0.5s ease';
                                alert.style.opacity = '0';
                                setTimeout(function () {
                                    alert.remove();
                                }, 500);
                            });
                        }, 4000);

                        if (window.history.replaceState) {
                            var cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                            window.history.replaceState(null, '', cleanUrl);
                        }
                    }
                });
                // ---------- rouvrir la modale après une erreur serveur ----------
                <c:if test="${openModal}">el('patientModal').showModal();
                </c:if>
            </script>
        </main>
    </div>
</div>
</body>
</html>