app.factory('ApiService', ['$rootScope', '$http', function ($rootScope, $http) {
    $rootScope.api = {
        loguedIn: false
    };

    return {
        LoguedIn: $rootScope.api.loguedIn,

        getPublicWebs: function() {
            return new Promise(function(resolve, reject) {
                reject("Not implemented");
            });
        },

        getPublicServices: function() {
            return new Promise(function(resolve, reject) {
                reject("Not implemented");
            });
        }
    };
}]);
