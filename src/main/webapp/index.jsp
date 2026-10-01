<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="dash" value="/patient/dashboard"/>
<c:if test="${sessionScope.role == 'ADMIN'}"><c:set var="dash" value="/admin/dashboard"/></c:if>
<c:if test="${sessionScope.role == 'DOCTOR'}"><c:set var="dash" value="/doctor/dashboard"/></c:if>
<c:if test="${sessionScope.role == 'STAFF'}"><c:set var="dash" value="/staff/dashboard"/></c:if>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ClinicManager - Gestion de clinique</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">




</head>
<body>

<!-- ============ NAVBAR ============ -->
<header class="nav">
    <div class="container nav-inner">
        <a href="${ctx}/" class="brand">
            <span class="brand-icon">+</span>
            Clinic<span>Manager</span>
        </a>

        <nav class="nav-links">
            <a href="#services">Services</a>
            <a href="#steps">Comment ça marche</a>
            <a href="#contact">Contact</a>
        </nav>

        <div class="nav-actions">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <span class="hello">Bonjour, <c:out value="${sessionScope.user.firstName}"/></span>
                    <a href="${ctx}${dash}" class="btn btn-primary">Mon espace</a>
                    <a href="${ctx}/logout" class="btn btn-outline">Déconnexion</a>
                </c:when>
                <c:otherwise>
                    <a href="${ctx}/login" class="btn btn-outline">Connexion</a>
                    <a href="${ctx}/register" class="btn btn-primary">Inscription</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>

<!-- ============ HERO ============ -->
<section class="hero">
    <div class="container hero-inner">
        <div class="hero-text">
            <span class="badge">Clinique moderne &amp; connectée</span>
            <h1>Prenez rendez-vous avec <em>votre médecin</em> en quelques clics</h1>
            <p>Choisissez une spécialité, un médecin et un créneau disponible.
                Suivez vos rendez-vous et retrouvez votre historique médical au même endroit.</p>

            <div class="hero-cta">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${ctx}${dash}" class="btn btn-primary btn-lg">Accéder à mon espace</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${ctx}/register" class="btn btn-primary btn-lg">Créer mon compte</a>
                        <a href="${ctx}/login" class="btn btn-outline btn-lg">Se connecter</a>
                    </c:otherwise>
                </c:choose>
            </div>

            <ul class="hero-points">
                <li>✔ Créneaux en temps réel</li>
                <li>✔ Annulation jusqu'à 12 h avant</li>
                <li>✔ Données protégées</li>
            </ul>
        </div>

        <div class="hero-card">
            <div class="mini-title">Prochain rendez-vous</div>
            <div class="mini-row"><span class="avatar">DR</span>
                <div><strong>Dr. Benali</strong><small>Cardiologie</small></div>
            </div>
            <div class="mini-slot">📅 Lundi 12 octobre &nbsp;·&nbsp; 🕘 09:30</div>
            <div class="mini-status">PLANNED</div>
        </div>
    </div>
</section>

<!-- ============ SERVICES ============ -->
<section id="services" class="section">
    <div class="container">
        <h2 class="section-title">Tout pour gérer votre clinique</h2>
        <p class="section-sub">Une plateforme pour les patients, les médecins et l'administration.</p>

        <div class="grid">
            <div class="feature"><div class="ico">🧑‍⚕️</div><h3>Patients</h3>
                <p>Profil, rendez-vous et historique médical consultables à tout moment.</p></div>
            <div class="feature"><div class="ico">🩺</div><h3>Médecins</h3>
                <p>Agenda, disponibilités, absences et suivi des consultations.</p></div>
            <div class="feature"><div class="ico">📅</div><h3>Rendez-vous</h3>
                <p>Réservation, modification, annulation et replanification simples.</p></div>
            <div class="feature"><div class="ico">📝</div><h3>Notes médicales</h3>
                <p>Diagnostic et compte rendu après chaque consultation, verrouillés après validation.</p></div>
        </div>
    </div>
</section>

<!-- ============ STEPS ============ -->
<section id="steps" class="section section-alt">
    <div class="container">
        <h2 class="section-title">Comment ça marche</h2>
        <p class="section-sub">Trois étapes pour réserver votre consultation.</p>

        <div class="grid grid-3">
            <div class="step"><span class="num">1</span><h3>Créez votre compte</h3>
                <p>Inscription rapide avec votre email et un mot de passe.</p></div>
            <div class="step"><span class="num">2</span><h3>Choisissez un créneau</h3>
                <p>Spécialité, médecin, date puis horaire disponible.</p></div>
            <div class="step"><span class="num">3</span><h3>Confirmez</h3>
                <p>Votre rendez-vous est enregistré et visible dans votre espace.</p></div>
        </div>

        <c:if test="${empty sessionScope.user}">
            <div class="center">
                <a href="${ctx}/register" class="btn btn-primary btn-lg">Commencer maintenant</a>
            </div>
        </c:if>
    </div>
</section>

<!-- ============ FOOTER ============ -->
<footer id="contact" class="footer">
    <div class="container footer-inner">
        <div>
            <div class="brand brand-light"><span class="brand-icon">+</span>Clinic<span>Manager</span></div>
            <p class="muted">Application web de gestion de clinique.</p>
        </div>
        <div class="muted">
            <p>📍 Tanger, Maroc</p>
            <p>📞 +212 5 39 00 00 00</p>
            <p>✉️ contact@clinicmanager.ma</p>
        </div>
    </div>
    <div class="copy">© 2026 ClinicManager. Tous droits réservés.</div>
</footer>

</body>
</html>
