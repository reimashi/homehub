module.exports = class ErrorResponse {
    constructor(code, errors) {
        this.status = Number(code);

        switch (this.status) {
            case 400:
                this.statusText = "Bad Request";
                break;
            case 401:
                this.statusText = "Unauthorized";
                break;
            case 403:
                this.statusText = "Forbidden";
                break;
            case 404:
                this.statusText = "Not Found";
                break;
            case 405:
                this.statusText = "Method Not Allowed";
                break;
            case 406:
                this.statusText = "Not Acceptable";
                break;
            case 407:
                this.statusText = "Proxy Authentication Required";
                break;
            case 408:
                this.statusText = "Request Timeout";
                break;
            case 409:
                this.statusText = "Conflict";
                break;
            case 410:
                this.statusText = "Gone";
                break;
            default:
            case 500:
                this.status = 500;
                this.statusText = "Internal Server Error";
                break;
            case 501:
                this.statusText = "Not Implemented";
                break;
            case 502:
                this.statusText = "Bad Gateway";
                break;
            case 503:
                this.statusText = "Service Unavailable";
                break;
            case 504:
                this.statusText = "Gateway Timeout";
                break;
        }

        if (errors) {
            if (Array.isArray(errors)) {
                this.errors = [{ field: null, location: null, messages: errors, types: [] }];
            } else if (typeof errors === 'object') {
                this.errors = [errors];
            } else {
                this.errors = [{ field: null, location: null, messages: [String(errors)], types: [] }];
            }
        } else {
            this.errors = [];
        }
    }
}
