<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inscription - ClinicManager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth/style.css">
</head>
<body class="auth-body">
<div class="auth-card">
    <h1>ClinicManager</h1>
    <h2>Inscription patient</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <form action="${pageContext.request.contextPath}/register" method="post" id="registerForm">
        <div class="form-row">
            <div class="form-group">
                <label for="lastName">Nom</label>
                <input type="text" id="lastName" name="lastName" required maxlength="100"
                       value="<c:out value='${param.lastName}'/>">
            </div>
            <div class="form-group">
                <label for="firstName">Prénom</label>
                <input type="text" id="firstName" name="firstName" required maxlength="100"
                       value="<c:out value='${param.firstName}'/>">
            </div>
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" required maxlength="150"
                   value="<c:out value='${param.email}'/>">
        </div>

        <div class="form-group">
            <label for="phone">Téléphone</label>
            <input type="tel" id="phone" name="phone" maxlength="20"
                   pattern="[0-9+\s]{8,20}" placeholder="+212 6 00 00 00 00"
                   value="<c:out value='${param.phone}'/>">
        </div>

        <div class="form-group">
            <label for="password">Mot de passe (6 caractères min.)</label>
            <input type="password" id="password" name="password" required minlength="6">
        </div>

        <div class="form-group">
            <label for="confirmPassword">Confirmer le mot de passe</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required minlength="6">
        </div>

        <button type="submit" class="btn">Créer mon compte</button>
    </form>

    <p class="auth-link">
        Déjà inscrit ?
        <a href="${pageContext.request.contextPath}/login">Se connecter</a>
    </p>
</div>

<script>
    document.getElementById('registerForm').addEventListener('submit', function (e) {
        var p = document.getElementById('password').value;
        var c = document.getElementById('confirmPassword').value;
        if (p !== c) {
            e.preventDefault();
            alert('Les mots de passe ne correspondent pas.');
        }
    });
</script>
</body>
</html>