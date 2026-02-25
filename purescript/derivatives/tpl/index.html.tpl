<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">

<head th:replace="~{head.html :: head('Derivatives')}">
    <title>Nordnet Derivatives</title>
</head>

<body>
    <div th:replace="~{navbar.html :: navbar}"></div>
    <div class="logo"></div>
    <div id="derivatives"></div>
    <div th:replace="~{head.html :: scripts}"></div>
    <div th:replace="~{footer.html :: footer}"></div>

    <script type="text/javascript" src="/js/derivatives/derivatives-%s.js"></script>
    <link rel="stylesheet" href="/css/derivatives/derivatives-%s.css">
</body>

</html>
