const express = require('express');
const router = express.Router();
const catchAsync = require('../utils/catchAsync');
const ExpressError = require('../utils/ExpressError');
const Campground = require('../models/campground');
const {campgroundSchema} = require('../schemas.js');
const {isLoggedIn, validateCampground, isAuthor} = require('../middleware')
const campgrounds = require('../controllers/campgrounds');
const { get } = require('./reviews');

const multer  = require('multer')
const {storage} = require('../cloudinary')
const upload = multer({ storage })

router.route('/')
    .get(catchAsync(campgrounds.index))
    .post(isLoggedIn, upload.array('image'), validateCampground, catchAsync(campgrounds.createCampground))
    

router.route('/new')
    .get(isLoggedIn, campgrounds.renderForm)

router.route('/:id') 
    .get(catchAsync(campgrounds.showCampground))
    .put(isLoggedIn, isAuthor, upload.array('image'), validateCampground, catchAsync(campgrounds.updateCampground))
    .delete(isLoggedIn,isAuthor, catchAsync(campgrounds.deleteCampground))


router.route('/:id/edit')
    .get(isLoggedIn,isAuthor, catchAsync(campgrounds.renderEdit))


module.exports = router;
