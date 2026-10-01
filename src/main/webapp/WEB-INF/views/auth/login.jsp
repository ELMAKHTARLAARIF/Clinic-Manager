<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Connexion - ClinicManager</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth/style.css">
</head>
<body class="auth-body">
<div class="auth-card">
    <h1>ClinicManager</h1>
    <h2>Connexion</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="alert alert-success"><c:out value="${success}"/></div>
    </c:if>

    <form action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" required
                   value="<c:out value='${param.email}'/>" placeholder="exemple@email.com">
        </div>

        <div class="form-group">
            <label for="password">Mot de passe</label>
            <input type="password" id="password" name="password" required minlength="6"
                   placeholder="••••••">
        </div>

        <button type="submit" class="btn">Se connecter</button>
    </form>

    <p class="auth-link">
        Pas encore de compte ?
        <a href="${pageContext.request.contextPath}/register">S'inscrire</a>
    </p>
</div>
</body>
</html>