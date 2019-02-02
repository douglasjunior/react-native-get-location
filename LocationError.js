
class LocationError extends Error {

    constructor(code, message) {
        super(message);
        this.name = 'LocationError';
        this.code = code;
        this.message = message;
    }

}

export default LocationError;
