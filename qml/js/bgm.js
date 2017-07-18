.pragma library

.import "common.js" as Common
.import "accounts.js" as Accounts

var http = Common.http;
var querystring = Common.querystring;

var api = 'https://api.bgm.tv';
var user = null;
var _debug = true;


var handleCallback = function(resp, callback) {
    if (typeof(callback) === 'function') {
        callback(resp);
    } else {
        console.error('ERROR: invalid callback');
    }
};

/**
 * Auth Check
 */
function authCheck(_user, onSuccess, onFailure) {
    if (_user && _user.id && _user.auth) {
        // 1. _user is an (authenticated) user
        user = _user;
        handleCallback(user, onSuccess);
    } else if (_user && _user.email && _user.passwd) {
        // 2. _user is an account
        auth(_user.email, _user.passwd, onSuccess, onFailure);
    } else {
        // 3. read account from db
        var account = Accounts.current();
        if (account && account.email && account.passwd) {
            auth(account.email, account.passwd, onSuccess, onFailure);
        } else {
            handleCallback('ERROR: invalid user', onFailure);
        }
    }
}


function auth(email, passwd, onSuccess, onFailure) {
    var path = '/auth?source=onAir';
    var postData = querystring.stringify({
        'username': email,
        'password': passwd,
        'auth': 0,
        'sysuid': 0,
        'sysusername': 0
    });
    http.post(path, postData, function(resp) {
        user = resp;
        if (_debug) console.log('Login success');
        handleCallback(user, onSuccess);
    }, function(err) {
        user = null; // TODO ?
        console.error('ERROR:', 'Login:', JSON.stringify(err));
        handleCallback(err, onFailure);
    });
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
