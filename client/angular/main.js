"use strict";

var modules = [
    'ngRoute',
    'ngAnimate',
    'satellizer'
];

var app = angular.module("homehub", modules);

app.config(function ($routeProvider) {
    $routeProvider
        .when("/", {
            templateUrl: 'main.html',
            controller: 'MainController'
        })
        .when("/webs", {
            templateUrl: 'webs.html',
            controller: 'WebController'
        })
        .otherwise({
            redirectTo: "/"
        });
});
