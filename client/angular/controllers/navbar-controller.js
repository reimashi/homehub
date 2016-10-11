app.controller("NavbarController", ["$scope", 'NavbarService', function ($scope, navbar) {
    $scope.changeSize = navbar.changeSize;
}]);