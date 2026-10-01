<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Erreur</title></head>
<body>
<h1>Une erreur est survenue</h1>
<p><a href="${pageContext.request.contextPath}/">Retour à l'accueil</a></p>

<h1>Erreur ${requestScope['jakarta.servlet.error.status_code']}</h1>
<p>${requestScope['jakarta.servlet.error.message']}</p>
<pre>${requestScope['jakarta.servlet.error.exception']}</pre>
</body>
</html>