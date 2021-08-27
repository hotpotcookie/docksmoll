/* Managing Database
-------------------- */
use docksmoll;
--
show databases;
db.hostInfo();
db.version();
db.stats();
--
db.dropDatabase();

/* Managing Collection
---------------------- */
db.createCollection("log");
db.createCollection("images");
--
db.getCollectionNames();
db.getCollectionInfos();
--
db.log.drop();
db.images.drop();

// Fetching Data
db.log.find();
db.log.count();
db.log.stats();
--
db.images.find();
db.images.count();
db.images.stats();
