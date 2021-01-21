const User = require('../models/user')

module.exports.registerPage = (req, res) => {
    res.render('users/register')
}
module.exports.loginPage = (req, res) => {
    res.render('users/login')
}
module.exports.authenticateLogin = (req, res) => {
    
    req.flash('success', "welcome back");
    if (req.session.returnto) {
        const returnto = req.session.returnto;
        delete req.session.returnto;
        return res.redirect(returnto);
    }
    
    res.redirect('./campgrounds')

}

module.exports.register = async(req, res) => {
    try{
    const {email, username, password} = req.body;
    const user = await new User({email, username});
    const registerUser = await User.register(user,password);
    req.login(registerUser, err=> {
        if(err) {
            return next(err);
        }
        else {
            res.redirect('/campgrounds')
        }
    })
    req.flash('success', 'Welcome to yelp camp!');
    res.redirect('/campgrounds');
    }
    catch(e) {
        req.flash('error',e.message);
        res.redirect('/register');
    }
  
}

module.exports.logout = (req, res) => {
    req.logout();
    req.flash('success', "Goodbye!");
    res.redirect('/campgrounds');
}