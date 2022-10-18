const Sequelize = require('sequelize');
const sequelize = new Sequelize('postgres://postgres:postgres@10.152.2.122:6543/webapps_mhbcn');

exports.connect = () => {
    sequelize
    .authenticate()
    .then(() => {
        console.log('Connection has been established successfully.');
    })
    .catch(err => {
        console.error('Unable to connect to the database:', err);
    });
};

