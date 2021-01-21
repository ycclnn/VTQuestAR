const Campground = require('../models/campground');
const {cloudinary} = require('../cloudinary/index');
const catchAsync = require('../utils/catchAsync');

const mbxGeo = require('@mapbox/mapbox-sdk/services/geocoding');
const mbxToken = process.env.MAPBOX_TOKEN;
const geocoder = mbxGeo({accessToken: mbxToken})



module.exports.index = async (req, res) => {
    const campgrounds = await Campground.find({});
    res.render('campgrounds/index', { campgrounds })

}

module.exports.renderForm =  (req, res) => {
  
    res.render('campgrounds/new')

}
module.exports.createCampground = async(req,res,next)=> {
    //if (!req.body.Campground) {throw new ExpressError("Invalid data", 400)}
    
    const geoData = await geocoder.forwardGeocode({
        query: req.body.campground.location,
        limit: 1
    }).send()
    //console.log(geoData.body.features[0].geometry.coordinates);
    
    const campground = new Campground(req.body.campground);
    campground.geometry = geoData.body.features[0].geometry;

    campground.images = req.files.map(f =>({url: f.path, filename: f.filename}));
    campground.author = req.user._id;
    await campground.save();
    req.flash('success', 'Successfully post a new campground!');
    // res.send(req.body)
    res.redirect(`/campgrounds/${campground._id}`)
    
   
}

module.exports.showCampground =  async (req,res) => {
    const {id} = req.params;
    const campground = await Campground.findById(id).populate({
        path: 'reviews',
        populate: {
            path: 'author'
        }
    }).populate('author');
    //console.log(campground);
    if (!campground) {
        req.flash('error', 'No such id found!');
        return res.redirect('/campgrounds');
    }

    res.render('campgrounds/show', {campground});
    
}

module.exports.renderEdit = async (req, res) =>{
    const {id} = req.params;
    const campground = await Campground.findById(id);
    
    if (!campground) {
        req.flash('error', 'No such campground found!');
        return res.redirect('/campgrounds');
    }
    
    res.render('campgrounds/edit', {campground});
}
module.exports.updateCampground = async (req, res) =>{
    
    const {id} = req.params;
    // console.log(req.body)
    campground = await Campground.findByIdAndUpdate(id, {...req.body.campground});
    const imgs = req.files.map(f =>({url: f.path, filename: f.filename}));
    campground.images.push(...imgs);


    await campground.save();
    if (req.body.deleteImages) {
        for(let filename of req.body.deleteImages) {
            await cloudinary.uploader.destroy(filename);
        }
        await campground.updateOne({$pull: {images: {filename: {$in: req.body.deleteImages}}}})
    }
    req.flash('success', 'Successfully updated the campground!')
    res.redirect(`/campgrounds/${campground._id}`);
}
module.exports.deleteCampground = async (req, res) =>{
   
    const {id} = req.params;
    const campground = await Campground.findByIdAndDelete(id);
    req.flash('success', 'Successfully deleted!');
    res.redirect('/campgrounds');
}