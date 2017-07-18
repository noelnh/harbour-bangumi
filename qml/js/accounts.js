.pragma library

.import "./storage.js" as Storage

var db = Storage.db;


/**
 * Save an account
 */
function save(email, passwd, user_id, user_str) {
    console.log("Adding account", user_id, email);
    if (!email || !passwd || !user_id)
        return;
    db.transaction(function(tx) {
        tx.executeSql("INSERT OR REPLACE INTO accounts VALUES (?, ?, ?, ?);", [email, passwd, user_id, user_str]);
        tx.executeSql("COMMIT;");
    });
}


/**
 * Remove an account
 */
function remove(user_id) {
    console.log("Removing an account", user_id);
    db.transaction(function(tx) {
        try {
            tx.executeSql("DELETE FROM accounts WHERE user_id = ?;", [user_id]);
            tx.executeSql("COMMIT;");
        } catch (err) {
            console.error("Error deleting from table accounts:", err);
        }
    });
}


/**
 * Find all accounts
 */
function findAll() {
    var accounts = [];
    db.readTransaction(function(tx) {
        var results = tx.executeSql("SELECT * FROM accounts;");
        var len = results.rows.length;
        for (var i = 0; i < len; i++) {
            var account = results.rows.item(i);
            if (account.user_str) {
                account.user = JSON.parse(account.user_str);
            }
            accounts.push(account);
        }
    });
    return accounts;
}


/**
 * Find current account
 */
function current(attr) {
    var account = null;
    db.readTransaction(function(tx) {
        var query = "SELECT * FROM accounts WHERE user_id = (SELECT value FROM settings WHERE key = 'current_id');";
        var results = tx.executeSql(query);
        if (results.rows.length !== 1) {
            console.error("Found 0 or more than one account:", results.rows.length);
        } else {
            account = results.rows.item(0);
            if (account.user_str) {
                account.user = JSON.parse(account.user_str);
            }
        }
    });
    if (attr === 'user') {
        if (account && account.user)
            return account.user;
        else
            return null;
    }
    return account;
}


/**
 * Find account by user_id or email
 */
function find(user_id, email) {
    var account = null;
    db.readTransaction(function(tx) {
        var query = "SELECT * FROM accounts WHERE user_id = ? OR email = ?;";
        var results = tx.executeSql(query, [user_id, email]);
        if (results.rows.length !== 1) {
            console.error("Found 0 or more than one account:", results.rows.length);
            account = null;
        } else {
            account = results.rows.item(0);
        }
    });
    return account;
}


/**
 * Change account
 */
function change(user_id) {
    console.log("Changing account", user_id);
    db.transaction(function(tx) {
        tx.executeSql("INSERT OR REPLACE INTO settings VALUES (?, ?);", ['current_id', user_id]);
        tx.executeSql("COMMIT;");
    });
}
