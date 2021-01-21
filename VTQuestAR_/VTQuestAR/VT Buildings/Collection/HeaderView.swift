

import UIKit
//the headerview that contains the category name and the see all button.
class HeaderView: UICollectionReusableView {
    
    //building category text
    var name = UILabel()
    //seeAll button
    var seeAllButton = UIButton()
  
    //when see all button is clicked, direct user to see all buildings with specific category
    @objc func seeAllTapped(){
        sectionSender.send(self.seeAllButton.tag)
       
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        name.text = "Academic"
        name.numberOfLines = 2
        name.font = UIFont.boldSystemFont(ofSize: 22.0)
        
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(UIColor.blue, for: .normal)
        
        let horizontalStack = UIStackView(arrangedSubviews: [name as UIView,seeAllButton as UIView])
        
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .equalSpacing
        
        
        self.addSubview(horizontalStack)
        //horizontalStack.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        // autolayout constraint
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        //activate layout constraint
        horizontalStack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        horizontalStack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 22).isActive = true
        horizontalStack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -22).isActive = true
        horizontalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
