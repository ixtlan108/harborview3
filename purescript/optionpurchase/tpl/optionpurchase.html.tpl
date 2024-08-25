<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">

<head th:replace="~{head.html :: head('Optionpurchase')}">
    <title>Optionpurchase</title>
</head>

<body>
    <div th:replace="~{navbar.html :: navbar}"></div>
    <div class="logo"></div>
    <div id="ps-optionpurchase"></div>
    <div th:replace="~{head.html :: scripts}"></div>
    <div th:replace="~{footer.html :: footer}"></div>

    <script type="text/javascript" src="/js/optionpurchase/optionpurchase-%s.js"></script>
    <link rel="stylesheet" href="/css/optionpurchase/optionpurchase-%s.css">

</body>

</html>