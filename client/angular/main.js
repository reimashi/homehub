"use strict";

var modules = [
    'ngRoute',
    'ngAnimate'
];

var app = angular.module("homehub", modules);

app.config(function ($routeProvider) {
    $routeProvider
        .when("/", {
            templateUrl: 'main.html',
            controller: 'MainController'
        })
        .otherwise({
            redirectTo: "/"
        });
});
