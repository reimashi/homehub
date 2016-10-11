app.controller("NavbarController", ["$scope", function ($scope) {
    $scope.hideNavbar = true;
    $scope.openNavbar = function () { $scope.hideNavbar = !$scope.hideNavbar; }
}]);