.pragma library

var api = 'https://api.bgm.tv';
var user = null;
var _authed = false;
var _debug = true;


if (typeof module !== 'undefined' && module.exports) {
    var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
    var querystring = require("querystring");
    console.log('Running with Node.js');
} else {
    var querystring = {
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


function auth(_user, onSuccess, onFailure) {
    var callBack = function(resp, callback) {
        if (typeof(callback) === 'function') {
            callback(resp);
        } else {
            console.error(resp);
            console.error('ERROR: invalid callback');
        }
    };
    if (_user.auth) {
        if (!user) user = _user;
        callBack(user, onSuccess);
    } else if (_user.name && _user.passwd) {
        var path = '/auth?source=onAir';
        var postData = querystring.stringify({
            'username': _user.name,
            'password': _user.passwd,
            'auth': 0,
            'sysuid': 0,
            'sysusername': 0
        });
        http.post(path, postData, function(resp) {
            user = resp;
            if (_debug) console.log('Login success', user.id);
            callBack(user, onSuccess);
        }, function(err) {
            user = null; // TODO ?
            console.error('ERROR:', err);
            callBack(err, onFailure);
        });
    } else {
        callBack('ERROR: invalid user', onFailure);
    }
}

function getWatching(uid, onSuccess, onFailure) {
    var path = '/user/' + uid + '/collection';
    path += '?' + querystring.stringify({
        'auth': user.auth,
        'cat': 'watching',
        'source': 'onAir',
    });
    http.get(path, onSuccess, onFailure);
}

function getProgress(uid, sid, onSuccess, onFailure) {
    var path = '/user/' + uid + '/progress';
    path += '?' + querystring.stringify({
        'auth': user.auth,
        'cat': 'watching',
        'source': 'onAir',
        'subject_id': sid,
    });
    http.get(path, onSuccess, onFailure);
}

function getSubject(sid, rgp, onSuccess, onFailure) {
    var path = '/subject/' + sid;
    path += '?' + querystring.stringify({
        'responseGroup': rgp || 'simple',
        'source': 'onAir',
    });
    http.get(path, onSuccess, onFailure);
}

function getCollection(sid, onSuccess, onFailure) {
    var path = '/collection/' + sid;
    path += '?' + querystring.stringify({
        'source': 'onAir',
        'auth': user.auth,
    });
    http.get(path, onSuccess, onFailure);
}

function search(q, start, limit, rgp, onSuccess, onFailure) {
    var path = '/search/subject/' + q;
    path += '?' + querystring.stringify({
        'responseGroup': rgp || 'simple',
        'source': 'onAir',
        'max_results': 10,
        'start': start || 0,
    });
    http.get(path, onSuccess, onFailure);
}

function updateCollection(sid, rating, stat, tags, comment, onSuccess, onFailure) {
    var path = '/collection/' + sid + '/update';
    path += '?' + querystring.stringify({
        'source': 'onAir',
        'auth': user.auth,
    });
    var postData = querystring.stringify({
        'rating': rating || 0,
        'status': stat || 'do',
        'tags': tags,
        'comment': comment,
    });
    http.post(path, postData);
}

/**
 * action: 'watched, drop, queue'
 * eps: 'epid1,epid2,...'
 */
function updateEps(epid, action, eps, onSuccess, onFailure) {
    var path = '/ep/' + epid + '/status/' + action;
    path += '?' + querystring.stringify({
        'source': 'onAir',
        'auth': user.auth,
    });
    var postData;
    if (action === 'watched' && eps) {
        postData = querystring.stringify({
            'ep_id': eps,
        });
    }
    http.post(path, postData);
}

function getMessages(onSuccess, onFailure) {
    var path = '/notify/count';
    path += '?' + querystring.stringify({
        'source': 'onAir',
        'auth': user.auth,
    });
    http.get(path);
}

function getCalendar(onSuccess, onFailure) {
    http.get('/calendar', onSuccess, onFailure);
}


exports.api = {
    auth: auth,
    getWatching: getWatching,
    getProgress: getProgress,
    getSubject: getSubject,
    getCollection: getCollection,
    search: search,
    updateCollection: updateCollection,
    updateEps: updateEps,
    getMessages: getMessages,
    getCalendar: getCalendar,
};

exports.user = function() { return user; };
