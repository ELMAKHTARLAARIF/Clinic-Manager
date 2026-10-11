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
    <jsp:include page="/WEB-INF/views/patient/sidebar.jsp">
        <jsp:param name="active" value="book"/>
    </jsp:include>

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

                <div class="agenda-scroll">
                    <div class="agenda" id="agenda"></div>
                </div>
            </div>

            <!-- ===== MODALE DE RÉSERVATION ===== -->
            <dialog id="bookingModal" class="modal">
                <form id="bookingForm" method="post" action="${ctx}/patient/appointments/create">
                    <input type="hidden" name="doctorId" value="<c:out value='${param.doctorId}'/>">
                    <input type="hidden" name="date" value="<c:out value='${param.date}'/>">
                    <input type="hidden" name="startTime" value="<c:out value='${param.startTime}'/>">
                    <input type="hidden" name="endTime" value="<c:out value='${param.endTime}'/>">

                    <div class="modal-head">
                        <h2>Confirmer le rendez-vous</h2>
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
                        <div class="summary" id="bookingSummary"></div>

                        <div class="field full">
                            <label for="b-type">Type de rendez-vous</label>
                            <select id="b-type" name="type" required>
                                <option value="CONSULTATION" ${empty param.type || param.type == 'CONSULTATION' ? 'selected' : ''}>
                                    Consultation
                                </option>
                                <option value="FOLLOW_UP"    ${param.type == 'FOLLOW_UP' ? 'selected' : ''}>Suivi
                                </option>
                                <option value="URGENT"       ${param.type == 'URGENT' ? 'selected' : ''}>Urgent</option>
                            </select>
                        </div>

                        <div class="field full">
                            <label for="b-reason">Motif</label>
                            <textarea id="b-reason" name="reason" maxlength="500" required
                                      placeholder="Décrivez brièvement la raison de votre visite"><c:out
                                    value="${param.reason}"/></textarea>
                        </div>
                    </div>

                    <div class="modal-foot">
                        <button type="button" class="btn btn-gray" onclick="this.closest('dialog').close()">Annuler
                        </button>
                        <button type="submit" class="btn">Confirmer le rendez-vous</button>
                    </div>
                </form>
            </dialog>

            <script>

                // ============================================================
                // 1. DONNÉES VENANT DU SERVEUR
                // ============================================================

                var CTX = '${ctx}';

                var SPECIALTIES = ${empty specialtiesJson ? '[]' : specialtiesJson};
                var DOCTORS = ${empty doctorsJson ? '[]' : doctorsJson};


                // ============================================================
                // 2. CONSTANTES
                // ============================================================

                var DAYS = [
                    'Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'
                ];

                var DAYS_LONG = [
                    'dimanche',
                    'lundi',
                    'mardi',
                    'mercredi',
                    'jeudi',
                    'vendredi',
                    'samedi'
                ];

                var MONTHS = [
                    'janv.', 'févr.', 'mars', 'avr.',
                    'mai', 'juin', 'juil.', 'août',
                    'sept.', 'oct.', 'nov.', 'déc.'
                ];

                var SLOT_MINUTES = 30;

                // Un rendez-vous doit être réservé au moins 2 heures avant
                var MIN_NOTICE = 2 * 60 * 60 * 1000;


                // ============================================================
                // 3. LES HEURES DE LA JOURNÉE
                // ============================================================

                var TIMES = [];

                for (var hour = 8; hour < 18; hour++) {

                    var h = hour < 10 ? '0' + hour : hour;

                    TIMES.push(h + ':00');
                    TIMES.push(h + ':30');
                }


                // ============================================================
                // 4. PETITES FONCTIONS UTILES
                // ============================================================

                function getElement(id) {
                    return document.getElementById(id);
                }


                function addZero(number) {

                    if (number < 10) {
                        return '0' + number;
                    }

                    return number;
                }


                // Exemple :
                // Date -> 2026-10-08

                function getDateString(date) {

                    return date.getFullYear()
                        + '-'
                        + addZero(date.getMonth() + 1)
                        + '-'
                        + addZero(date.getDate());
                }


                // Ajouter des jours à une date

                function addDays(date, numberOfDays) {

                    var newDate = new Date(date);

                    newDate.setDate(
                        newDate.getDate() + numberOfDays
                    );

                    return newDate;
                }


                // Retourne le lundi de la semaine

                function getMonday(date) {

                    var day = date.getDay();

                    if (day === 0) {
                        return addDays(date, 1);
                    }

                    return addDays(date, 1 - day);
                }


                // Ajouter des minutes à une heure
                // Exemple : 10:30 + 30 = 11:00

                function addMinutes(time, minutes) {

                    var hours = parseInt(time.substring(0, 2));
                    var mins = parseInt(time.substring(3, 5));

                    var totalMinutes = hours * 60 + mins + minutes;

                    var newHours = Math.floor(totalMinutes / 60);
                    var newMinutes = totalMinutes % 60;

                    return addZero(newHours)
                        + ':'
                        + addZero(newMinutes);
                }


                // Exemple :
                // 8 octobre -> "8 oct."

                function formatDate(date) {

                    return date.getDate()
                        + ' '
                        + MONTHS[date.getMonth()];
                }


                // Trouver un médecin grâce à son ID

                function findDoctor(id) {

                    for (var i = 0; i < DOCTORS.length; i++) {

                        if (String(DOCTORS[i].id) === String(id)) {
                            return DOCTORS[i];
                        }
                    }

                    return null;
                }


                // Trouver le nom d'une spécialité

                function getSpecialtyName(id) {

                    for (var i = 0; i < SPECIALTIES.length; i++) {

                        if (String(SPECIALTIES[i].id) === String(id)) {
                            return SPECIALTIES[i].name;
                        }
                    }

                    return '';
                }


                // ============================================================
                // 5. DATE D'AUJOURD'HUI
                // ============================================================

                var today = new Date();

                today.setHours(0, 0, 0, 0);


                // ============================================================
                // 6. ÉTAT DE L'AGENDA
                // ============================================================

                var state = {

                    // "day" = journée
                    // "week" = semaine

                    mode: 'day',

                    specialtyId: '',

                    doctorId: DOCTORS.length > 0
                        ? DOCTORS[0].id
                        : '',

                    weekStart: getMonday(today),

                    day: new Date(today)
                };


                // Les créneaux reçus du serveur

                var slotMap = {};

                var requestNumber = 0;


                // ============================================================
                // 7. MÉDECINS VISIBLES
                // ============================================================

                function getVisibleDoctors() {

                    var doctors = [];

                    for (var i = 0; i < DOCTORS.length; i++) {

                        var doctor = DOCTORS[i];

                        // Pas de filtre de spécialité
                        if (state.specialtyId === '') {
                            doctors.push(doctor);
                        }

                        // Ou le médecin appartient à la spécialité choisie
                        else if (
                            String(doctor.specialtyId)
                            ===
                            String(state.specialtyId)
                        ) {
                            doctors.push(doctor);
                        }
                    }

                    return doctors;
                }


                // ============================================================
                // 8. CLÉ D'UN CRÉNEAU
                // ============================================================

                function getSlotKey(doctorId, date, time) {

                    return doctorId
                        + '|'
                        + date
                        + '|'
                        + time;
                }


                // ============================================================
                // 9. ÉTAT D'UN CRÉNEAU
                // ============================================================

                function getSlotStatus(doctor, date, time) {

                    // Dimanche
                    if (date.getDay() === 0) {
                        return 'CLOSED';
                    }


                    // Pause déjeuner
                    if (time >= '12:00' && time < '13:00') {
                        return 'BREAK';
                    }


                    var key = getSlotKey(
                        doctor.id,
                        getDateString(date),
                        time
                    );

                    var status = slotMap[key];


                    // Aucun créneau reçu du serveur
                    if (!status) {
                        return 'CLOSED';
                    }


                    // Rendez-vous déjà pris
                    if (status === 'BOOKED') {
                        return 'BOOKED';
                    }


                    // Vérifier les 2 heures minimum
                    var start = new Date(
                        date.getFullYear(),
                        date.getMonth(),
                        date.getDate(),
                        parseInt(time.substring(0, 2)),
                        parseInt(time.substring(3, 5))
                    );


                    if (
                        start.getTime()
                        <
                        new Date().getTime() + MIN_NOTICE
                    ) {
                        return 'PAST';
                    }


                    return 'FREE';
                }


                // ============================================================
                // 10. CONSTRUIRE L'URL POUR LE SERVEUR
                // ============================================================

                function getSlotsUrl() {

                    // ---------------------------
                    // MODE SEMAINE
                    // ---------------------------

                    if (state.mode === 'week') {

                        var from = getDateString(state.weekStart);

                        var to = getDateString(
                            addDays(state.weekStart, 5)
                        );

                        return CTX
                            + '/patient/agenda?doctorId='
                            + encodeURIComponent(state.doctorId)
                            + '&from='
                            + from
                            + '&to='
                            + to;
                    }


                    // ---------------------------
                    // MODE JOUR
                    // ---------------------------

                    var doctors = getVisibleDoctors();

                    var doctorIds = '';

                    for (var i = 0; i < doctors.length; i++) {

                        if (i > 0) {
                            doctorIds += ',';
                        }

                        doctorIds += doctors[i].id;
                    }


                    return CTX
                        + '/patient/agenda?date='
                        + getDateString(state.day)
                        + '&doctorIds='
                        + encodeURIComponent(doctorIds);
                }


                // ============================================================
                // 11. CHARGER LES CRÉNEAUX
                // ============================================================

                function loadSlots() {

                    var url = getSlotsUrl();

                    var currentRequest = ++requestNumber;


                    fetch(url, {
                        headers: {
                            'Accept': 'application/json'
                        }
                    })

                        .then(function (response) {

                            if (!response.ok) {
                                throw new Error(
                                    'Erreur serveur : ' + response.status
                                );
                            }


                            var contentType =
                                response.headers.get('content-type') || '';


                            if (contentType.indexOf('application/json') === -1) {

                                throw new Error(
                                    'Session expirée. Reconnectez-vous.'
                                );
                            }


                            return response.json();
                        })


                        .then(function (rows) {

                            // Une ancienne requête est arrivée après
                            // une nouvelle requête.
                            if (currentRequest !== requestNumber) {
                                return;
                            }


                            slotMap = {};


                            for (var i = 0; i < rows.length; i++) {

                                var row = rows[i];

                                var key = getSlotKey(
                                    row.doctorId,
                                    row.date,
                                    row.time
                                );

                                slotMap[key] = row.status;
                            }


                            showError('');

                            renderAgenda();
                        })


                        .catch(function (error) {

                            if (currentRequest !== requestNumber) {
                                return;
                            }


                            slotMap = {};

                            showError(error.message);

                            renderAgenda();
                        });
                }


                // ============================================================
                // 12. AFFICHER UNE ERREUR
                // ============================================================

                function showError(message) {

                    var box = getElement('agendaError');

                    box.textContent = message;

                    if (message) {
                        box.style.display = 'block';
                    } else {
                        box.style.display = 'none';
                    }
                }


                // ============================================================
                // 13. REMPLIR LE FILTRE SPÉCIALITÉ
                // ============================================================

                function fillSpecialties() {

                    var select = getElement('f-specialty');

                    select.innerHTML =
                        '<option value="">Toutes les spécialités</option>';


                    for (var i = 0; i < SPECIALTIES.length; i++) {

                        var specialty = SPECIALTIES[i];

                        select.innerHTML +=
                            '<option value="'
                            + specialty.id
                            + '">'
                            + specialty.name
                            + '</option>';
                    }


                    select.value = state.specialtyId;
                }


                // ============================================================
                // 14. REMPLIR LE FILTRE MÉDECIN
                // ============================================================

                function fillDoctors() {

                    var doctors = getVisibleDoctors();

                    var doctorSelect = getElement('f-doctor');


                    // Vérifier si le médecin actuel existe encore
                    var doctorExists = false;

                    for (var i = 0; i < doctors.length; i++) {

                        if (
                            String(doctors[i].id)
                            ===
                            String(state.doctorId)
                        ) {
                            doctorExists = true;
                            break;
                        }
                    }


                    // Si le médecin n'existe plus,
                    // prendre le premier médecin
                    if (!doctorExists) {

                        if (doctors.length > 0) {
                            state.doctorId = doctors[0].id;
                        } else {
                            state.doctorId = '';
                        }
                    }


                    doctorSelect.innerHTML = '';


                    for (var j = 0; j < doctors.length; j++) {

                        doctorSelect.innerHTML +=
                            '<option value="'
                            + doctors[j].id
                            + '">'
                            + doctors[j].name
                            + '</option>';
                    }


                    doctorSelect.value = state.doctorId;


                    // En mode journée, le médecin n'est pas sélectionnable
                    if (state.mode === 'day') {
                        doctorSelect.disabled = true;
                    } else {
                        doctorSelect.disabled = false;
                    }
                }


                // ============================================================
                // 15. REMPLIR TOUS LES FILTRES
                // ============================================================

                function fillFilters() {

                    fillSpecialties();

                    fillDoctors();
                }


                // ============================================================
                // 16. CONSTRUIRE LES COLONNES DE L'AGENDA
                // ============================================================

                function getColumns() {

                    var columns = [];


                    // ---------------------------
                    // MODE JOUR
                    // ---------------------------

                    if (state.mode === 'day') {

                        var doctors = getVisibleDoctors();

                        for (var i = 0; i < doctors.length; i++) {

                            columns.push({

                                title: doctors[i].name,

                                specialty: getSpecialtyName(
                                    doctors[i].specialtyId
                                ),

                                doctor: doctors[i],

                                date: state.day
                            });
                        }


                        return columns;
                    }


                    // ---------------------------
                    // MODE SEMAINE
                    // ---------------------------

                    var doctor = findDoctor(state.doctorId);


                    if (!doctor) {
                        return columns;
                    }


                    for (var dayNumber = 0; dayNumber < 6; dayNumber++) {

                        var date = addDays(
                            state.weekStart,
                            dayNumber
                        );


                        columns.push({

                            title: DAYS[date.getDay()],

                            specialty: formatDate(date),

                            doctor: doctor,

                            date: date
                        });
                    }


                    return columns;
                }


                // ============================================================
                // 17. AFFICHER UN CRÉNEAU
                // ============================================================

                function createSlot(status, column, time) {

                    if (status === 'FREE') {

                        return '<button'
                            + ' type="button"'
                            + ' class="slot free"'
                            + ' data-doctor="' + column.doctor.id + '"'
                            + ' data-date="' + getDateString(column.date) + '"'
                            + ' data-time="' + time + '"'
                            + '>'
                            + time
                            + '</button>';
                    }


                    if (status === 'BOOKED') {
                        return '<span class="slot booked">Occupé</span>';
                    }


                    if (status === 'PAST') {
                        return '<span class="slot past">'
                            + time
                            + '</span>';
                    }


                    if (status === 'BREAK') {
                        return '<span class="slot break">Pause</span>';
                    }


                    return '<span class="slot closed">·</span>';
                }


                // ============================================================
                // 18. AFFICHER L'AGENDA
                // ============================================================

                function renderAgenda() {

                    var columns = getColumns();

                    var agenda = getElement('agenda');


                    // Nombre de colonnes
                    var numberOfColumns = columns.length;

                    if (numberOfColumns === 0) {
                        numberOfColumns = 1;
                    }


                    agenda.style.gridTemplateColumns =
                        '64px repeat('
                        + numberOfColumns
                        + ', minmax(110px, 1fr))';


                    var html = '';

                    // Coin en haut à gauche
                    html += '<div class="a-corner"></div>';


                    // ---------------------------
                    // TITRES DES COLONNES
                    // ---------------------------

                    for (var i = 0; i < columns.length; i++) {

                        var column = columns[i];

                        var className = 'a-head';


                        if (
                            getDateString(column.date)
                            ===
                            getDateString(today)
                        ) {
                            className += ' today';
                        }


                        html +=
                            '<div class="'
                            + className
                            + '"';


                        // En mode journée,
                        // cliquer sur le médecin ouvre sa semaine
                        if (state.mode === 'day') {

                            html +=
                                ' data-doctor="'
                                + column.doctor.id
                                + '"';
                        }


                        html += '>';

                        html += '<b>'
                            + column.title
                            + '</b>';

                        html += '<small>'
                            + column.specialty
                            + '</small>';

                        html += '</div>';
                    }


                    // Aucun médecin
                    if (columns.length === 0) {

                        html +=
                            '<div class="a-head">'
                            + '<small>Aucun médecin pour cette spécialité</small>'
                            + '</div>';
                    }


                    // ---------------------------
                    // LES HEURES
                    // ---------------------------

                    for (var t = 0; t < TIMES.length; t++) {

                        var time = TIMES[t];


                        // Heure à gauche
                        html +=
                            '<div class="a-time">'
                            + time
                            + '</div>';


                        // Créneaux des médecins
                        for (var c = 0; c < columns.length; c++) {

                            var column = columns[c];


                            var status = getSlotStatus(
                                column.doctor,
                                column.date,
                                time
                            );


                            html +=
                                '<div class="a-cell">'
                                + createSlot(
                                    status,
                                    column,
                                    time
                                )
                                + '</div>';
                        }
                    }


                    agenda.innerHTML = html;
                }


                // ============================================================
                // 19. AFFICHER LE TITRE
                // ============================================================

                function renderTitle() {

                    var title = getElement('agendaTitle');

                    var doctorCard = getElement('doctorCard');


                    // ---------------------------
                    // MODE JOUR
                    // ---------------------------

                    if (state.mode === 'day') {

                        var date = state.day;


                        title.textContent =
                            DAYS_LONG[date.getDay()]
                            + ' '
                            + formatDate(date)
                            + ' '
                            + date.getFullYear();


                        doctorCard.style.display = 'none';

                        return;
                    }


                    // ---------------------------
                    // MODE SEMAINE
                    // ---------------------------

                    var endDate = addDays(
                        state.weekStart,
                        5
                    );


                    title.textContent =
                        formatDate(state.weekStart)
                        + ' – '
                        + formatDate(endDate)
                        + ' '
                        + endDate.getFullYear();


                    var doctor = findDoctor(state.doctorId);


                    if (!doctor) {

                        doctorCard.style.display = 'none';

                        return;
                    }


                    doctorCard.style.display = 'flex';


                    doctorCard.innerHTML =
                        '<div class="avatar">'
                        + doctor.name.charAt(0)
                        + '</div>'

                        + '<div>'
                        + '<b>' + doctor.name + '</b>'
                        + '<small>'
                        + getSpecialtyName(doctor.specialtyId)
                        + ' · '
                        + (doctor.department || '')
                        + '</small>'
                        + '</div>'

                        + '<div class="rules">'
                        + 'Rendez-vous de '
                        + SLOT_MINUTES
                        + ' min'
                        + ' · réservation jusqu\'à 2 h avant'
                        + '<br>'
                        + 'Annulation possible jusqu\'à 12 h avant'
                        + '</div>';
                }


                // ============================================================
                // 20. RAFRAÎCHIR L'AGENDA
                // ============================================================

                function refresh() {

                    fillFilters();

                    renderTitle();


                    var columns = getColumns();


                    if (columns.length === 0) {

                        slotMap = {};

                        showError('');

                        renderAgenda();

                        return;
                    }


                    loadSlots();
                }


                // ============================================================
                // 21. CHANGER DE MODE
                // ============================================================

                function changeMode(mode) {

                    state.mode = mode;


                    if (mode === 'week') {

                        getElement('tab-week')
                            .classList.add('active');

                        getElement('tab-day')
                            .classList.remove('active');
                    } else {

                        getElement('tab-day')
                            .classList.add('active');

                        getElement('tab-week')
                            .classList.remove('active');
                    }


                    refresh();
                }


                // ============================================================
                // 22. PRÉCÉDENT / SUIVANT
                // ============================================================

                function moveCalendar(number) {

                    // ---------------------------
                    // MODE SEMAINE
                    // ---------------------------

                    if (state.mode === 'week') {

                        var newWeek = addDays(
                            state.weekStart,
                            number * 7
                        );


                        // Ne pas aller avant cette semaine
                        if (newWeek < getMonday(today)) {
                            return;
                        }


                        state.weekStart = newWeek;
                    }


                        // ---------------------------
                        // MODE JOUR
                    // ---------------------------

                    else {

                        var newDay = addDays(
                            state.day,
                            number
                        );


                        // Ne pas aller dans le passé
                        if (newDay < today) {
                            return;
                        }


                        state.day = newDay;
                    }


                    refresh();
                }


                // ============================================================
                // 23. BOUTONS DE NAVIGATION
                // ============================================================

                getElement('btn-prev')
                    .addEventListener('click', function () {

                        moveCalendar(-1);
                    });


                getElement('btn-next')
                    .addEventListener('click', function () {

                        moveCalendar(1);
                    });


                getElement('btn-today')
                    .addEventListener('click', function () {

                        state.day = new Date(today);

                        state.weekStart = getMonday(today);

                        refresh();
                    });


                // ============================================================
                // 24. BOUTONS JOUR / SEMAINE
                // ============================================================

                getElement('tab-day')
                    .addEventListener('click', function () {

                        changeMode('day');
                    });


                getElement('tab-week')
                    .addEventListener('click', function () {

                        changeMode('week');
                    });


                // ============================================================
                // 25. FILTRE SPÉCIALITÉ
                // ============================================================

                getElement('f-specialty')
                    .addEventListener('change', function () {

                        state.specialtyId = this.value;

                        refresh();
                    });


                // ============================================================
                // 26. FILTRE MÉDECIN
                // ============================================================

                getElement('f-doctor')
                    .addEventListener('change', function () {

                        state.doctorId = this.value;

                        refresh();
                    });


                // ============================================================
                // 27. MODALE DE RÉSERVATION
                // ============================================================

                var bookingModal = getElement('bookingModal');

                var bookingForm = getElement('bookingForm');


                function openBooking(doctorId, date, time) {

                    var doctor = findDoctor(doctorId);


                    // Remplir les champs cachés du formulaire

                    bookingForm.elements['doctorId'].value =
                        doctorId;

                    bookingForm.elements['date'].value =
                        date;

                    bookingForm.elements['startTime'].value =
                        time;

                    bookingForm.elements['endTime'].value =
                        addMinutes(time, SLOT_MINUTES);


                    // Afficher le résumé

                    var selectedDate =
                        new Date(date + 'T00:00:00');


                    var summary = '';


                    if (doctor) {

                        summary +=
                            '<b>'
                            + doctor.name
                            + '</b>'
                            + ' · '
                            + getSpecialtyName(doctor.specialtyId)
                            + '<br>';
                    }


                    summary +=
                        DAYS_LONG[selectedDate.getDay()]
                        + ' '
                        + formatDate(selectedDate)
                        + ' '
                        + selectedDate.getFullYear()
                        + ' · de <b>'
                        + time
                        + '</b> à <b>'
                        + addMinutes(time, SLOT_MINUTES)
                        + '</b>';


                    getElement('bookingSummary').innerHTML =
                        summary;


                    bookingModal.showModal();
                }


                // ============================================================
                // 28. CLIC SUR L'AGENDA
                // ============================================================

                getElement('agenda')
                    .addEventListener('click', function (event) {


                        // ---------------------------
                        // Cliquer sur un créneau libre
                        // ---------------------------

                        var slot =
                            event.target.closest('.slot.free');


                        if (slot) {

                            openBooking(
                                slot.dataset.doctor,
                                slot.dataset.date,
                                slot.dataset.time
                            );

                            return;
                        }


                        // ---------------------------
                        // Cliquer sur un médecin
                        // ---------------------------

                        var doctorHeader =
                            event.target.closest(
                                '.a-head[data-doctor]'
                            );


                        if (doctorHeader) {

                            state.doctorId =
                                doctorHeader.dataset.doctor;

                            changeMode('week');
                        }
                    });


                // ============================================================
                // 29. FERMER LA MODALE
                // ============================================================

                bookingModal.addEventListener(
                    'click',
                    function (event) {

                        if (event.target === bookingModal) {
                            bookingModal.close();
                        }
                    }
                );


                // ============================================================
                // 30. DÉMARRER L'AGENDA
                // ============================================================

                refresh();


                // ============================================================
                // 31. ROUVRIR LA MODALE APRÈS UNE ERREUR
                // ============================================================

                <c:if test="${openModal}">

                if (bookingForm.elements['doctorId'].value) {

                    openBooking(
                        bookingForm.elements['doctorId'].value,
                        bookingForm.elements['date'].value,
                        bookingForm.elements['startTime'].value
                    );
                }

                </c:if>

            </script>
        </main>
    </div>
</div>
</body>
</html>