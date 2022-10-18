// const Sequelize = require('../config/database.js');
require("dotenv").config();
const Sequelize = require('sequelize');
const sequelize = new Sequelize(process.env.DB_URL);
// const Sequelize = require('sequelize');
const userModel = sequelize.define('users', {
    // attributes  
    orgType: { type: Sequelize.STRING, allowNull: false },    // Central, State
    orgMinistry: { type: Sequelize.STRING, allowNull: false },     
    orgDepartment: { type: Sequelize.STRING, allowNull: false },    
    orgAddress: { type: Sequelize.STRING, allowNull: false },   
    orgEmail: { type: Sequelize.STRING, unique:true },

    conactPersonName:  { type: Sequelize.STRING , allowNull: false}, 
    conactDesignation:  { type: Sequelize.STRING , allowNull: false}, 
    email:  { type: Sequelize.STRING , allowNull: false}, 
    mobile:  { type: Sequelize.STRING , allowNull: false}, 

    password: { type: Sequelize.STRING, allowNull: false },
    token: { type: Sequelize.STRING },    
    appName: { type: Sequelize.STRING , allowNull: false}, 
    }, 
    {
    
    // options
    
    });
    userModel.sync(); //{force:true} to drop and recreate table
    module.exports = userModel;