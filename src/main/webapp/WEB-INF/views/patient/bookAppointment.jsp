<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Prendre rendez-vous - ClinicManager</title>
    <link rel="stylesheet" href="${ctx}/css/admin/admin.css">
    <link rel="stylesheet" href="${ctx}/css/patient/agenda.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/patient/sidebar.jsp"><jsp:param name="active" value="book"/></jsp:include>

    <div class="content">
        <header class="topbar">
            <h1>Prendre rendez-vous</h1>
            <div class="user">
                <span><c:out value="${sessionScope.user.fullName}"/></span>
                <div class="avatar">P</div>
            </div>
        </header>

        <main class="main">
            <c:if test="${not empty success}">
                <div class="alert alert-success"><c:out value="${success}"/></div>
            </c:if>
            <div class="alert alert-error" id="agendaError" style="display:none"></div>

            <!-- ===== FILTRES ===== -->
            <div class="card filters">
                <div class="field">
                    <label for="f-specialty">Spécialité</label>
                    <select id="f-specialty"></select>
                </div>
                <div class="field">
                    <label for="f-doctor">Médecin</label>
                    <select id="f-doctor"></select>
                </div>
                <div class="tabs">
                    <button type="button" class="tab" id="tab-week">Semaine d'un médecin</button>
                    <button type="button" class="tab" id="tab-day">Jour · tous les médecins</button>
                </div>
            </div>

            <!-- ===== AGENDA ===== -->
            <div class="card">
                <div class="card-head">
                    <h2 id="agendaTitle"></h2>
                    <div class="tools">
                        <button type="button" class="btn btn-sm" id="btn-prev">← Précédent</button>
                        <button type="button" class="btn btn-sm" id="btn-today">Aujourd'hui</button>
                        <button type="button" class="btn btn-sm" id="btn-next">Suivant →</button>
                    </div>
                </div>

                <div class="doctor-card" id="doctorCard"></div>

                <div class="legend">
                    <span><i class="dot free"></i>Libre (cliquez pour réserver)</span>
                    <span><i class="dot booked"></i>Occupé</span>
                    <span><i class="dot past"></i>Trop proche (moins de 2 h)</span>
                    <span><i class="dot break"></i>Pause 12:00–13:00</span>
                    <span><i class="dot closed"></i>Non disponible</span>
                </div>

                <div class="agenda-scroll"><div class="agenda" id="agenda"></div></div>
            </div>

            <!-- ===== MODALE DE RÉSERVATION ===== -->
            <dialog id="bookingModal" class="modal">
                <form id="bookingForm" method="post" action="${ctx}/patient/appointments/create">
                    <input type="hidden" name="doctorId"  value="<c:out value='${param.doctorId}'/>">
                    <input type="hidden" name="date"      value="<c:out value='${param.date}'/>">
                    <input type="hidden" name="startTime" value="<c:out value='${param.startTime}'/>">

                    <div class="modal-head">
                        <h2>Confirmer le rendez-vous</h2>
                        <button type="button" class="close" onclick="this.closest('dialog').close()">✕</button>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-error" style="margin:16px 24px 0"><c:out value="${error}"/></div>
                    </c:if>
                    <c:if test="${not empty errors}">
                        <div class="alert alert-error" style="margin:16px 24px 0">
                            <c:forEach var="e" items="${errors}"><div><c:out value="${e.value}"/></div></c:forEach>
                        </div>
                    </c:if>

                    <div class="modal-body">
                        <div class="summary" id="bookingSummary"></div>

                        <div class="field full">
                            <label for="b-type">Type de rendez-vous</label>
                            <select id="b-type" name="type" required>
                                <option value="CONSULTATION" ${empty param.type || param.type == 'CONSULTATION' ? 'selected' : ''}>Consultation</option>
                                <option value="FOLLOW_UP"    ${param.type == 'FOLLOW_UP' ? 'selected' : ''}>Suivi</option>
                                <option value="URGENT"       ${param.type == 'URGENT' ? 'selected' : ''}>Urgent</option>
                            </select>
                        </div>

                        <div class="field full">
                            <label for="b-reason">Motif</label>
                            <textarea id="b-reason" name="reason" maxlength="500" required
                                      placeholder="Décrivez brièvement la raison de votre visite"><c:out value="${param.reason}"/></textarea>
                        </div>
                    </div>

                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler</button>
                        <button type="submit" class="btn">Confirmer le rendez-vous</button>
                    </div>
                </form>
            </dialog>

            <script>

                var CTX = '${ctx}';
                var SPECIALTIES = ${empty specialtiesJson ? '[]' : specialtiesJson};
                var DOCTORS = ${empty doctorsJson ? '[]' : doctorsJson};

                // =====================================================================
                //  2. CONSTANTES ET OUTILS
                // =====================================================================
                var DAYS        = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
                var DAYS_LONG   = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];
                var MONTHS      = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
                var SLOT_MINUTES = 30;
                var MIN_NOTICE_MS = 2 * 3600 * 1000;       // réservation jusqu'à 2 h avant

                var TIMES = [];
                for (var h = 8; h < 18; h++) { TIMES.push(pad(h) + ':00', pad(h) + ':30'); }

                function $(id) { return document.getElementById(id); }
                function pad(n) { return (n < 10 ? '0' : '') + n; }
                function same(a, b) { return String(a) === String(b); }
                function esc(text) {
                    return String(text).replace(/[&<>"']/g, function (c) {
                        return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c];
                    });
                }

                function iso(d) { return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()); }
                function addDays(d, n) { var x = new Date(d); x.setDate(x.getDate() + n); return x; }
                function mondayOf(d) {
                    var dow = d.getDay();
                    return addDays(d, dow === 0 ? 1 : 1 - dow);
                }
                function addMinutes(time, minutes) {
                    var total = parseInt(time.slice(0, 2), 10) * 60 + parseInt(time.slice(3), 10) + minutes;
                    return pad(Math.floor(total / 60)) + ':' + pad(total % 60);
                }
                function formatDay(d) { return d.getDate() + ' ' + MONTHS[d.getMonth()]; }

                function findDoctor(id) { return DOCTORS.filter(function (d) { return same(d.id, id); })[0]; }
                function specialtyName(id) {
                    var s = SPECIALTIES.filter(function (x) { return same(x.id, id); })[0];
                    return s ? s.name : '';
                }
                function visibleDoctors() {
                    return DOCTORS.filter(function (d) { return !state.specialtyId || same(d.specialtyId, state.specialtyId); });
                }

                
                var today = new Date();
                today.setHours(0, 0, 0, 0);

                var state = {
                    mode: 'day',                                   // 'day' | 'week'
                    specialtyId: '',
                    doctorId: DOCTORS.length ? DOCTORS[0].id : '',
                    weekStart: mondayOf(today),
                    day: new Date(today)
                };

                var slotMap = {};                                  // "doctorId|date|time" -> "FREE" | "BOOKED"
                var lastRequest = 0;

                function slotKey(doctorId, dateIso, time) { return doctorId + '|' + dateIso + '|' + time; }

                // Affichage seulement : le serveur revérifie toujours à la réservation.
                function slotStatus(doctor, date, time) {
                    if (date.getDay() === 0) return 'CLOSED';                        // dimanche
                    if (time >= '12:00' && time < '13:00') return 'BREAK';           // pause déjeuner

                    var status = slotMap[slotKey(doctor.id, iso(date), time)];
                    if (!status) return 'CLOSED';                                    // le médecin ne travaille pas
                    if (status === 'BOOKED') return 'BOOKED';

                    var start = new Date(date.getFullYear(), date.getMonth(), date.getDate(),
                        parseInt(time.slice(0, 2), 10), parseInt(time.slice(3), 10));
                    return start < new Date(Date.now() + MIN_NOTICE_MS) ? 'PAST' : 'FREE';
                }

                // =====================================================================
                //  4. CHARGEMENT DES CRÉNEAUX
                // =====================================================================
                function slotsUrl() {
                    if (state.mode === 'week') {
                        return CTX + '/patient/agenda?doctorId=' + encodeURIComponent(state.doctorId) +
                            '&from=' + iso(state.weekStart) + '&to=' + iso(addDays(state.weekStart, 5));
                    }
                    var ids = visibleDoctors().map(function (d) { return d.id; }).join(',');
                    return CTX + '/patient/agenda?date=' + iso(state.day) + '&doctorIds=' + encodeURIComponent(ids);
                }

                function fetchSlots() {
                    return fetch(slotsUrl(), {headers: {'Accept': 'application/json'}}).then(function (r) {
                        if (!r.ok) throw new Error('Erreur serveur : ' + r.status);
                        if ((r.headers.get('content-type') || '').indexOf('application/json') === -1) {
                            throw new Error('Session expirée : reconnectez-vous.');
                        }
                        return r.json();
                    });
                }

                function showError(message) {
                    var box = $('agendaError');
                    box.textContent = message || '';
                    box.style.display = message ? 'block' : 'none';
                }

                // Point d'entrée unique : filtres -> chargement -> dessin.
                function refresh() {
                    fillFilters();
                    renderTitleAndCard();

                    if (!buildColumns().length) {                    // rien à charger
                        slotMap = {};
                        showError('');
                        renderAgenda();
                        return;
                    }

                    var myRequest = ++lastRequest;
                    fetchSlots().then(function (rows) {
                        if (myRequest !== lastRequest) return;       // réponse périmée
                        slotMap = {};
                        rows.forEach(function (r) { slotMap[slotKey(r.doctorId, r.date, r.time)] = r.status; });
                        showError('');
                        renderAgenda();
                    }).catch(function (err) {
                        if (myRequest !== lastRequest) return;
                        slotMap = {};
                        showError(err.message);
                        renderAgenda();
                    });
                }

                // =====================================================================
                //  5. AFFICHAGE
                // =====================================================================
                function fillFilters() {
                    var specialty = $('f-specialty');
                    specialty.innerHTML = '<option value="">Toutes les spécialités</option>' +
                        SPECIALTIES.map(function (s) {
                            return '<option value="' + esc(s.id) + '">' + esc(s.name) + '</option>';
                        }).join('');
                    specialty.value = state.specialtyId;

                    var doctors = visibleDoctors();
                    if (!doctors.some(function (d) { return same(d.id, state.doctorId); })) {
                        state.doctorId = doctors.length ? doctors[0].id : '';   // médecin filtré : on prend le premier
                    }

                    var doctor = $('f-doctor');
                    doctor.innerHTML = doctors.map(function (d) {
                        return '<option value="' + esc(d.id) + '">' + esc(d.name) + '</option>';
                    }).join('');
                    doctor.value = state.doctorId;
                    doctor.disabled = state.mode === 'day';
                }

                function buildColumns() {
                    if (state.mode === 'day') {
                        return visibleDoctors().map(function (doc) {
                            return {title: doc.name, sub: specialtyName(doc.specialtyId), doctor: doc, date: state.day};
                        });
                    }
                    var doctor = findDoctor(state.doctorId);
                    if (!doctor) return [];
                    var cols = [];
                    for (var i = 0; i < 6; i++) {                    // lundi -> samedi
                        var d = addDays(state.weekStart, i);
                        cols.push({title: DAYS[d.getDay()], sub: formatDay(d), doctor: doctor, date: d});
                    }
                    return cols;
                }

                function slotCell(status, col, time) {
                    switch (status) {
                        case 'FREE':
                            return '<button type="button" class="slot free" data-doctor="' + esc(col.doctor.id) +
                                '" data-date="' + iso(col.date) + '" data-time="' + time + '">' + time + '</button>';
                        case 'BOOKED': return '<span class="slot booked">Occupé</span>';
                        case 'PAST':   return '<span class="slot past">' + time + '</span>';
                        case 'BREAK':  return '<span class="slot break">Pause</span>';
                        default:       return '<span class="slot closed">·</span>';
                    }
                }

                function renderAgenda() {
                    var cols = buildColumns();
                    var grid = $('agenda');
                    grid.style.gridTemplateColumns = '64px repeat(' + Math.max(cols.length, 1) + ', minmax(110px, 1fr))';

                    var html = '<div class="a-corner"></div>';

                    cols.forEach(function (c) {
                        var classes = 'a-head' + (iso(c.date) === iso(today) ? ' today' : '');
                        var link = state.mode === 'day'
                            ? ' data-doctor="' + esc(c.doctor.id) + '" title="Voir la semaine de ce médecin"' : '';
                        html += '<div class="' + classes + '"' + link + '><b>' + esc(c.title) + '</b><small>' + esc(c.sub) + '</small></div>';
                    });
                    if (!cols.length) html += '<div class="a-head"><small>Aucun médecin pour cette spécialité</small></div>';

                    TIMES.forEach(function (time) {
                        html += '<div class="a-time">' + time + '</div>';
                        cols.forEach(function (c) {
                            html += '<div class="a-cell">' + slotCell(slotStatus(c.doctor, c.date, time), c, time) + '</div>';
                        });
                    });

                    grid.innerHTML = html;
                }

                function renderTitleAndCard() {
                    var title = $('agendaTitle');
                    var card = $('doctorCard');

                    if (state.mode === 'day') {
                        var d = state.day;
                        title.textContent = DAYS_LONG[d.getDay()] + ' ' + formatDay(d) + ' ' + d.getFullYear();
                        card.style.display = 'none';
                        return;
                    }

                    var end = addDays(state.weekStart, 5);
                    title.textContent = formatDay(state.weekStart) + ' – ' + formatDay(end) + ' ' + end.getFullYear();

                    var doc = findDoctor(state.doctorId);
                    card.style.display = doc ? 'flex' : 'none';
                    if (!doc) return;
                    card.innerHTML =
                        '<div class="avatar">' + esc(doc.name.split(' ').pop().charAt(0)) + '</div>' +
                        '<div><b>' + esc(doc.name) + '</b><small>' + esc(specialtyName(doc.specialtyId)) +
                        ' · ' + esc(doc.department || '') + '</small></div>' +
                        '<div class="rules">Rendez-vous de ' + SLOT_MINUTES + ' min · réservation jusqu\'à 2 h avant<br>' +
                        'Annulation possible jusqu\'à 12 h avant</div>';
                }

                // =====================================================================
                //  6. NAVIGATION
                // =====================================================================
                function setMode(mode) {
                    state.mode = mode;
                    $('tab-week').classList.toggle('active', mode === 'week');
                    $('tab-day').classList.toggle('active', mode === 'day');
                    refresh();
                }

                function move(step) {
                    if (state.mode === 'week') {
                        var week = addDays(state.weekStart, 7 * step);
                        if (week < mondayOf(today)) return;          // pas dans le passé
                        state.weekStart = week;
                    } else {
                        var day = addDays(state.day, step);
                        if (day < today) return;
                        state.day = day;
                    }
                    refresh();
                }

                $('btn-prev').addEventListener('click', function () { move(-1); });
                $('btn-next').addEventListener('click', function () { move(1); });
                $('btn-today').addEventListener('click', function () {
                    state.weekStart = mondayOf(today);
                    state.day = new Date(today);
                    refresh();
                });
                $('tab-week').addEventListener('click', function () { setMode('week'); });
                $('tab-day').addEventListener('click', function () { setMode('day'); });

                $('f-specialty').addEventListener('change', function (e) {
                    state.specialtyId = e.target.value;
                    refresh();
                });
                $('f-doctor').addEventListener('change', function (e) {
                    state.doctorId = e.target.value;
                    refresh();
                });

                // =====================================================================
                //  7. RÉSERVATION
                // =====================================================================
                var bookingModal = $('bookingModal');
                var bookingForm = $('bookingForm');

                function openBooking(doctorId, dateIso, time) {
                    var doc = findDoctor(doctorId);
                    var d = new Date(dateIso + 'T00:00:00');

                    bookingForm.elements['doctorId'].value = doctorId;
                    bookingForm.elements['date'].value = dateIso;
                    bookingForm.elements['startTime'].value = time;

                    $('bookingSummary').innerHTML =
                        '<b>' + esc(doc ? doc.name : 'Médecin') + '</b> · ' + esc(doc ? specialtyName(doc.specialtyId) : '') + '<br>' +
                        DAYS_LONG[d.getDay()] + ' ' + formatDay(d) + ' ' + d.getFullYear() +
                        ' · de <b>' + time + '</b> à <b>' + addMinutes(time, SLOT_MINUTES) + '</b>';

                    bookingModal.showModal();
                }

                // Un seul écouteur pour l'agenda : créneau libre OU en-tête médecin.
                $('agenda').addEventListener('click', function (e) {
                    var slot = e.target.closest('.slot.free');
                    if (slot) {
                        openBooking(slot.dataset.doctor, slot.dataset.date, slot.dataset.time);
                        return;
                    }
                    var head = e.target.closest('.a-head[data-doctor]');
                    if (head) {
                        state.doctorId = head.dataset.doctor;
                        setMode('week');
                    }
                });

                bookingModal.addEventListener('click', function (e) {
                    if (e.target === bookingModal) bookingModal.close();   // clic en dehors
                });

                // =====================================================================
                //  8. DÉMARRAGE
                // =====================================================================
                setMode(state.mode);

                // Après une erreur serveur : rouvrir la modale avec le créneau choisi.
                <c:if test="${openModal}">
                if (bookingForm.elements['doctorId'].value) {
                    openBooking(bookingForm.elements['doctorId'].value,
                        bookingForm.elements['date'].value,
                        bookingForm.elements['startTime'].value);
                }
                </c:if>
            </script>
        </main>
    </div>
</div>
</body>
</html>