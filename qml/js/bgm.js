.pragma library

.import "common.js" as Common

var http = Common.http;
var querystring = Common.querystring;

var api = 'https://api.bgm.tv';
var user = null;
var _authed = false;
var _debug = true;

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
