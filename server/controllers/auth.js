// Imports
const crypto = require('crypto'),
    path = require('path'),
    express = require('express'),
    bb = require('bluebird'),
    validate = require('express-validation'),
    validator = require('joi'),
    jwt = require('jsonwebtoken'),
    ErrorRes = require(path.join(__dirname, "..", "utils", "error-response")),
    config = require(path.join(__dirname, "..", "..", "config.json"));

// Global variables
class AuthController {
    constructor(models) {
        this.models = models;
        this.router = express.Router();

        this.router.post("/login", validate({
            body: {
                email: validator.string().min(3).max(128).required(),
                password: validator.string().hex().length(64).required() // Sha256
            }
        }), bb.coroutine(function*(req, res) {
            const rootUser = "root";
            const rootPass = "4813494d137e1631bba301d5acab6e7bb7aa74ce1185d456565ef51d737677b2";

            if (req.body.email != rootUser) {
                res.status(401).send(new ErrorRes(401, { field: "email", location: "body", types: ["email.notexists"], messages: ['"email" not exists']}));
            }
            else if (req.body.password != rootPass) {
                res.status(401).send(new ErrorRes(401, { field: "password", location: "body", types: ["password.mismatch"], messages: ['"password" mismatch with user password']}));
            }
            else {
                res.send({ token: jwt.sign({ username: rootUser }, config.secret) });
            }
        }));
    }

    get Router() {
        return this.router;
    }
}


module.exports = (models) => {
    return new AuthController(models);
}
