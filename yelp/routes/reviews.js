//

const express = require('express');
const router = express.Router({mergeParams: true});
const catchAsync = require('../utils/catchAsync');
const ExpressError = require('../utils/ExpressError');
const Campground = require('../models/campground');
const {reviewSchema} = require('../schemas.js');
const Review = require('../models/review');
const {validateReview, isLoggedIn, isReviewAuthor} = require('../middleware')
const reviews = require('../controllers/reviews')

router.route('/')
    .post(isLoggedIn, validateReview, catchAsync(reviews.createReview))

router.route('/:reviewId')
    .delete(isLoggedIn, isReviewAuthor, catchAsync(reviews.deleteReview))




module.exports = router;