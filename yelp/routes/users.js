const express = require('express');
const router = express.Router();
const catchAsync = require('../utils/catchAsync');
//const ExpressError = require('../utils/ExpressError');
const Campground = require('../models/campground');
const User = require('../models/user')
const users = require('../controllers/users')
const passport = require('passport')

router.route('/register')
    .get(users.registerPage)
    .post(catchAsync(users.register))
router.route('/login')
    .get(users.loginPage)
    .post(passport.authenticate('local', {failureFlash: true,failureRedirect: '/login'}), users.authenticateLogin)
router.route('/logout')
    .get(users.logout)

module.exports = router;