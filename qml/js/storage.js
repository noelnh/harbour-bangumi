.pragma library
.import QtQuick.LocalStorage 2.0 as LS


var identifier = "harbour-bangumi";
var description = "Bangumi LocalStorage";

var CREATE_TABLES = {
    SETTINGS: 'CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT);',
    ACCOUNTS: 'CREATE TABLE IF NOT EXISTS accounts(email TEXT PRIMARY KEY, passwd TEXT, user_id TEXT, user_str TEXT);'
}


/**
 * Open app's database, create it if not exists.
 */
var db = LS.LocalStorage.openDatabaseSync(identifier, "", description, 1000000, function(db) {
    db.changeVersion(db.version, "1.0", function(tx) {
        tx.executeSql(CREATE_TABLES.SETTINGS);
        tx.executeSql(CREATE_TABLES.ACCOUNTS);
    });
});


/**
 * Reset
 */
function reset() {
    db.transaction(function(tx) {
        tx.executeSql("DROP TABLE IF EXISTS settings;");
        tx.executeSql("DROP TABLE IF EXISTS accounts;");
        tx.executeSql(CREATE_TABLES.SETTINGS);
        tx.executeSql(CREATE_TABLES.ACCOUNTS);
        tx.executeSql("COMMIT;");
    });
}


/**
 * Read
 */
function read(table, key, value) {
    var results;
    db.transaction(function(tx){
        results = tx.executeSql("SELECT * FROM ? WHERE ? = ?;", [table, key, value]);
    });
    return results.rows || [];
}
