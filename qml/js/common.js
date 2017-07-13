.pragma library

var api = 'https://api.bgm.tv';

var querystring;

if (typeof module !== 'undefined' && module.exports) {
    var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
    querystring = require("querystring");
    console.log('Running with Node.js');
} else {
    querystring = {
        stringify: function(obj) {
            return Object.keys(obj).map(function(k) {
                return encodeURIComponent(k) + '=' + encodeURIComponent(obj[k]);
            }).join('&');
        }
    };
}

var http = {
    get: function(path, onSuccess, onFailure) {
        this.request({
            'method': 'GET',
            'path': path,
        }, onSuccess, onFailure);
    },
    post: function(path, data, onSuccess, onFailure) {
        var headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
        };
        this.request({
            'method': 'POST',
            'path': path,
            'data': data,
            'headers': headers,
        }, onSuccess, onFailure);
    },
    request: function(options, onSuccess, onFailure) {
        if (typeof(onSuccess) !== 'function')
            onSuccess = function(resp) { console.log(resp) };
        if (typeof(onFailure) !== 'function')
            onFailure = function(resp) { console.error('ERROR:', resp) };

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4) {
                console.log('http status: ' + xhr.status);
                switch (xhr.status) {
                    case 200:
                    case 201:
                    case 204:
                        try {
                            var resp = JSON.parse(xhr.responseText);
                            onSuccess(resp);
                        } catch (e) {
                            console.warn(e);
                            onFailure({});
                        }
                        break;
                    case 404:
                        onFailure('404 Not found');
                        break;
                    case 500:
                        onFailure('500 Server error');
                        break;
                    default:
                        onFailure(xhr.status + ' ' + xhr.responseText);
                }
            }
        };

        var url = api + '/';
        if (options.path) {
            if (options.path[0] === '/')
                url += options.path.substr(1);
            else
                url += options.path;
        }

        xhr.open(options.method, url, true);
        console.log('Open:', options.method, url);

        if (options.headers && JSON.stringify(options.headers) !== '{}') {
            for (var name in options.headers) {
                console.log('Add headers', name);
                xhr.setRequestHeader(name, options.headers[name]);
            }
        }

        if (options.method === 'POST' && options.data) {
            console.log('Send request / with data');
            xhr.send(options.data);
        } else {
            console.log('Send request / empty');
            xhr.send();
        }
    },
};



