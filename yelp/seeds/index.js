const mongoose = require('mongoose');
const cities = require('./cities');
const { places, descriptors } = require('./seedHelpers');
const Campground = require('../models/campground');


mongoose.connect('mongodb://localhost:27017/yelp-camp', {
    useNewUrlParser: true,
    useCreateIndex: true,
    useUnifiedTopology: true
});

const db = mongoose.connection;

db.on("error", console.error.bind(console, "connection error:"));
db.once("open", () => {
    console.log("Database connected");
});

const sample = array => array[Math.floor(Math.random() * array.length)];


const seedDB = async () => {
    await Campground.deleteMany({});
    for (let i = 0; i < 200; i++) {
        const random1000 = Math.floor(Math.random() * 1000);
        const price = Math.floor(Math.random() * 100);
        

     
        const camp = new Campground({
            author: '60062215f0d109edd1272344',
            location: `${cities[random1000].city}, ${cities[random1000].state}`,
            title: `${sample(descriptors)} ${sample(places)}`,
            geometry: {
                type: "Point",
                coordinates: [cities[random1000].longitude, cities[random1000].latitude]
            },
            images: [{
                
                url: 'https://res.cloudinary.com/zhennan/image/upload/v1611094686/YelpCamp/yllnvyyhhviqkeljglst.png',
                filename: 'YelpCamp/yllnvyyhhviqkeljglst'
              },
              {
                
                url: 'https://res.cloudinary.com/zhennan/image/upload/v1611094686/YelpCamp/dxo4wadhn2aimqw8dx3x.png',
                filename: 'YelpCamp/dxo4wadhn2aimqw8dx3x'
              },
              {
                
                url: 'https://res.cloudinary.com/zhennan/image/upload/v1611094687/YelpCamp/zy5wgf2zwf5ot9jojqtb.png',
                filename: 'YelpCamp/zy5wgf2zwf5ot9jojqtb'
              }],

            description: " printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived no",
            price: price
        })
        await camp.save();
    }
}

seedDB().then(() => {
    mongoose.connection.close();
}) 