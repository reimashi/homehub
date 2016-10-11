app.controller("MainController", ["$scope", 'NavbarService', function ($scope, navbar) {
    navbar.hide();
    console.log("Controlador principal");
}]);
