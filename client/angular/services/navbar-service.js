app.factory('NavbarService', ['$rootScope', function ($rootScope) {
    $rootScope.navbarHidden = true;
    $rootScope.navbarMaximized = false;

    var fnChangeSize = function () { $rootScope.navbarMaximized = !$rootScope.navbarMaximized; }
    var fnHide = function () { $rootScope.navbarHidden = true; }
    var fnShow = function () { $rootScope.navbarHidden = false; }

    return {
        changeSize: fnChangeSize,
        hide: fnHide,
        show: fnShow
    };
}]);