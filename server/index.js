var http            = require('http');
var https           = require('https');
var express         = require('express');
var bodyParser      = require('body-parser');
var methodOverride  = require('method-override');
var winston         = require('winston');
var fs              = require('fs');
var path            = require('path');

var app             = express();
var config          = require(path.join(__dirname, "..", "config.json"));
var models          = require(path.join(__dirname, "models", "index"));

function configure() {
    app.set('x-powered-by', "homehub/0.1");

    // Permite devolver objetos JSON
    app.use(bodyParser.urlencoded({ extended: true }));
    app.use(bodyParser.json());

    // Simula metodos DELETE y PUT para REST
    app.use(methodOverride());

    // Controladores
    app.use("/auth", require(path.join(__dirname, "controllers", "auth"))(models).Router);

    // Permite servir ficheros estáticos
    app.use('/', express.static(path.join(__dirname, "..", "htdocs")));

    // Manejo de errores en json
    app.use(function(err, req, res, next){
        res.status(400).json(err);
    });
}

// Handlers

process.on('SIGINT', function() {
    exports.stop();
    process.exit(0);
});

// Iniciando el servidor

exports.start = function () {
    winston.info("[Server] Iniciando servidor web...");

    var sslPrivateKeyPath = path.join(__dirname, "..", config.https.privatekey);
    var sslCertificatePath = path.join(__dirname, "..", config.https.certificate);

    if (fs.existsSync(sslPrivateKeyPath) && fs.existsSync(sslCertificatePath)) {
        configure();
        models.fn.connect();

        if (!config.http.enabled) {
            // Iniciamos servidor HTTP solo para redireccionar
            var expressHttp = express();
            var httpServer = http.createServer(expressHttp);

            expressHttp.get('*',function(req,res) {
                var url = "https://" + req.headers['host'] + (config.https.port != 443 ? ":" + String(config.https.port) : "") + req.url;
                res.writeHead(301, { "Location": url });
                res.end();
            })

            httpServer.listen(config.http.port, function() {
                winston.info("[Server] Servicio HTTP iniciado (Puerto: " + config.http.port + ", Redirección a HTTPS)");
            });
        }
        else {
            // Iniciamos servidor HTTP
            var httpServer = http.createServer(app);
            httpServer.listen(config.http.port, function() {
                winston.info("[Server] Servicio HTTP iniciado (Puerto: " + config.http.port + ").");
            });
        }

        // Iniciamos servidor HTTPS
        var httpsOptions = {
            key: fs.readFileSync(sslPrivateKeyPath, 'utf8'),
            cert: fs.readFileSync(sslCertificatePath, 'utf8')
        };

        var httpsServer = https.createServer(httpsOptions, app);

        httpsServer.listen(config.https.port, function() {
            winston.info("[Server] Servicio HTTPS iniciado (Puerto: " + config.https.port + ").");
        });
    }
    else {
        winston.error("[Server] No se encuentran los certificados SSL.");
    }
}

exports.stop = function () {
    winston.info("[Server] Apagando servidor web...");
    models.fn.disconnect();
}

exports.start();
