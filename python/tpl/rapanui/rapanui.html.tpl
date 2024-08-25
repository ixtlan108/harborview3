<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">

<head th:replace="~{head.html :: head('Rapa Nui')}">
    <title>Rapa Nui</title>
</head>

<body>
    <div th:replace="~{navbar.html :: navbar}"></div>
    <div class="logo"></div>
    <div id="rapanui"></div>
    <div th:replace="~{head.html :: scripts}"></div>
    <div th:replace="~{footer.html :: footer}"></div>

    <!--
    <script type="text/javascript" src="/js/sortable.min.js"></script>
    -->
    <script type="text/javascript" src="/js/rapanui/${psname}"></script>
    <link rel="stylesheet" href="/css/rapanui/${cssname}">

</body>

</html>