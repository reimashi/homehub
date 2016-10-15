app.factory('ApiService', ['$rootScope', '$http', '$auth', function ($rootScope, $http, $auth) {
    return {
        isAuthenticated: $auth.isAuthenticated,

        login: function(email, password) {
            return $auth.login({ email: String(email), password: sha256(String(password)) });
        },

        logout: function() {
            return $auth.logout();
        },

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
