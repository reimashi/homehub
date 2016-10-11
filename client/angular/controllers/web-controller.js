app.controller("WebController", ["$scope", 'NavbarService', function ($scope, navbar) {
    navbar.show();
    console.log("Controlador webs");
}]);
